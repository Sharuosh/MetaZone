package com.example.meta_zone.ar

import android.content.Context
import android.graphics.Rect
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraManager
import android.util.Log
import android.view.Surface
import android.view.WindowManager
import com.google.ar.core.Frame
import com.google.ar.core.TrackingState
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.label.ImageLabeling
import com.google.mlkit.vision.label.defaults.ImageLabelerOptions
import com.google.mlkit.vision.objects.DetectedObject
import com.google.mlkit.vision.objects.ObjectDetection
import com.google.mlkit.vision.objects.defaults.ObjectDetectorOptions
import java.util.concurrent.atomic.AtomicBoolean
import java.util.concurrent.atomic.AtomicLong
import kotlin.math.roundToInt

/**
 * MetaZone realtime perception core for Sense -> Vision.
 *
 * Runtime pipeline:
 *
 *   ARCore Frame
 *      -> async ML Kit perception
 *      -> tracked object localization/classification
 *      -> periodic multi-object scene pass
 *      -> periodic whole-image labels
 *      -> temporal stabilization
 *      -> normalized VisionScene
 *
 * This class never blocks the AR render thread.
 *
 * IMPORTANT:
 * - The AR Camera placement system remains separate.
 * - Vision only produces perception data.
 * - Gemini/cloud AI is deliberately not used per frame.
 */
class MetaZoneVisionEngine(
    context: Context,
    private val onResult: (VisionScene) -> Unit = {},
    private val onError: (String, Throwable?) -> Unit = { _, _ -> },
) {

    companion object {
        private const val TAG = "MetaZoneVision"

        private const val MIN_OBJECT_CONFIDENCE = 0.35f
        private const val MIN_LABEL_CONFIDENCE = 0.55f

        private const val MAX_OBJECTS = 20
        private const val MAX_LABELS = 15

        /*
         * Do not submit ML work faster than this. The AR render loop itself
         * remains continuous.
         */
        private const val MIN_ANALYSIS_GAP_MS = 80L

        /*
         * Stability:
         * - require repeated observations before exposing a weak new object
         * - smooth box movement
         * - briefly retain a tracked object through detector dropouts
         */
        private const val STABLE_MIN_HITS = 2
        private const val STABLE_HOLD_MS = 900L
        private const val STABLE_ALPHA = 0.32f

        private const val LABEL_VOTE_SWITCH_HITS = 2

        private val GENERIC_LABELS =
            setOf(
                "good",
                "home good",
                "home goods",
                "fashion good",
                "fashion goods",
                "object",
                "thing",
                "item",
                "product",
                "pattern",
                "textile",
                "material",
                "design",
                "room",
                "indoor",
                "indoors",
                "outdoor",
                "outdoors",
                "interior",
                "interior design",
                "unknown",
            )

        private val PERSON_WORDS =
            setOf(
                "person",
                "people",
                "man",
                "woman",
                "child",
                "boy",
                "girl",
                "human",
            )

        private val VEHICLE_WORDS =
            setOf(
                "car",
                "vehicle",
                "bus",
                "truck",
                "motorcycle",
                "motorbike",
                "bicycle",
                "bike",
                "scooter",
            )

        private val VEGETATION_WORDS =
            setOf(
                "tree",
                "plant",
                "flower",
                "grass",
                "vegetation",
                "bush",
                "shrub",
            )

        private val FURNITURE_WORDS =
            setOf(
                "chair",
                "table",
                "desk",
                "bed",
                "sofa",
                "couch",
                "cabinet",
                "shelf",
                "bookshelf",
                "wardrobe",
                "bench",
                "stool",
                "dresser",
                "drawer",
                "seat",
                "ottoman",
                "nightstand",
                "cupboard",
            )

        private val FLOOR_WORDS =
            setOf(
                "floor",
                "ground",
                "carpet",
                "rug",
                "mat",
                "pavement",
                "sidewalk",
                "road",
                "tile",
                "tiles",
            )

        private val BUILDING_WORDS =
            setOf(
                "wall",
                "door",
                "window",
                "building",
                "ceiling",
                "stairs",
                "staircase",
            )
    }

    private val appContext = context.applicationContext

    private val scheduler =
        AdaptivePerceptionScheduler(appContext)

    /*
     * Realtime detector.
     *
     * STREAM_MODE gives us tracking IDs and low-latency updates.
     * Classification is enabled so the object itself can carry a semantic
     * category when the model has one.
     */
    private val trackerDetector =
        ObjectDetection.getClient(
            ObjectDetectorOptions.Builder()
                .setDetectorMode(
                    ObjectDetectorOptions.STREAM_MODE,
                )
                .enableClassification()
                .build(),
        )

    /*
     * Snapshot detector.
     *
     * SINGLE_IMAGE_MODE + multiple objects is the scene-coverage path.
     */
    private val multiObjectDetector =
        ObjectDetection.getClient(
            ObjectDetectorOptions.Builder()
                .setDetectorMode(
                    ObjectDetectorOptions.SINGLE_IMAGE_MODE,
                )
                .enableMultipleObjects()
                .enableClassification()
                .build(),
        )

    /*
     * Whole-image semantic context.
     *
     * Image labeling is intentionally slower and less frequent than the
     * realtime detector. It enriches scene understanding without being in the
     * frame loop.
     */
    private val labeler =
        ImageLabeling.getClient(
            ImageLabelerOptions.Builder()
                .setConfidenceThreshold(
                    MIN_LABEL_CONFIDENCE,
                )
                .build(),
        )

    private val inFlight =
        AtomicBoolean(false)

    private val frameCounter =
        AtomicLong(0L)

    private val lastAnalysisStartNs =
        AtomicLong(0L)

    @Volatile
    private var lastScene =
        VisionScene.empty()

    @Volatile
    private var lastTrackedObjects =
        emptyList<VisionObject>()

    @Volatile
    private var lastMultiObjects =
        emptyList<VisionObject>()

    @Volatile
    private var lastLabels =
        emptyList<VisionLabel>()

    private val stableLock = Any()

    private val stableObjects =
        LinkedHashMap<String, StableObjectState>()

    private val closed =
        AtomicBoolean(false)

    fun analyze(frame: Frame) {
        if (closed.get()) return

        if (
            frame.camera.trackingState !=
            TrackingState.TRACKING
        ) {
            return
        }

        val frameNumber =
            frameCounter.incrementAndGet()

        val nowNs =
            System.nanoTime()

        if (
            !inFlight.compareAndSet(
                false,
                true,
            )
        ) {
            return
        }

        val job =
            scheduler.chooseJob(
                nowNs = nowNs,
                frameNumber = frameNumber,
            )

        if (
            job ==
            AdaptivePerceptionScheduler.Job.NONE
        ) {
            inFlight.set(false)
            return
        }

        val previousStartNs =
            lastAnalysisStartNs.get()

        if (
            previousStartNs != 0L &&
            (
                nowNs -
                    previousStartNs
                ) / 1_000_000L <
            MIN_ANALYSIS_GAP_MS
        ) {
            inFlight.set(false)
            return
        }

        lastAnalysisStartNs.set(nowNs)

        val mediaImage =
            try {
                frame.acquireCameraImage()
            } catch (t: Throwable) {
                inFlight.set(false)

                scheduler.noteJobCompleted(
                    job = job,
                    durationMs = 0L,
                )

                Log.w(
                    TAG,
                    "Unable to acquire camera image",
                    t,
                )

                return
            }

        val startedNs =
            System.nanoTime()

        val rotation =
            try {
                calculateRotationDegrees()
            } catch (_: Throwable) {
                0
            }

        val inputImage =
            try {
                InputImage.fromMediaImage(
                    mediaImage,
                    rotation,
                )
            } catch (t: Throwable) {
                try {
                    mediaImage.close()
                } catch (_: Throwable) {
                }

                inFlight.set(false)

                onError(
                    "Unable to create Vision input image",
                    t,
                )

                return
            }

        fun finish() {
            try {
                mediaImage.close()
            } catch (_: Throwable) {
            }

            inFlight.set(false)

            val durationMs =
                (
                    System.nanoTime() -
                        startedNs
                    ) / 1_000_000L

            scheduler.noteJobCompleted(
                job = job,
                durationMs = durationMs,
            )

            publishScene(
                durationMs = durationMs,
            )
        }

        when (job) {
            AdaptivePerceptionScheduler.Job.TRACK -> {
                trackerDetector
                    .process(inputImage)
                    .addOnSuccessListener { detected ->
                        lastTrackedObjects =
                            detected
                                .map(
                                    { detectedObject -> detectedObject.asVisionObject() },
                                )
                                .filter {
                                    isUsefulObject(it)
                                }
                                .sortedByDescending {
                                    it.primaryConfidence
                                }
                                .take(MAX_OBJECTS)
                    }
                    .addOnFailureListener { error ->
                        Log.w(
                            TAG,
                            "Live object tracking failed",
                            error,
                        )
                        onError(
                            "Live object tracking failed",
                            error,
                        )
                    }
                    .addOnCompleteListener {
                        finish()
                    }
            }

            AdaptivePerceptionScheduler.Job.MULTI_OBJECT -> {
                multiObjectDetector
                    .process(inputImage)
                    .addOnSuccessListener { detected ->
                        lastMultiObjects =
                            detected
                                .map(
                                    { detectedObject -> detectedObject.asVisionObject() },
                                )
                                .filter {
                                    isUsefulObject(it)
                                }
                                .sortedByDescending {
                                    it.primaryConfidence
                                }
                                .take(MAX_OBJECTS)
                    }
                    .addOnFailureListener { error ->
                        Log.w(
                            TAG,
                            "Multi-object snapshot failed",
                            error,
                        )
                        onError(
                            "Multi-object snapshot failed",
                            error,
                        )
                    }
                    .addOnCompleteListener {
                        finish()
                    }
            }

            AdaptivePerceptionScheduler.Job.LABELS -> {
                labeler
                    .process(inputImage)
                    .addOnSuccessListener { detected ->
                        lastLabels =
                            detected
                                .filter {
                                    it.confidence >=
                                        MIN_LABEL_CONFIDENCE
                                }
                                .sortedByDescending {
                                    it.confidence
                                }
                                .take(MAX_LABELS)
                                .map { label ->
                                    VisionLabel(
                                        text =
                                            cleanLabel(
                                                label.text,
                                            ),
                                        confidence =
                                            label.confidence,
                                        semanticKind =
                                            classifySemantic(
                                                label.text,
                                            ),
                                    )
                                }
                    }
                    .addOnFailureListener { error ->
                        Log.w(
                            TAG,
                            "Image labeling failed",
                            error,
                        )
                        onError(
                            "Image labeling failed",
                            error,
                        )
                    }
                    .addOnCompleteListener {
                        finish()
                    }
            }

            AdaptivePerceptionScheduler.Job.NONE -> {
                finish()
            }
        }
    }

    fun latestScene(): VisionScene =
        lastScene

    fun close() {
        if (
            !closed.compareAndSet(
                false,
                true,
            )
        ) {
            return
        }

        try {
            trackerDetector.close()
        } catch (t: Throwable) {
            Log.w(
                TAG,
                "Tracker detector close failed",
                t,
            )
        }

        try {
            multiObjectDetector.close()
        } catch (t: Throwable) {
            Log.w(
                TAG,
                "Multi detector close failed",
                t,
            )
        }

        try {
            labeler.close()
        } catch (t: Throwable) {
            Log.w(
                TAG,
                "Labeler close failed",
                t,
            )
        }

        synchronized(stableLock) {
            stableObjects.clear()
        }
    }

    private fun publishScene(
        durationMs: Long,
    ) {
        val merged =
            mergeObjects(
                tracked = lastTrackedObjects,
                snapshot = lastMultiObjects,
            )

        val stable =
            stabilizeObjects(
                detected = merged,
                nowMs = android.os.SystemClock.uptimeMillis(),
            )

        val enriched =
            enrichObjectsWithSceneLabels(
                stable,
                lastLabels,
            )

        val environment =
            buildEnvironment(
                objects = enriched,
                labels = lastLabels,
            )

        val scene =
            VisionScene(
                timestampNanos = System.nanoTime(),
                objects = enriched,
                labels = lastLabels,
                environment = environment,
            )

        lastScene = scene

        logScene(
            scene = scene,
            durationMs = durationMs,
        )

        onResult(scene)
    }

    private fun stabilizeObjects(
        detected: List<VisionObject>,
        nowMs: Long,
    ): List<VisionObject> {
        synchronized(stableLock) {
            val matchedKeys =
                HashSet<String>()

            detected.forEach { objectInfo ->
                val key =
                    findStableKey(
                        objectInfo = objectInfo,
                    )

                val previous =
                    stableObjects[key]

                if (previous == null) {
                    stableObjects[key] =
                        StableObjectState(
                            key = key,
                            last = objectInfo,
                            hits = 1,
                            lastSeenMs = nowMs,
                        )
                } else {
                    previous.last =
                        smoothObject(
                            previous.last,
                            objectInfo,
                        )
                    previous.hits += 1
                    previous.lastSeenMs = nowMs
                    updateStableLabel(
                        previous,
                        objectInfo,
                    )
                }

                matchedKeys.add(key)
            }

            val iterator =
                stableObjects.iterator()

            while (iterator.hasNext()) {
                val entry =
                    iterator.next()

                val state =
                    entry.value

                if (
                    entry.key !in matchedKeys &&
                    nowMs -
                        state.lastSeenMs >
                    STABLE_HOLD_MS
                ) {
                    iterator.remove()
                }
            }

            return stableObjects
                .values
                .filter { state ->
                    val ageMs =
                        nowMs -
                            state.lastSeenMs

                    state.hits >= STABLE_MIN_HITS ||
                        (
                            ageMs <= 180L &&
                            state.last.primaryConfidence >=
                                0.75f
                            )
                }
                .sortedByDescending {
                    it.last.primaryConfidence
                }
                .take(MAX_OBJECTS)
                .map { it.last }
                .toList()
        }
    }

    private fun findStableKey(
        objectInfo: VisionObject,
    ): String {
        if (objectInfo.trackingId >= 0) {
            return "track:${objectInfo.trackingId}"
        }

        var bestKey: String? = null
        var bestScore = 0f

        stableObjects.forEach { (key, state) ->
            val score =
                overlapScore(
                    a = state.last.bounds,
                    b = objectInfo.bounds,
                )

            if (score > bestScore) {
                bestScore = score
                bestKey = key
            }
        }

        return if (
            bestKey != null &&
            bestScore >= 0.25f
        ) {
            bestKey!!
        } else {
            "anon:${objectInfo.primaryLabel}:${objectInfo.bounds.centerX()}:${objectInfo.bounds.centerY()}"
        }
    }

    private fun smoothObject(
        previous: VisionObject,
        current: VisionObject,
    ): VisionObject {
        val blended =
            blendRect(
                previous.bounds,
                current.bounds,
                STABLE_ALPHA,
            )

        val currentLabel =
            if (
                isUsefulLabel(
                    current.primaryLabel,
                )
            ) {
                current.primaryLabel
            } else {
                previous.primaryLabel
            }

        val currentKind =
            if (
                current.semanticKind !=
                SemanticKind.UNKNOWN
            ) {
                current.semanticKind
            } else {
                previous.semanticKind
            }

        val confidence =
            (
                previous.primaryConfidence *
                    (1f - STABLE_ALPHA) +
                    current.primaryConfidence *
                    STABLE_ALPHA
                ).coerceIn(0f, 1f)

        return previous.copy(
            bounds = blended,
            labels =
                if (current.labels.isNotEmpty()) {
                    current.labels
                } else {
                    previous.labels
                },
            primaryLabel = currentLabel,
            primaryConfidence = confidence,
            semanticKind = currentKind,
        )
    }

    private fun updateStableLabel(
        state: StableObjectState,
        incoming: VisionObject,
    ) {
        if (
            !isUsefulLabel(
                incoming.primaryLabel,
            )
        ) {
            return
        }

        if (
            incoming.primaryLabel ==
            state.last.primaryLabel
        ) {
            state.pendingLabel = null
            state.pendingLabelHits = 0
            return
        }

        if (
            incoming.primaryLabel ==
            state.pendingLabel
        ) {
            state.pendingLabelHits += 1
        } else {
            state.pendingLabel =
                incoming.primaryLabel
            state.pendingLabelHits = 1
        }

        if (
            state.pendingLabelHits >=
            LABEL_VOTE_SWITCH_HITS
        ) {
            state.last =
                state.last.copy(
                    primaryLabel =
                        incoming.primaryLabel,
                    semanticKind =
                        incoming.semanticKind,
                    primaryConfidence =
                        maxOf(
                            state.last.primaryConfidence,
                            incoming.primaryConfidence,
                        ),
                )
            state.pendingLabel = null
            state.pendingLabelHits = 0
        }
    }

    private fun enrichObjectsWithSceneLabels(
        objects: List<VisionObject>,
        labels: List<VisionLabel>,
    ): List<VisionObject> {
        if (objects.isEmpty() || labels.isEmpty()) {
            return objects
        }

        /*
         * The whole-image labeler has no per-object bounding box. Therefore we
         * only promote a scene label into the object label when there is exactly
         * one stable object and that semantic category is specific enough.
         * This avoids incorrectly naming every object "Chair".
         */
        if (objects.size != 1) {
            return objects
        }

        val objectInfo = objects.first()

        if (
            isUsefulLabel(
                objectInfo.primaryLabel,
            )
        ) {
            return objects
        }

        val useful =
            labels.firstOrNull {
                isUsefulLabel(it.text)
            } ?: return objects

        return listOf(
            objectInfo.copy(
                primaryLabel = useful.text,
                primaryConfidence =
                    maxOf(
                        objectInfo.primaryConfidence,
                        useful.confidence,
                    ),
                semanticKind = useful.semanticKind,
            ),
        )
    }

    private fun mergeObjects(
        tracked: List<VisionObject>,
        snapshot: List<VisionObject>,
    ): List<VisionObject> {
        if (tracked.isEmpty()) return snapshot
        if (snapshot.isEmpty()) return tracked

        val result =
            ArrayList<VisionObject>(
                tracked.size + snapshot.size,
            )

        result.addAll(tracked)

        snapshot.forEach { candidate ->
            val duplicate =
                result.any { existing ->
                    sameObject(
                        existing,
                        candidate,
                    )
                }

            if (!duplicate) {
                result.add(candidate)
            }
        }

        return result
            .sortedByDescending {
                it.primaryConfidence
            }
            .take(MAX_OBJECTS)
    }

    private fun sameObject(
        a: VisionObject,
        b: VisionObject,
    ): Boolean {
        if (
            a.trackingId != -1 &&
            b.trackingId != -1 &&
            a.trackingId == b.trackingId
        ) {
            return true
        }

        val overlap =
            overlapScore(
                a.bounds,
                b.bounds,
            )

        if (overlap >= 0.25f) {
            return true
        }

        if (
            a.semanticKind !=
            b.semanticKind
        ) {
            return false
        }

        val ax = a.bounds.centerX().toFloat()
        val ay = a.bounds.centerY().toFloat()
        val bx = b.bounds.centerX().toFloat()
        val by = b.bounds.centerY().toFloat()

        val dx = ax - bx
        val dy = ay - by

        val maxDistance =
            (
                maxOf(
                    a.bounds.width(),
                    b.bounds.width(),
                ) * 0.45f
            ).coerceAtLeast(32f)

        return (
            dx * dx +
                dy * dy
            ) <=
            maxDistance * maxDistance
    }

    private fun blendRect(
        a: Rect,
        b: Rect,
        alpha: Float,
    ): Rect {
        fun blend(
            x: Int,
            y: Int,
        ): Int =
            (
                x * (1f - alpha) +
                    y * alpha
                ).roundToInt()

        return Rect(
            blend(a.left, b.left),
            blend(a.top, b.top),
            blend(a.right, b.right),
            blend(a.bottom, b.bottom),
        )
    }

    private fun overlapScore(
        a: Rect,
        b: Rect,
    ): Float {
        val left = maxOf(a.left, b.left)
        val top = maxOf(a.top, b.top)
        val right = minOf(a.right, b.right)
        val bottom = minOf(a.bottom, b.bottom)

        if (
            right <= left ||
            bottom <= top
        ) {
            return 0f
        }

        val intersection =
            (right - left).toFloat() *
                (bottom - top).toFloat()

        val areaA =
            a.width().coerceAtLeast(1) *
                a.height().coerceAtLeast(1)

        val areaB =
            b.width().coerceAtLeast(1) *
                b.height().coerceAtLeast(1)

        val union =
            areaA +
                areaB -
                intersection

        if (union <= 0f) return 0f

        return intersection / union
    }

    private fun isUsefulObject(
        objectInfo: VisionObject,
    ): Boolean {
        if (
            objectInfo.primaryConfidence <
            MIN_OBJECT_CONFIDENCE
        ) {
            return false
        }

        if (
            objectInfo.primaryLabel
                .isBlank()
        ) {
            return false
        }

        return true
    }

    private fun isUsefulLabel(
        label: String,
    ): Boolean {
        val normalized =
            normalizeLabel(label)

        return normalized.isNotEmpty() &&
            normalized !in GENERIC_LABELS &&
            GENERIC_LABELS.none {
                normalized.contains(it)
            }
    }

    private fun DetectedObject.asVisionObject():
        VisionObject {
        val mappedLabels =
            labels
                .map { label ->
                    VisionLabel(
                        text =
                            cleanLabel(
                                label.text,
                            ),
                        confidence =
                            label.confidence,
                        semanticKind =
                            classifySemantic(
                                label.text,
                            ),
                    )
                }
                .sortedByDescending {
                    it.confidence
                }

        val useful =
            mappedLabels.firstOrNull {
                isUsefulLabel(it.text)
            }

        val best =
            mappedLabels.firstOrNull()

        val chosen =
            useful ?: best

        val hasUseful =
            chosen != null &&
                isUsefulLabel(
                    chosen.text,
                )

        return VisionObject(
            trackingId =
                trackingId ?: -1,
            bounds =
                boundingBox,
            labels =
                mappedLabels
                    .filter {
                        isUsefulLabel(it.text)
                    },
            primaryLabel =
                if (hasUseful) {
                    chosen!!.text
                } else {
                    "Object"
                },
            primaryConfidence =
                if (hasUseful) {
                    chosen!!.confidence
                } else {
                    TRACKING_OBJECT_CONFIDENCE
                },
            semanticKind =
                if (hasUseful) {
                    chosen!!.semanticKind
                } else {
                    SemanticKind.UNKNOWN
                },
        )
    }

    private fun buildEnvironment(
        objects: List<VisionObject>,
        labels: List<VisionLabel>,
    ): SceneEnvironment {
        val kinds =
            (
                objects.map {
                    it.semanticKind
                } +
                    labels.map {
                        it.semanticKind
                    }
                ).toSet()

        return SceneEnvironment(
            hasFloorLikeSurface =
                SemanticKind.FLOOR in kinds,
            hasFurniture =
                SemanticKind.FURNITURE in kinds,
            hasPerson =
                SemanticKind.PERSON in kinds,
            hasVehicle =
                SemanticKind.VEHICLE in kinds,
            hasVegetation =
                SemanticKind.VEGETATION in kinds,
            hasBuildingElement =
                SemanticKind.BUILDING in kinds,
            hasUnknownObjects =
                SemanticKind.UNKNOWN in kinds,
        )
    }

    private fun classifySemantic(
        text: String,
    ): SemanticKind {
        val value =
            normalizeLabel(text)

        return when {
            containsAny(
                value,
                PERSON_WORDS,
            ) ->
                SemanticKind.PERSON

            containsAny(
                value,
                VEHICLE_WORDS,
            ) ->
                SemanticKind.VEHICLE

            containsAny(
                value,
                VEGETATION_WORDS,
            ) ->
                SemanticKind.VEGETATION

            containsAny(
                value,
                FURNITURE_WORDS,
            ) ->
                SemanticKind.FURNITURE

            containsAny(
                value,
                FLOOR_WORDS,
            ) ->
                SemanticKind.FLOOR

            containsAny(
                value,
                BUILDING_WORDS,
            ) ->
                SemanticKind.BUILDING

            else ->
                SemanticKind.UNKNOWN
        }
    }

    private fun containsAny(
        value: String,
        words: Set<String>,
    ): Boolean =
        words.any {
            word ->
            value == word ||
                value.contains(
                    word,
                )
        }

    private fun cleanLabel(
        text: String,
    ): String =
        text
            .trim()
            .lowercase()
            .replace(
                Regex("\\s+"),
                " ",
            )
            .replaceFirstChar {
                it.uppercase()
            }

    private fun normalizeLabel(
        text: String,
    ): String =
        text
            .trim()
            .lowercase()
            .replace(
                Regex("[^a-z0-9\\s]"),
                " ",
            )
            .replace(
                Regex("\\s+"),
                " ",
            )

    private fun logScene(
        scene: VisionScene,
        durationMs: Long,
    ) {
        if (
            scene.objects.isEmpty() &&
            scene.labels.isEmpty()
        ) {
            return
        }

        val objectsSummary =
            scene.objects
                .take(5)
                .joinToString(
                    separator = " | ",
                ) {
                    "${it.primaryLabel}:" +
                        String.format(
                            "%.2f",
                            it.primaryConfidence,
                        ) +
                        ":id=${it.trackingId}"
                }

        val labelsSummary =
            scene.labels
                .take(6)
                .joinToString(
                    separator = ", ",
                ) {
                    "${it.text}:${String.format("%.2f", it.confidence)}"
                }

        Log.d(
            TAG,
            "SCENE duration=${durationMs}ms " +
                "objects=${scene.objects.size} " +
                "[$objectsSummary] " +
                "labels=${scene.labels.size} " +
                "[$labelsSummary]",
        )
    }

    private fun calculateRotationDegrees():
        Int {
        val cameraManager =
            appContext.getSystemService(
                Context.CAMERA_SERVICE,
            ) as CameraManager

        val cameraId =
            cameraManager
                .cameraIdList
                .firstOrNull { id ->
                    val characteristics =
                        cameraManager
                            .getCameraCharacteristics(id)

                    characteristics.get(
                        CameraCharacteristics.LENS_FACING,
                    ) ==
                        CameraCharacteristics.LENS_FACING_BACK
                }
                ?: cameraManager
                    .cameraIdList
                    .first()

        val characteristics =
            cameraManager
                .getCameraCharacteristics(
                    cameraId,
                )

        val sensorOrientation =
            characteristics.get(
                CameraCharacteristics.SENSOR_ORIENTATION,
            ) ?: 90

        val displayRotation =
            try {
                val windowManager =
                    appContext.getSystemService(
                        Context.WINDOW_SERVICE,
                    ) as WindowManager

                when (
                    windowManager
                        .defaultDisplay
                        .rotation
                ) {
                    Surface.ROTATION_0 -> 0
                    Surface.ROTATION_90 -> 90
                    Surface.ROTATION_180 -> 180
                    Surface.ROTATION_270 -> 270
                    else -> 0
                }
            } catch (_: Throwable) {
                0
            }

        return (
            sensorOrientation -
                displayRotation +
                360
            ) % 360
    }

    private data class StableObjectState(
        val key: String,
        var last: VisionObject,
        var hits: Int,
        var lastSeenMs: Long,
        var pendingLabel: String? = null,
        var pendingLabelHits: Int = 0,
    )
}

private const val TRACKING_OBJECT_CONFIDENCE = 0.60f

enum class SemanticKind {
    UNKNOWN,
    FLOOR,
    FURNITURE,
    PERSON,
    VEHICLE,
    VEGETATION,
    BUILDING,
}

data class VisionScene(
    val timestampNanos: Long,
    val objects: List<VisionObject>,
    val labels: List<VisionLabel>,
    val environment: SceneEnvironment,
) {
    companion object {
        fun empty():
            VisionScene =
            VisionScene(
                timestampNanos = 0L,
                objects = emptyList(),
                labels = emptyList(),
                environment = SceneEnvironment(),
            )
    }
}

data class VisionObject(
    val trackingId: Int,
    val bounds: Rect,
    val labels: List<VisionLabel>,
    val primaryLabel: String = "unknown",
    val primaryConfidence: Float = 0f,
    val semanticKind: SemanticKind =
        SemanticKind.UNKNOWN,
)

data class VisionLabel(
    val text: String,
    val confidence: Float,
    val semanticKind: SemanticKind =
        SemanticKind.UNKNOWN,
)

data class SceneEnvironment(
    val hasFloorLikeSurface: Boolean = false,
    val hasFurniture: Boolean = false,
    val hasPerson: Boolean = false,
    val hasVehicle: Boolean = false,
    val hasVegetation: Boolean = false,
    val hasBuildingElement: Boolean = false,
    val hasUnknownObjects: Boolean = false,
)
