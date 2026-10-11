package com.example.meta_zone.ar

import android.content.Context
import android.opengl.GLES11Ext
import android.opengl.GLES20
import android.opengl.Matrix
import android.util.Log
import android.media.Image
import com.google.ar.core.Coordinates2d
import com.google.ar.core.Frame
import com.google.ar.core.Plane
import com.google.ar.core.Pose
import com.google.ar.core.Session
import com.google.ar.core.TrackingState
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.FloatBuffer
import javax.microedition.khronos.egl.EGLConfig
import javax.microedition.khronos.opengles.GL10

class NativeArRenderer(
    context: Context,
    private val onError: (String) -> Unit,
    private val visionMode: Boolean = false,
) : android.opengl.GLSurfaceView.Renderer {

    companion object {
        private const val TAG = "MetaZoneNativeAR"

        private const val CAMERA_VERTEX_SHADER = """
            attribute vec4 aPosition;
            attribute vec2 aTexCoord;

            varying vec2 vTexCoord;

            void main() {
                gl_Position = aPosition;
                vTexCoord = aTexCoord;
            }
        """

        private const val CAMERA_FRAGMENT_SHADER = """
            #extension GL_OES_EGL_image_external : require

            precision highp float;

            uniform samplerExternalOES uTexture;

            varying vec2 vTexCoord;

            void main() {
                gl_FragColor = texture2D(
                    uTexture,
                    vTexCoord
                );
            }
        """

        private const val DEPTH_DIAGNOSTIC_VERTEX_SHADER = """
            attribute vec4 aPosition;

            varying vec2 vNdc;

            void main() {
                gl_Position = aPosition;
                vNdc = aPosition.xy;
            }
        """

        private const val DEPTH_DIAGNOSTIC_FRAGMENT_SHADER = """
            precision highp float;

            uniform sampler2D uDepthTexture;
            uniform mat3 uDepthUvTransform;
            uniform float uNearMeters;
            uniform float uFarMeters;

            varying vec2 vNdc;

            float getDepthMeters(vec2 uv) {
                vec2 depthBytes = texture2D(
                    uDepthTexture,
                    clamp(uv, 0.001, 0.999)
                ).rg;

                float millimeters = dot(
                    depthBytes,
                    vec2(255.0, 256.0 * 255.0)
                );

                return millimeters * 0.001;
            }

            vec3 depthColor(float depthMeters) {
                float t = clamp(
                    (depthMeters - uNearMeters) /
                    max(uFarMeters - uNearMeters, 0.001),
                    0.0,
                    1.0
                );

                // Near = red/orange, middle = green, far = blue.
                float r = 1.0 - smoothstep(0.0, 0.50, t);
                float g = 1.0 - abs(t * 2.0 - 1.0);
                float b = smoothstep(0.35, 1.0, t);

                return vec3(r, g, b);
            }

            void main() {
                vec2 depthUv = (
                    uDepthUvTransform *
                    vec3(vNdc, 1.0)
                ).xy;

                if (
                    depthUv.x < 0.0 || depthUv.x > 1.0 ||
                    depthUv.y < 0.0 || depthUv.y > 1.0
                ) {
                    discard;
                }

                float depthMeters = getDepthMeters(depthUv);

                // Packed zero is our invalid-depth marker.
                if (depthMeters <= 0.001) {
                    discard;
                }

                gl_FragColor = vec4(
                    depthColor(depthMeters),
                    0.58
                );
            }
        """

        private const val OBJECT_VERTEX_SHADER = """
            uniform mat4 uMvpMatrix;
            uniform mat4 uModelMatrix;
            uniform mat4 uViewMatrix;

            attribute vec4 aPosition;
            attribute vec3 aNormal;

            varying vec3 vWorldNormal;
            varying vec3 vWorldPosition;
            varying vec3 vViewPosition;
            varying vec3 vScreenSpacePosition;

            void main() {
                vec4 worldPosition = uModelMatrix * aPosition;
                vec4 viewPosition = uViewMatrix * worldPosition;

                vWorldPosition = worldPosition.xyz;
                vWorldNormal = normalize(mat3(uModelMatrix) * aNormal);
                vViewPosition = viewPosition.xyz;

                gl_Position = uMvpMatrix * aPosition;
                vScreenSpacePosition = gl_Position.xyz / gl_Position.w;
            }
        """

        private const val OBJECT_FRAGMENT_SHADER = """
            precision highp float;

            uniform vec4 uColor;
            uniform float uLightIntensity;
            uniform vec3 uLightDirection;
            uniform vec3 uLightColor;
            uniform vec3 uViewPosition;

            uniform sampler2D uDepthTexture;
            uniform mat3 uDepthUvTransform;
            uniform float uDepthOcclusionEnabled;
            uniform float uDepthTolerancePerMm;
            uniform float uOcclusionAlpha;

            varying vec3 vWorldNormal;
            varying vec3 vWorldPosition;
            varying vec3 vViewPosition;
            varying vec3 vScreenSpacePosition;

            float getDepthMillimeters(vec2 depthUv) {
                vec2 packedDepth =
                    texture2D(
                        uDepthTexture,
                        clamp(depthUv, 0.001, 0.999)
                    ).rg;

                return dot(
                    packedDepth,
                    vec2(255.0, 256.0 * 255.0)
                );
            }

            float getVisibility(
                vec2 depthUv,
                float assetDepthMm
            ) {
                if (uDepthOcclusionEnabled < 0.5) {
                    return 1.0;
                }

                float depthMm = getDepthMillimeters(depthUv);

                // Zero means ARCore does not currently have a valid depth
                // estimate for this pixel. In that case we must not hide the
                // virtual object.
                if (depthMm <= 1.0) {
                    return 1.0;
                }

                // ARCore depth is measured along the camera principal axis.
                // The virtual depth below uses the same camera-space Z axis.
                // Keep only a small tolerance for sensor/render quantization.
                float tolerance = max(
                    uDepthTolerancePerMm * max(assetDepthMm, 1.0),
                    6.0
                );

                // Real surface is closer to the camera than this virtual
                // fragment -> this pixel of the AR object must disappear.
                if (depthMm + tolerance < assetDepthMm) {
                    return 0.0;
                }

                return 1.0;
            }

            void main() {
                const float kMetersToMillimeters = 1000.0;

                float assetDepthMm =
                    -vViewPosition.z *
                    kMetersToMillimeters;

                vec2 depthUv =
                    (
                        uDepthUvTransform *
                        vec3(
                            vScreenSpacePosition.xy,
                            1.0
                        )
                    ).xy;

                float visibility =
                    getVisibility(
                        depthUv,
                        assetDepthMm
                    );

                if (visibility <= 0.001) {
                    discard;
                }

                vec3 normal = normalize(vWorldNormal);
                vec3 lightDir = normalize(-uLightDirection);
                vec3 viewDir =
                    normalize(
                        uViewPosition -
                        vWorldPosition
                    );
                vec3 halfDir =
                    normalize(
                        lightDir +
                        viewDir
                    );

                float diffuse =
                    max(
                        dot(normal, lightDir),
                        0.0
                    );

                float specular =
                    pow(
                        max(
                            dot(normal, halfDir),
                            0.0
                        ),
                        32.0
                    );

                float ambient =
                    0.34 +
                    0.18 *
                    clamp(
                        uLightIntensity,
                        0.35,
                        2.0
                    );

                float direct =
                    0.52 *
                    diffuse *
                    clamp(
                        uLightIntensity,
                        0.45,
                        2.2
                    );

                vec3 litColor =
                    uColor.rgb *
                    ambient;

                litColor +=
                    uColor.rgb *
                    direct *
                    uLightColor;

                litColor +=
                    uLightColor *
                    (0.10 * specular);

                float fresnel =
                    pow(
                        1.0 -
                            max(
                                dot(normal, viewDir),
                                0.0
                            ),
                        3.0
                    );

                litColor +=
                    uColor.rgb *
                    fresnel *
                    0.06;

                gl_FragColor =
                    vec4(
                        clamp(
                            litColor,
                            0.0,
                            1.0
                        ),
                        uColor.a *
                        visibility
                    );
            }
        """

        private const val SHADOW_VERTEX_SHADER = """
            uniform mat4 uMvpMatrix;

            attribute vec4 aPosition;

            varying vec2 vShadowUv;

            void main() {
                vShadowUv = aPosition.xz * 0.5 + 0.5;
                gl_Position = uMvpMatrix * aPosition;
            }
        """

        private const val SHADOW_FRAGMENT_SHADER = """
            precision mediump float;

            uniform float uShadowStrength;
            uniform vec2 uShadowCenter;

            varying vec2 vShadowUv;

            void main() {
                vec2 p = (vShadowUv - uShadowCenter) * 2.0;
                float d = dot(p, p);
                float softness = smoothstep(1.0, 0.18, d);
                float core = smoothstep(0.72, 0.02, d);
                float alpha = (softness * 0.55 + core * 0.45) * uShadowStrength;
                gl_FragColor = vec4(0.015, 0.02, 0.04, alpha);
            }
        """

        private const val DRAW_PLANE_DEBUG = false
        private const val HIT_TEST_INTERVAL_MS = 250L
        private const val DEPTH_SAMPLE_INTERVAL_MS = 50L
        private const val PLANE_SCAN_INTERVAL_MS = 700L
        private const val RETICLE_RADIUS_METERS = 0.065f
        private const val VISION_PROJECTION_INTERVAL_MS = 33L

        // Temporary visual diagnostic mode. This deliberately shows the live depth
        // map over the camera so we can verify registration before re-enabling
        // the final per-pixel AR occlusion renderer.
        private const val DEFAULT_DEPTH_DIAGNOSTIC_MODE = true

        private const val DEPTH_GRID_SIZE = 7
        private const val DEPTH_MIN_MM = 180
        private const val DEPTH_MAX_MM = 15000
        private const val DEPTH_MIN_VALID_RATIO = 0.35f
        private const val DEPTH_TEXTURE_UPDATE_INTERVAL_MS = 50L
        private const val DEPTH_OCCLUSION_BIAS_METERS = 0.018f
    }

    private val depthDiagnosticMode =
        if (visionMode) {
            false
        } else {
            DEFAULT_DEPTH_DIAGNOSTIC_MODE
        }

    @Volatile
    private var session: Session? = null

    @Volatile
    private var pendingTapX = -1f

    @Volatile
    private var pendingTapY = -1f

    private var cameraTextureId = -1
    private var cameraProgram = 0
    private var cameraTextureBoundToSession = false

    private var cameraPositionHandle = -1
    private var cameraTexCoordHandle = -1
    private var cameraTextureHandle = -1

    private var depthDiagnosticProgram = 0
    private var depthDiagnosticPositionHandle = -1
    private var depthDiagnosticTextureHandle = -1
    private var depthDiagnosticUvTransformHandle = -1
    private var depthDiagnosticNearHandle = -1
    private var depthDiagnosticFarHandle = -1

    private var objectProgram = 0
    private var objectPositionHandle = -1
    private var objectNormalHandle = -1
    private var objectMvpHandle = -1
    private var objectModelHandle = -1
    private var objectColorHandle = -1
    private var objectLightIntensityHandle = -1
    private var objectLightDirectionHandle = -1
    private var objectLightColorHandle = -1
    private var objectViewPositionHandle = -1
    private var objectViewMatrixHandle = -1
    private var objectDepthTextureHandle = -1
    private var objectDepthOcclusionEnabledHandle = -1
    private var objectDepthUvTransformHandle = -1
    private var objectDepthToleranceHandle = -1
    private var objectOcclusionAlphaHandle = -1

    private var depthTextureId = 0
    private var depthTextureWidth = 0
    private var depthTextureHeight = 0
    private var depthTextureReady = false
    private var depthOcclusionTransformReady = false
    private var lastDepthTextureUploadMs = 0L
    private var lastDepthDiagnosticLogMs = 0L
    private var depthTextureBuffer: ByteBuffer? = null

    /*
     * Screen-space mapping from ARCore OpenGL NDC coordinates to the
     * current depth texture coordinates.
     *
     * These were accidentally omitted from the previous generated file,
     * which caused the Kotlin compile errors you just saw.
     */
    private val depthNdcBasis =
        floatArrayOf(
            0f, 0f,
            1f, 0f,
            0f, 1f,
        )

    private val depthTextureBasis =
        FloatArray(6)

    private val depthUvTransform =
        FloatArray(9)

    private var objectAnchor: com.google.ar.core.Anchor? = null

    // Ultra-stable visual pose layer. ARCore remains the source of truth for
    // the anchor, while this layer suppresses single-frame micro-jitter and
    // rejects implausible sudden pose jumps.
    private var stableAnchorPose: Pose? = null
    private var lastStableAnchorUpdateMs = 0L
    private var anchorLostSinceMs = 0L
    private var anchorOutlierCount = 0
    private var anchorStableFrames = 0
    private var hasDetectedPlane = false
    private var lastPlaneCount = -1

    private var surfaceWidth = 0
    private var surfaceHeight = 0

    private var reticlePose: Pose? = null
    private var reticleVisible = false

    @Volatile
    private var depthReady = false

    @Volatile
    private var latestSpatialSnapshot: SpatialSnapshot? = null

    @Volatile
    private var latestFusedScene: FusedSceneSnapshot? = null

    /*
     * Projection cache used by Flutter.
     *
     * MetaZoneVisionEngine reports detections in CPU-image coordinates.
     * ARCore owns the authoritative IMAGE_PIXELS -> VIEW transform, so we
     * project the latest scene on the render thread and cache the result.
     * Flutter then receives screen-space coordinates that line up with the
     * actual AR view instead of guessing with width/height scaling.
     */
    @Volatile
    private var latestProjectedVisionObjects: List<ProjectedVisionObject> =
        emptyList()

    @Volatile
    private var latestFusedObjectById: Map<Int, FusedObject> =
        emptyMap()

    @Volatile
    private var latestVisionProjectionTimestampNs = 0L

    @Volatile
    private var latestVisionTrackingState = "UNAVAILABLE"

    private var lastVisionProjectionMs = 0L
    private var lastSpatialFusionMs = 0L
    private var lastDepthSampleMs = 0L
    private var lastHitTestMs = 0L
    private var lastPlaneScanMs = 0L

    private val visionEngine =
        MetaZoneVisionEngine(
            context = context,
            onResult = { scene ->
                if (scene.objects.isNotEmpty()) {
                    scene.objects.forEach { objectInfo ->
                        val labels = objectInfo.labels.joinToString { it.text }
                        Log.d(
                            TAG,
                            "VISION OBJECT id=${objectInfo.trackingId} labels=[$labels] bounds=${objectInfo.bounds}",
                        )
                    }
                }

                if (scene.labels.isNotEmpty()) {
                    val labels = scene.labels.joinToString {
                        "${it.text}:${"%.2f".format(it.confidence)}"
                    }
                    Log.d(TAG, "VISION LABELS [$labels]")
                }
            },
            onError = { message, error ->
                if (error != null) {
                    Log.w(TAG, message, error)
                } else {
                    Log.w(TAG, message)
                }
            },
        )

    private var planeVerticesArray = FloatArray(0)
    private var planeVertexBuffer: FloatBuffer? = null

    private val quad =
        floatBuffer(
            floatArrayOf(
                -1f, -1f,
                 1f, -1f,
                -1f,  1f,
                 1f,  1f,
            ),
        )

    private val texCoords =
        floatBuffer(
            FloatArray(8),
        )

    private val ndcCoords =
        floatArrayOf(
            -1f, -1f,
             1f, -1f,
            -1f,  1f,
             1f,  1f,
        )

    private val transformedTexCoords =
        FloatArray(8)

    private val viewMatrix =
        FloatArray(16)

    private val projectionMatrix =
        FloatArray(16)

    private val modelMatrix =
        FloatArray(16)

    private val mvpMatrix =
        FloatArray(16)

    private val lightDirection =
        floatArrayOf(0.45f, -0.85f, 0.35f)

    private val lightColor =
        floatArrayOf(1.0f, 1.0f, 1.0f)

    private val viewPosition =
        FloatArray(3)

    private var latestLightIntensity = 1.0f
    private var latestMainLightIntensity = 1.0f

    private val cubeVertices =
        floatBuffer(
            floatArrayOf(
                -0.05f, -0.05f,  0.05f,
                 0.05f, -0.05f,  0.05f,
                 0.05f,  0.05f,  0.05f,

                -0.05f, -0.05f,  0.05f,
                 0.05f,  0.05f,  0.05f,
                -0.05f,  0.05f,  0.05f,

                -0.05f, -0.05f, -0.05f,
                -0.05f,  0.05f, -0.05f,
                 0.05f,  0.05f, -0.05f,

                -0.05f, -0.05f, -0.05f,
                 0.05f,  0.05f, -0.05f,
                 0.05f, -0.05f, -0.05f,

                -0.05f, -0.05f, -0.05f,
                -0.05f, -0.05f,  0.05f,
                -0.05f,  0.05f,  0.05f,

                -0.05f, -0.05f, -0.05f,
                -0.05f,  0.05f,  0.05f,
                -0.05f,  0.05f, -0.05f,

                 0.05f, -0.05f, -0.05f,
                 0.05f,  0.05f, -0.05f,
                 0.05f,  0.05f,  0.05f,

                 0.05f, -0.05f, -0.05f,
                 0.05f,  0.05f,  0.05f,
                 0.05f, -0.05f,  0.05f,

                -0.05f,  0.05f,  0.05f,
                 0.05f,  0.05f,  0.05f,
                 0.05f,  0.05f, -0.05f,

                -0.05f,  0.05f,  0.05f,
                 0.05f,  0.05f, -0.05f,
                -0.05f,  0.05f, -0.05f,

                -0.05f, -0.05f,  0.05f,
                -0.05f, -0.05f, -0.05f,
                 0.05f, -0.05f, -0.05f,

                -0.05f, -0.05f,  0.05f,
                 0.05f, -0.05f, -0.05f,
                 0.05f, -0.05f,  0.05f,
            ),
        )

    private val cubeNormals =
        floatBuffer(
            floatArrayOf(
                0f, 0f, 1f,
                0f, 0f, 1f,
                0f, 0f, 1f,
                0f, 0f, 1f,
                0f, 0f, 1f,
                0f, 0f, 1f,

                0f, 0f, -1f,
                0f, 0f, -1f,
                0f, 0f, -1f,
                0f, 0f, -1f,
                0f, 0f, -1f,
                0f, 0f, -1f,

                -1f, 0f, 0f,
                -1f, 0f, 0f,
                -1f, 0f, 0f,
                -1f, 0f, 0f,
                -1f, 0f, 0f,
                -1f, 0f, 0f,

                1f, 0f, 0f,
                1f, 0f, 0f,
                1f, 0f, 0f,
                1f, 0f, 0f,
                1f, 0f, 0f,
                1f, 0f, 0f,

                0f, 1f, 0f,
                0f, 1f, 0f,
                0f, 1f, 0f,
                0f, 1f, 0f,
                0f, 1f, 0f,
                0f, 1f, 0f,

                0f, -1f, 0f,
                0f, -1f, 0f,
                0f, -1f, 0f,
                0f, -1f, 0f,
                0f, -1f, 0f,
                0f, -1f, 0f,
            ),
        )

    private val shadowVertices =
        floatBuffer(
            floatArrayOf(
                -0.10f, 0.001f, -0.055f,
                 0.10f, 0.001f, -0.055f,
                -0.10f, 0.001f,  0.055f,
                 0.10f, 0.001f,  0.055f,
            ),
        )

    private val reticleVertices = createReticleVertices()

    fun attachSession(newSession: Session) {
        session = newSession
        cameraTextureBoundToSession = false
        hasDetectedPlane = false
        lastPlaneCount = -1
        pendingTapX = -1f
        pendingTapY = -1f
        reticlePose = null
        reticleVisible = false
        depthReady = false
        depthTextureReady = false
        depthOcclusionTransformReady = false
        depthTextureWidth = 0
        depthTextureHeight = 0
        lastDepthTextureUploadMs = 0L
        lastDepthDiagnosticLogMs = 0L
        depthTextureBuffer = null
        latestSpatialSnapshot = null
        latestFusedScene = null
        latestProjectedVisionObjects = emptyList()
        latestFusedObjectById = emptyMap()
        latestVisionProjectionTimestampNs = 0L
        latestVisionTrackingState = "UNAVAILABLE"
        lastVisionProjectionMs = 0L
        lastSpatialFusionMs = 0L
        lastDepthSampleMs = 0L
        lastHitTestMs = 0L
        lastPlaneScanMs = 0L

        objectAnchor?.detach()
        objectAnchor = null

        Log.d(TAG, "AR session attached to renderer")
    }

    fun clearSession() {
        objectAnchor?.detach()
        objectAnchor = null
        resetAnchorStabilizer()

        session = null
        cameraTextureBoundToSession = false
        hasDetectedPlane = false
        lastPlaneCount = -1
        pendingTapX = -1f
        pendingTapY = -1f
        reticlePose = null
        reticleVisible = false
        depthReady = false
        depthTextureReady = false
        depthOcclusionTransformReady = false
        depthTextureWidth = 0
        depthTextureHeight = 0
        lastDepthTextureUploadMs = 0L
        lastDepthDiagnosticLogMs = 0L
        depthTextureBuffer = null
        latestSpatialSnapshot = null
        latestFusedScene = null
        latestProjectedVisionObjects = emptyList()
        latestFusedObjectById = emptyMap()
        latestVisionProjectionTimestampNs = 0L
        latestVisionTrackingState = "UNAVAILABLE"
        lastVisionProjectionMs = 0L
        lastSpatialFusionMs = 0L
        lastDepthSampleMs = 0L
        lastHitTestMs = 0L
        lastPlaneScanMs = 0L
    }

    fun latestSpatialSnapshot(): SpatialSnapshot? = latestSpatialSnapshot

    fun latestFusedScene(): FusedSceneSnapshot? = latestFusedScene

    /**
     * Returns the latest VisionScene in a StandardMessageCodec-safe shape.
     *
     * This is a read-only snapshot. It never acquires a camera image, launches
     * ML work, or waits for the render thread. MetaZoneVisionEngine keeps its
     * latest scene volatile, so Flutter can poll this bridge safely.
     */
    fun latestVisionSnapshot(): Map<String, Any> {
        val nowNs = System.nanoTime()
        val projected = latestProjectedVisionObjects

        val objects = projected.map { projectedObject ->
            val spatial =
                if (projectedObject.trackingId >= 0) {
                    latestFusedObjectById[projectedObject.trackingId]
                } else {
                    null
                }

            val objectMap =
                linkedMapOf<String, Any>(
                    "trackingId" to projectedObject.trackingId,
                    "primaryLabel" to projectedObject.primaryLabel,
                    "confidence" to projectedObject.confidence.toDouble(),
                    "semanticKind" to projectedObject.semanticKind.name,
                    "bounds" to
                        mapOf<String, Any>(
                            "left" to projectedObject.left.toDouble(),
                            "top" to projectedObject.top.toDouble(),
                            "right" to projectedObject.right.toDouble(),
                            "bottom" to projectedObject.bottom.toDouble(),
                            "width" to projectedObject.width.toDouble(),
                            "height" to projectedObject.height.toDouble(),
                        ),
                    "center" to
                        mapOf<String, Any>(
                            "x" to projectedObject.centerX.toDouble(),
                            "y" to projectedObject.centerY.toDouble(),
                        ),
                )

            if (spatial != null) {
                objectMap["spatiallyTracked"] = true
                objectMap["distanceMeters"] = spatial.depthMeters.toDouble()
                objectMap["spatialConfidence"] = spatial.confidence.toDouble()
                objectMap["worldPosition"] =
                    mapOf<String, Any>(
                        "x" to spatial.worldX.toDouble(),
                        "y" to spatial.worldY.toDouble(),
                        "z" to spatial.worldZ.toDouble(),
                    )
                objectMap["estimatedSizeMeters"] =
                    mapOf<String, Any>(
                        "width" to spatial.estimatedWidthMeters.toDouble(),
                        "height" to spatial.estimatedHeightMeters.toDouble(),
                        "depth" to spatial.estimatedDepthMeters.toDouble(),
                    )
            } else {
                objectMap["spatiallyTracked"] = false
            }

            objectMap
        }

        val timestampNs = latestVisionProjectionTimestampNs
        val ageMs =
            if (timestampNs <= 0L) {
                -1L
            } else {
                ((nowNs - timestampNs).coerceAtLeast(0L)) / 1_000_000L
            }

        val scene = visionEngine.latestScene()

        val labels =
            scene.labels.map { label ->
                mapOf<String, Any>(
                    "text" to label.text,
                    "confidence" to label.confidence.toDouble(),
                    "semanticKind" to label.semanticKind.name,
                )
            }

        val environment =
            mapOf<String, Any>(
                "hasFloorLikeSurface" to
                    scene.environment.hasFloorLikeSurface,
                "hasFurniture" to
                    scene.environment.hasFurniture,
                "hasPerson" to
                    scene.environment.hasPerson,
                "hasVehicle" to
                    scene.environment.hasVehicle,
                "hasVegetation" to
                    scene.environment.hasVegetation,
                "hasBuildingElement" to
                    scene.environment.hasBuildingElement,
                "hasUnknownObjects" to
                    scene.environment.hasUnknownObjects,
            )

        return linkedMapOf(
            "timestampNanos" to timestampNs,
            "ageMs" to ageMs,
            "isLive" to (ageMs >= 0L && ageMs <= 750L),
            "trackingState" to latestVisionTrackingState,
            "depthReady" to depthReady,
            "spatialObjectCount" to latestFusedObjectById.size,
            "objectCount" to objects.size,
            "objects" to objects,
            "labels" to labels,
            "environment" to environment,
        )
    }

    /**
     * Resolves a Vision detection using the same screen-space coordinates
     * that are sent to Flutter.
     *
     * This is intentionally read-only and does not trigger ML or hit-testing.
     */
    fun selectVisionObject(
        x: Float,
        y: Float,
    ): Map<String, Any>? {
        val selected =
            latestProjectedVisionObjects
                .asSequence()
                .filter { projected ->
                    x >= projected.left &&
                        x <= projected.right &&
                        y >= projected.top &&
                        y <= projected.bottom
                }
                .sortedWith(
                    compareBy<ProjectedVisionObject> {
                        it.area
                    }.thenByDescending {
                        it.confidence
                    },
                )
                .firstOrNull()
                ?: return null

        val spatial =
            if (selected.trackingId >= 0) {
                latestFusedObjectById[selected.trackingId]
            } else {
                null
            }

        val result =
            linkedMapOf<String, Any>(
                "trackingId" to selected.trackingId,
                "primaryLabel" to selected.primaryLabel,
                "confidence" to selected.confidence.toDouble(),
                "semanticKind" to selected.semanticKind.name,
                "bounds" to
                    mapOf<String, Any>(
                        "left" to selected.left.toDouble(),
                        "top" to selected.top.toDouble(),
                        "right" to selected.right.toDouble(),
                        "bottom" to selected.bottom.toDouble(),
                    ),
            )

        if (spatial != null) {
            result["spatiallyTracked"] = true
            result["distanceMeters"] = spatial.depthMeters.toDouble()
            result["spatialConfidence"] = spatial.confidence.toDouble()
            result["worldPosition"] =
                mapOf<String, Any>(
                    "x" to spatial.worldX.toDouble(),
                    "y" to spatial.worldY.toDouble(),
                    "z" to spatial.worldZ.toDouble(),
                )
        } else {
            result["spatiallyTracked"] = false
        }

        return result
    }

    fun requestPlacement(x: Float, y: Float) {
        // Sense/Vision is not a placement mode. Ignore placement requests
        // completely so an AR Camera interaction cannot leak into Vision.
        if (visionMode) {
            return
        }

        pendingTapX = x
        pendingTapY = y
    }

    override fun onSurfaceCreated(
        gl: GL10?,
        config: EGLConfig?,
    ) {
        try {
            GLES20.glClearColor(0f, 0f, 0f, 1f)
            GLES20.glDisable(GLES20.GL_CULL_FACE)
            GLES20.glEnable(GLES20.GL_BLEND)
            GLES20.glBlendFunc(
                GLES20.GL_SRC_ALPHA,
                GLES20.GL_ONE_MINUS_SRC_ALPHA,
            )

            cameraTextureId = createExternalTexture()
            cameraTextureBoundToSession = false
            depthTextureId = createDepthTexture()
            depthTextureReady = false
            depthTextureWidth = 0
            depthTextureHeight = 0
            lastDepthTextureUploadMs = 0L

            cameraProgram =
                createProgram(
                    CAMERA_VERTEX_SHADER,
                    CAMERA_FRAGMENT_SHADER,
                )

            cameraPositionHandle =
                GLES20.glGetAttribLocation(
                    cameraProgram,
                    "aPosition",
                )

            cameraTexCoordHandle =
                GLES20.glGetAttribLocation(
                    cameraProgram,
                    "aTexCoord",
                )

            cameraTextureHandle =
                GLES20.glGetUniformLocation(
                    cameraProgram,
                    "uTexture",
                )

            depthDiagnosticProgram =
                createProgram(
                    DEPTH_DIAGNOSTIC_VERTEX_SHADER,
                    DEPTH_DIAGNOSTIC_FRAGMENT_SHADER,
                )

            depthDiagnosticPositionHandle =
                GLES20.glGetAttribLocation(
                    depthDiagnosticProgram,
                    "aPosition",
                )

            depthDiagnosticTextureHandle =
                GLES20.glGetUniformLocation(
                    depthDiagnosticProgram,
                    "uDepthTexture",
                )

            depthDiagnosticUvTransformHandle =
                GLES20.glGetUniformLocation(
                    depthDiagnosticProgram,
                    "uDepthUvTransform",
                )

            depthDiagnosticNearHandle =
                GLES20.glGetUniformLocation(
                    depthDiagnosticProgram,
                    "uNearMeters",
                )

            depthDiagnosticFarHandle =
                GLES20.glGetUniformLocation(
                    depthDiagnosticProgram,
                    "uFarMeters",
                )

            objectProgram =
                createProgram(
                    OBJECT_VERTEX_SHADER,
                    OBJECT_FRAGMENT_SHADER,
                )

            objectPositionHandle =
                GLES20.glGetAttribLocation(
                    objectProgram,
                    "aPosition",
                )

            objectMvpHandle =
                GLES20.glGetUniformLocation(
                    objectProgram,
                    "uMvpMatrix",
                )

            objectColorHandle =
                GLES20.glGetUniformLocation(
                    objectProgram,
                    "uColor",
                )

            objectNormalHandle =
                GLES20.glGetAttribLocation(
                    objectProgram,
                    "aNormal",
                )

            objectModelHandle =
                GLES20.glGetUniformLocation(
                    objectProgram,
                    "uModelMatrix",
                )

            objectLightIntensityHandle =
                GLES20.glGetUniformLocation(
                    objectProgram,
                    "uLightIntensity",
                )

            objectLightDirectionHandle =
                GLES20.glGetUniformLocation(
                    objectProgram,
                    "uLightDirection",
                )

            objectLightColorHandle =
                GLES20.glGetUniformLocation(
                    objectProgram,
                    "uLightColor",
                )

            objectViewPositionHandle =
                GLES20.glGetUniformLocation(
                    objectProgram,
                    "uViewPosition",
                )

            objectViewMatrixHandle =
                GLES20.glGetUniformLocation(
                    objectProgram,
                    "uViewMatrix",
                )

            objectDepthTextureHandle =
                GLES20.glGetUniformLocation(
                    objectProgram,
                    "uDepthTexture",
                )

            objectDepthOcclusionEnabledHandle =
                GLES20.glGetUniformLocation(
                    objectProgram,
                    "uDepthOcclusionEnabled",
                )




            objectDepthUvTransformHandle =
                GLES20.glGetUniformLocation(
                    objectProgram,
                    "uDepthUvTransform",
                )
            objectDepthToleranceHandle =
                GLES20.glGetUniformLocation(
                    objectProgram,
                    "uDepthTolerancePerMm",
                )

            objectOcclusionAlphaHandle =
                GLES20.glGetUniformLocation(
                    objectProgram,
                    "uOcclusionAlpha",
                )


            checkGlError("onSurfaceCreated")

            Log.d(TAG, "OpenGL renderer initialized — DEPTH DIAGNOSTIC MODE=${depthDiagnosticMode}")
        } catch (t: Throwable) {
            onError(
                "OpenGL initialization failed: ${t.message}",
            )
        }
    }

    override fun onSurfaceChanged(
        gl: GL10?,
        width: Int,
        height: Int,
    ) {
        surfaceWidth = width
        surfaceHeight = height
        GLES20.glViewport(0, 0, width, height)
        checkGlError("onSurfaceChanged")
    }

    override fun onDrawFrame(gl: GL10?) {
        GLES20.glClear(
            GLES20.GL_COLOR_BUFFER_BIT or GLES20.GL_DEPTH_BUFFER_BIT,
        )

        val currentSession = session ?: return

        try {
            if (!cameraTextureBoundToSession) {
                currentSession.setCameraTextureName(cameraTextureId)
                cameraTextureBoundToSession = true
            }

            val frame = currentSession.update()
            updateEnvironmentalLighting(frame)

            val nowMs = android.os.SystemClock.uptimeMillis()

            // Diagnostic mode intentionally removes the ML/Vision workload.
            // We only need the ARCore frame and the live Depth API feed while
            // diagnosing the depth-to-screen registration.
            if (!depthDiagnosticMode &&
                nowMs - lastPlaneScanMs >= PLANE_SCAN_INTERVAL_MS
            ) {
                lastPlaneScanMs = nowMs
                detectPlanes(currentSession)
            }

            sampleSpatialDepth(frame, nowMs)
            updateDepthUvTransform(frame)

            if (!depthDiagnosticMode) {
                /*
                 * Vision/Sense and AR Camera share the same native camera
                 * substrate, but their user experiences are deliberately
                 * isolated.
                 *
                 * Sense/Vision:
                 *   - runs perception + projection + spatial understanding
                 *   - NEVER runs placement/reticle interaction
                 *
                 * AR Camera:
                 *   - keeps the normal reticle + placement pipeline
                 */
                visionEngine.analyze(frame)
                updateVisionProjection(frame, nowMs)
                updateSpatialFusion(frame, nowMs)

                if (!visionMode) {
                    updateReticle(frame, nowMs)
                    processPendingTap(frame)
                } else {
                    // Hard safety boundary: Vision never carries AR placement
                    // state or interaction visuals.
                    reticleVisible = false
                    reticlePose = null
                    pendingTapX = -1f
                    pendingTapY = -1f
                }
            }

            updateTextureCoordinates(frame)
            drawCamera()

            if (depthDiagnosticMode) {
                drawDepthDiagnosticOverlay()
            } else if (!visionMode) {
                /*
                 * AR-only visuals.
                 *
                 * These are intentionally excluded from Sense/Vision:
                 *   - detected plane debug geometry
                 *   - placement reticle
                 *   - placed AR object / anchor rendering
                 */
                if (DRAW_PLANE_DEBUG) {
                    drawDetectedPlanes(currentSession, frame)
                }
                drawReticle(frame)
                drawPlacedObject(frame)
            }
        } catch (t: Throwable) {
            onError(
                "AR frame error: ${t.message}",
            )
        }
    }

    private fun sampleSpatialDepth(
        frame: Frame,
        nowMs: Long,
    ) {
        if (nowMs - lastDepthSampleMs < DEPTH_SAMPLE_INTERVAL_MS) {
            return
        }

        lastDepthSampleMs = nowMs

        if (frame.camera.trackingState != TrackingState.TRACKING) {
            depthReady = false
            latestSpatialSnapshot = null
            return
        }

        var depthImage: Image? = null

        try {
            depthImage = frame.acquireDepthImage16Bits()

            val camera = frame.camera
            val intrinsics = camera.imageIntrinsics
            val focalLength = intrinsics.focalLength
            val principalPoint = intrinsics.principalPoint
            val imageDimensions = intrinsics.imageDimensions

            if (
                focalLength.size < 2 ||
                principalPoint.size < 2 ||
                imageDimensions.size < 2 ||
                focalLength[0] <= 0f ||
                focalLength[1] <= 0f
            ) {
                depthReady = false
                return
            }

            val imageWidth = depthImage.width
            val imageHeight = depthImage.height

            if (imageWidth <= 1 || imageHeight <= 1) {
                depthReady = false
                return
            }

            val scaleX = imageWidth.toFloat() / imageDimensions[0].toFloat()
            val scaleY = imageHeight.toFloat() / imageDimensions[1].toFloat()

            val fx = focalLength[0] * scaleX
            val fy = focalLength[1] * scaleY
            val cx = principalPoint[0] * scaleX
            val cy = principalPoint[1] * scaleY

            val plane = depthImage.planes.firstOrNull() ?: run {
                depthReady = false
                return
            }

            val buffer = plane.buffer.duplicate()
            val rowStride = plane.rowStride
            val pixelStride = plane.pixelStride

            if (pixelStride < 2 || rowStride <= 0) {
                depthReady = false
                return
            }

            val cameraPose = camera.pose
            val samples = ArrayList<SpatialPoint>(DEPTH_GRID_SIZE * DEPTH_GRID_SIZE)
            val maxIndex = DEPTH_GRID_SIZE - 1

            for (gy in 0..maxIndex) {
                val normalizedY = gy.toFloat() / maxIndex.toFloat()
                val py = (normalizedY * (imageHeight - 1)).toInt()

                for (gx in 0..maxIndex) {
                    val normalizedX = gx.toFloat() / maxIndex.toFloat()
                    val px = (normalizedX * (imageWidth - 1)).toInt()

                    val depthMm = readDepthMillimeters(buffer, rowStride, pixelStride, px, py)
                    if (depthMm !in DEPTH_MIN_MM..DEPTH_MAX_MM) continue

                    val depthMeters = depthMm.toFloat() / 1000f
                    val cameraX = ((px.toFloat() - cx) / fx) * depthMeters
                    val cameraY = ((py.toFloat() - cy) / fy) * depthMeters
                    val cameraZ = depthMeters
                    val worldPoint = FloatArray(3)

                    cameraPose.transformPoint(
                        floatArrayOf(cameraX, cameraY, cameraZ),
                        0,
                        worldPoint,
                        0,
                    )

                    samples += SpatialPoint(
                        imageX = px,
                        imageY = py,
                        normalizedX = normalizedX,
                        normalizedY = normalizedY,
                        depthMeters = depthMeters,
                        worldX = worldPoint[0],
                        worldY = worldPoint[1],
                        worldZ = worldPoint[2],
                    )
                }
            }

            val totalSamples = DEPTH_GRID_SIZE * DEPTH_GRID_SIZE
            val validRatio = samples.size.toFloat() / totalSamples.toFloat()

            if (validRatio < DEPTH_MIN_VALID_RATIO) {
                depthReady = false
                latestSpatialSnapshot = null
                return
            }

            if (depthDiagnosticMode) {
                val centerX = imageWidth / 2
                val centerY = imageHeight / 2
                val centerDepth = readDepthMillimeters(
                    buffer,
                    rowStride,
                    pixelStride,
                    centerX,
                    centerY,
                )
                if (nowMs - lastDepthDiagnosticLogMs >= 1000L) {
                    Log.d(
                        TAG,
                        "DEPTH DIAGNOSTIC CENTER raw=${centerDepth}mm " +
                            "image=${imageWidth}x${imageHeight}",
                    )
                }
            }

            val minDepth = samples.minOfOrNull { it.depthMeters } ?: return
            val maxDepth = samples.maxOfOrNull { it.depthMeters } ?: return
            var depthSum = 0f
            for (sample in samples) depthSum += sample.depthMeters
            val averageDepth = depthSum / samples.size.toFloat()

            latestSpatialSnapshot = SpatialSnapshot(
                timestampNs = frame.timestamp,
                cameraWorldPose = cameraPose,
                imageWidth = imageWidth,
                imageHeight = imageHeight,
                cameraImageWidth = imageDimensions[0],
                cameraImageHeight = imageDimensions[1],
                validRatio = validRatio,
                averageDepthMeters = averageDepth,
                minDepthMeters = minDepth,
                maxDepthMeters = maxDepth,
                points = samples,
            )

            if (nowMs - lastDepthTextureUploadMs >= DEPTH_TEXTURE_UPDATE_INTERVAL_MS) {
                uploadDepthTexture(
                    image = depthImage,
                    plane = plane,
                    width = imageWidth,
                    height = imageHeight,
                    nowMs = nowMs,
                )
            }

            if (!depthReady) Log.d(TAG, "SPATIAL DEPTH READY")
            depthReady = true

            Log.d(
                TAG,
                "SPATIAL DEPTH samples=${samples.size} valid=${"%.0f".format(validRatio * 100f)}% " +
                    "range=${"%.2f".format(minDepth)}-${"%.2f".format(maxDepth)}m " +
                    "avg=${"%.2f".format(averageDepth)}m",
            )
        } catch (_: com.google.ar.core.exceptions.NotYetAvailableException) {
            depthReady = false
        } catch (_: com.google.ar.core.exceptions.NotTrackingException) {
            depthReady = false
        } catch (_: com.google.ar.core.exceptions.ResourceExhaustedException) {
            depthReady = false
        } catch (_: IllegalStateException) {
            depthReady = false
        } catch (t: Throwable) {
            depthReady = false
            Log.w(TAG, "Spatial depth sampling failed: ${t.message}")
        } finally {
            try { depthImage?.close() } catch (_: Throwable) {}
        }
    }

    private fun createDepthTexture(): Int {
        val textures = IntArray(1)
        GLES20.glGenTextures(1, textures, 0)
        val textureId = textures[0]

        GLES20.glBindTexture(
            GLES20.GL_TEXTURE_2D,
            textureId,
        )
        GLES20.glTexParameteri(
            GLES20.GL_TEXTURE_2D,
            GLES20.GL_TEXTURE_MIN_FILTER,
            GLES20.GL_NEAREST,
        )
        GLES20.glTexParameteri(
            GLES20.GL_TEXTURE_2D,
            GLES20.GL_TEXTURE_MAG_FILTER,
            GLES20.GL_NEAREST,
        )
        GLES20.glTexParameteri(
            GLES20.GL_TEXTURE_2D,
            GLES20.GL_TEXTURE_WRAP_S,
            GLES20.GL_CLAMP_TO_EDGE,
        )
        GLES20.glTexParameteri(
            GLES20.GL_TEXTURE_2D,
            GLES20.GL_TEXTURE_WRAP_T,
            GLES20.GL_CLAMP_TO_EDGE,
        )
        GLES20.glBindTexture(
            GLES20.GL_TEXTURE_2D,
            0,
        )

        return textureId
    }

    private fun uploadDepthTexture(
        image: Image,
        plane: Image.Plane,
        width: Int,
        height: Int,
        nowMs: Long,
    ) {
        if (depthTextureId == 0 || width <= 0 || height <= 0) {
            return
        }

        try {
            val requiredBytes = width * height * 4
            var upload = depthTextureBuffer

            if (upload == null || upload.capacity() < requiredBytes) {
                upload =
                    ByteBuffer
                        .allocateDirect(requiredBytes)
                        .order(ByteOrder.nativeOrder())
                depthTextureBuffer = upload
            }

            upload.clear()

            val source = plane.buffer.duplicate()
            val rowStride = plane.rowStride
            val pixelStride = plane.pixelStride

            if (pixelStride < 2 || rowStride < width * pixelStride) {
                return
            }

            for (y in 0 until height) {
                val rowBase = y * rowStride

                for (x in 0 until width) {
                    val byteIndex = rowBase + x * pixelStride
                    if (byteIndex + 1 >= source.limit()) {
                        upload.put(0)
                        upload.put(0)
                        continue
                    }

                    val low = source.get(byteIndex)
                    val high = source.get(byteIndex + 1)

                    // Pack uint16 depth as low/high bytes in R/G.
                    // RGBA is used so sampling .rg is reliable on GLES2/3.
                    upload.put(low)
                    upload.put(high)
                    upload.put(0.toByte())
                    upload.put((-1).toByte())
                }
            }

            upload.position(0)

            GLES20.glBindTexture(
                GLES20.GL_TEXTURE_2D,
                depthTextureId,
            )

            if (
                depthTextureWidth != width ||
                depthTextureHeight != height
            ) {
                GLES20.glTexImage2D(
                    GLES20.GL_TEXTURE_2D,
                    0,
                    GLES20.GL_RGBA,
                    width,
                    height,
                    0,
                    GLES20.GL_RGBA,
                    GLES20.GL_UNSIGNED_BYTE,
                    upload,
                )
                depthTextureWidth = width
                depthTextureHeight = height
            } else {
                GLES20.glTexSubImage2D(
                    GLES20.GL_TEXTURE_2D,
                    0,
                    0,
                    0,
                    width,
                    height,
                    GLES20.GL_RGBA,
                    GLES20.GL_UNSIGNED_BYTE,
                    upload,
                )
            }

            GLES20.glBindTexture(
                GLES20.GL_TEXTURE_2D,
                0,
            )

            depthTextureReady = true
            lastDepthTextureUploadMs = nowMs

            Log.d(
                TAG,
                "DEPTH OCCLUSION TEXTURE READY ${width}x${height} " +
                    "format=${image.format} rowStride=$rowStride pixelStride=$pixelStride",
            )
        } catch (t: Throwable) {
            depthTextureReady = false
            Log.w(
                TAG,
                "Depth texture upload failed: ${t.message}",
            )
        }
    }

    private fun updateDepthUvTransform(
        frame: Frame,
    ): Boolean {
        if (
            !depthTextureReady ||
            depthTextureWidth <= 0 ||
            depthTextureHeight <= 0 ||
            surfaceWidth <= 0 ||
            surfaceHeight <= 0
        ) {
            return false
        }

        return try {
            /*
             * IMPORTANT: uDepthTexture is our own GL texture containing the
             * CPU depth image. It is NOT ARCore's camera GPU texture.
             * Therefore Coordinates2d.TEXTURE_NORMALIZED is the wrong target
             * coordinate system for this texture.
             *
             * Convert the current display-rotated OpenGL NDC positions into
             * ARCore CPU-image normalized coordinates first. The acquired
             * Depth image is registered to the camera image geometry, so the
             * resulting normalized image coordinates can be used to sample
             * our uploaded depth texture.
             *
             * Android CPU images use a top-left origin while OpenGL textures
             * use a bottom-left texture origin. The Y axis is therefore flipped
             * before the matrix is sent to the shader.
             */
            frame.transformCoordinates2d(
                Coordinates2d.OPENGL_NORMALIZED_DEVICE_COORDINATES,
                depthNdcBasis,
                Coordinates2d.IMAGE_NORMALIZED,
                depthTextureBasis,
            )

            val ox = depthTextureBasis[0]
            val oy = depthTextureBasis[1]

            val xx = depthTextureBasis[2] - ox
            val xy = depthTextureBasis[3] - oy
            val yx = depthTextureBasis[4] - ox
            val yy = depthTextureBasis[5] - oy

            // imageNormalized = A * ndc + b
            // depthTextureUv = (imageX, 1 - imageY)
            //
            // column-major mat3:
            // uv = [ xx, -xy, ox;
            //        yx, -yy, oyFlip;
            //        0,   0,   1 ] * [ndcX ndcY 1]
            // where oyFlip = 1 - oy.
            depthUvTransform[0] = xx
            depthUvTransform[1] = -xy
            depthUvTransform[2] = 0f

            depthUvTransform[3] = yx
            depthUvTransform[4] = -yy
            depthUvTransform[5] = 0f

            depthUvTransform[6] = ox
            depthUvTransform[7] = 1f - oy
            depthUvTransform[8] = 1f

            if (!depthOcclusionTransformReady) {
                depthOcclusionTransformReady = true
                Log.d(
                    TAG,
                    "DEPTH OCCLUSION IMAGE-SPACE TRANSFORM READY " +
                        "depth=${depthTextureWidth}x${depthTextureHeight}",
                )
            }

            if (depthDiagnosticMode) {
                val nowMs = android.os.SystemClock.uptimeMillis()
                if (nowMs - lastDepthDiagnosticLogMs >= 1000L) {
                    lastDepthDiagnosticLogMs = nowMs
                    Log.d(
                        TAG,
                        "DEPTH DIAGNOSTIC TRANSFORM " +
                            "[${"%.4f".format(depthUvTransform[0])}," +
                            "${"%.4f".format(depthUvTransform[3])}," +
                            "${"%.4f".format(depthUvTransform[6])};" +
                            "${"%.4f".format(depthUvTransform[1])}," +
                            "${"%.4f".format(depthUvTransform[4])}," +
                            "${"%.4f".format(depthUvTransform[7])}]",
                    )
                }
            }

            true
        } catch (t: Throwable) {
            depthOcclusionTransformReady = false
            Log.w(
                TAG,
                "Depth image UV transform failed: ${t.message}",
            )
            false
        }
    }

    private fun readDepthMillimeters(
        buffer: java.nio.ByteBuffer,
        rowStride: Int,
        pixelStride: Int,
        x: Int,
        y: Int,
    ): Int {
        val byteIndex = y * rowStride + x * pixelStride
        if (byteIndex < 0 || byteIndex + 1 >= buffer.limit()) return 0
        val low = buffer.get(byteIndex).toInt() and 0xFF
        val high = buffer.get(byteIndex + 1).toInt() and 0xFF
        return low or (high shl 8)
    }

    data class SpatialPoint(
        val imageX: Int,
        val imageY: Int,
        val normalizedX: Float,
        val normalizedY: Float,
        val depthMeters: Float,
        val worldX: Float,
        val worldY: Float,
        val worldZ: Float,
    )

    data class SpatialSnapshot(
        val timestampNs: Long,
        val cameraWorldPose: Pose,
        val imageWidth: Int,
        val imageHeight: Int,
        val cameraImageWidth: Int,
        val cameraImageHeight: Int,
        val validRatio: Float,
        val averageDepthMeters: Float,
        val minDepthMeters: Float,
        val maxDepthMeters: Float,
        val points: List<SpatialPoint>,
    )

    /**
     * Projects the latest ML detections from CPU-image pixels into Android
     * VIEW coordinates using ARCore's authoritative display geometry.
     */
    private fun updateVisionProjection(
        frame: Frame,
        nowMs: Long,
    ) {
        latestVisionTrackingState =
            when (frame.camera.trackingState) {
                TrackingState.TRACKING -> "TRACKING"
                TrackingState.PAUSED -> "PAUSED"
                else -> "STOPPED"
            }

        if (
            surfaceWidth <= 0 ||
            surfaceHeight <= 0 ||
            frame.camera.trackingState != TrackingState.TRACKING
        ) {
            latestProjectedVisionObjects = emptyList()
            latestVisionProjectionTimestampNs = 0L
            return
        }

        if (nowMs - lastVisionProjectionMs < VISION_PROJECTION_INTERVAL_MS) {
            return
        }

        lastVisionProjectionMs = nowMs

        val scene = visionEngine.latestScene()

        if (scene.objects.isEmpty()) {
            latestProjectedVisionObjects = emptyList()
            latestVisionProjectionTimestampNs = scene.timestampNanos
            return
        }

        val projected =
            ArrayList<ProjectedVisionObject>(
                scene.objects.size,
            )

        for (objectInfo in scene.objects) {
            val b = objectInfo.bounds

            val input = floatArrayOf(
                b.left.toFloat(), b.top.toFloat(),
                b.right.toFloat(), b.top.toFloat(),
                b.left.toFloat(), b.bottom.toFloat(),
                b.right.toFloat(), b.bottom.toFloat(),
            )

            val output = FloatArray(input.size)

            try {
                frame.transformCoordinates2d(
                    Coordinates2d.IMAGE_PIXELS,
                    input,
                    Coordinates2d.VIEW,
                    output,
                )

                var left = Float.POSITIVE_INFINITY
                var top = Float.POSITIVE_INFINITY
                var right = Float.NEGATIVE_INFINITY
                var bottom = Float.NEGATIVE_INFINITY

                var i = 0
                while (i < output.size) {
                    left = minOf(left, output[i])
                    top = minOf(top, output[i + 1])
                    right = maxOf(right, output[i])
                    bottom = maxOf(bottom, output[i + 1])
                    i += 2
                }

                left = left.coerceIn(0f, surfaceWidth.toFloat())
                top = top.coerceIn(0f, surfaceHeight.toFloat())
                right = right.coerceIn(0f, surfaceWidth.toFloat())
                bottom = bottom.coerceIn(0f, surfaceHeight.toFloat())

                if (right <= left || bottom <= top) {
                    continue
                }

                projected +=
                    ProjectedVisionObject(
                        trackingId = objectInfo.trackingId,
                        primaryLabel = objectInfo.primaryLabel,
                        confidence = objectInfo.primaryConfidence,
                        semanticKind = objectInfo.semanticKind,
                        sourceBounds = b,
                        left = left,
                        top = top,
                        right = right,
                        bottom = bottom,
                    )
            } catch (t: Throwable) {
                Log.w(
                    TAG,
                    "Vision coordinate projection failed: ${t.message}",
                )
            }
        }

        latestProjectedVisionObjects = projected
        latestVisionProjectionTimestampNs = scene.timestampNanos
    }

    /**
     * Connects what the Vision engine saw in 2D with what ARCore measured in 3D.
     * This is intentionally lightweight; no new ML inference happens here.
     */
    private fun updateSpatialFusion(
        frame: Frame,
        nowMs: Long,
    ) {
        if (nowMs - lastSpatialFusionMs < 180L) return

        lastSpatialFusionMs = nowMs

        val depth = latestSpatialSnapshot
        if (!depthReady || depth == null || depth.points.isEmpty()) {
            latestFusedScene = null
            latestFusedObjectById = emptyMap()
            return
        }

        val scene = visionEngine.latestScene()
        if (scene.objects.isEmpty()) {
            latestFusedScene =
                FusedSceneSnapshot(
                    timestampNs = depth.timestampNs,
                    objects = emptyList(),
                    environment = scene.environment,
                )
            latestFusedObjectById = emptyMap()
            return
        }

        val fused = ArrayList<FusedObject>(scene.objects.size)
        val projectedObjects = latestProjectedVisionObjects

        for (visionObject in scene.objects) {
            val bounds = visionObject.bounds

            /*
             * Use ARCore's display geometry to convert the projected screen
             * center back into CPU-image pixels before mapping it into the
             * depth image. This avoids assuming that the camera image and
             * Flutter surface share the same rotation/crop.
             */
            val projected =
                projectedObjects.firstOrNull {
                    it.trackingId == visionObject.trackingId &&
                        it.sourceBounds == bounds
                } ?: projectedObjects.firstOrNull {
                    it.trackingId == visionObject.trackingId
                }

            val viewCenterX =
                projected?.centerX ?: surfaceWidth * 0.5f
            val viewCenterY =
                projected?.centerY ?: surfaceHeight * 0.5f

            val imageCenter = FloatArray(2)

            try {
                frame.transformCoordinates2d(
                    Coordinates2d.VIEW,
                    floatArrayOf(viewCenterX, viewCenterY),
                    Coordinates2d.IMAGE_PIXELS,
                    imageCenter,
                )
            } catch (_: Throwable) {
                imageCenter[0] = bounds.centerX().toFloat()
                imageCenter[1] = bounds.centerY().toFloat()
            }

            val depthCenterX =
                (
                    imageCenter[0].coerceIn(
                        0f,
                        (depth.cameraImageWidth - 1).toFloat(),
                    ) /
                        depth.cameraImageWidth.coerceAtLeast(1)
                    *
                        depth.imageWidth
                ).toInt()

            val depthCenterY =
                (
                    imageCenter[1].coerceIn(
                        0f,
                        (depth.cameraImageHeight - 1).toFloat(),
                    ) /
                        depth.cameraImageHeight.coerceAtLeast(1)
                    *
                        depth.imageHeight
                ).toInt()

            val local = depth.points
                .asSequence()
                .filter { it.depthMeters in 0.25f..12f }
                .sortedBy {
                    val dx = it.imageX - depthCenterX
                    val dy = it.imageY - depthCenterY
                    dx * dx + dy * dy
                }
                .take(7)
                .toList()

            if (local.isEmpty()) continue

            val median = local.sortedBy { it.depthMeters }[local.size / 2]
            val xMin = local.minOf { it.worldX }
            val xMax = local.maxOf { it.worldX }
            val yMin = local.minOf { it.worldY }
            val yMax = local.maxOf { it.worldY }
            val zMin = local.minOf { it.worldZ }
            val zMax = local.maxOf { it.worldZ }

            val detectionArea =
                (bounds.width().toFloat() * bounds.height().toFloat())
                    .coerceAtLeast(1f)
            val screenArea =
                (surfaceWidth.toFloat() * surfaceHeight.toFloat())
                    .coerceAtLeast(1f)
            val imageSupport = (detectionArea / screenArea * 10f).coerceIn(0f, 1f)
            val sampleSupport = (local.size / 7f).coerceIn(0f, 1f)

            val confidence = (
                visionObject.primaryConfidence * 0.45f +
                    depth.validRatio * 0.30f +
                    imageSupport * 0.10f +
                    sampleSupport * 0.15f
                ).coerceIn(0f, 1f)

            fused += FusedObject(
                trackingId = visionObject.trackingId,
                label = visionObject.primaryLabel,
                semanticKind = visionObject.semanticKind,
                worldX = median.worldX,
                worldY = median.worldY,
                worldZ = median.worldZ,
                depthMeters = median.depthMeters,
                estimatedWidthMeters = (xMax - xMin).coerceAtLeast(0f),
                estimatedHeightMeters = (yMax - yMin).coerceAtLeast(0f),
                estimatedDepthMeters = (zMax - zMin).coerceAtLeast(0f),
                confidence = confidence,
                sourceBounds = bounds,
            )
        }

        latestFusedScene =
            FusedSceneSnapshot(
                timestampNs = depth.timestampNs,
                objects = fused,
                environment = scene.environment,
            )

        latestFusedObjectById =
            fused
                .asSequence()
                .filter { it.trackingId >= 0 }
                .associateBy { it.trackingId }

        if (fused.isNotEmpty()) {
            val first = fused.first()
            Log.d(
                TAG,
                "SPATIAL FUSION objects=${fused.size} " +
                    "first=${first.label} " +
                    "pos=(" +
                    "${"%.2f".format(first.worldX)}," +
                    "${"%.2f".format(first.worldY)}," +
                    "${"%.2f".format(first.worldZ)}) " +
                    "depth=${"%.2f".format(first.depthMeters)}m " +
                    "confidence=${"%.2f".format(first.confidence)}",
            )
        }
    }

    data class ProjectedVisionObject(
        val trackingId: Int,
        val primaryLabel: String,
        val confidence: Float,
        val semanticKind: SemanticKind,
        val sourceBounds: android.graphics.Rect,
        val left: Float,
        val top: Float,
        val right: Float,
        val bottom: Float,
    ) {
        val width: Float
            get() = (right - left).coerceAtLeast(0f)

        val height: Float
            get() = (bottom - top).coerceAtLeast(0f)

        val centerX: Float
            get() = (left + right) * 0.5f

        val centerY: Float
            get() = (top + bottom) * 0.5f

        val area: Float
            get() = width * height
    }

    data class FusedObject(
        val trackingId: Int,
        val label: String,
        val semanticKind: SemanticKind,
        val worldX: Float,
        val worldY: Float,
        val worldZ: Float,
        val depthMeters: Float,
        val estimatedWidthMeters: Float,
        val estimatedHeightMeters: Float,
        val estimatedDepthMeters: Float,
        val confidence: Float,
        val sourceBounds: android.graphics.Rect,
    )

    data class FusedSceneSnapshot(
        val timestampNs: Long,
        val objects: List<FusedObject>,
        val environment: SceneEnvironment,
    )

    private fun detectPlanes(currentSession: Session) {
        try {
            val planes =
                currentSession.getAllTrackables(
                    Plane::class.java,
                )

            var trackingPlaneCount = 0

            for (plane in planes) {
                if (
                    plane.trackingState == TrackingState.TRACKING &&
                    plane.subsumedBy == null
                ) {
                    trackingPlaneCount++
                }
            }

            if (trackingPlaneCount != lastPlaneCount) {
                lastPlaneCount = trackingPlaneCount

                Log.d(
                    TAG,
                    "Tracking planes: $trackingPlaneCount",
                )
            }

            if (!hasDetectedPlane && trackingPlaneCount > 0) {
                hasDetectedPlane = true

                Log.d(
                    TAG,
                    "FIRST AR PLANE DETECTED",
                )
            }
        } catch (t: Throwable) {
            Log.e(
                TAG,
                "Plane detection error",
                t,
            )
        }
    }

    private fun updateReticle(
        frame: Frame,
        nowMs: Long,
    ) {
        if (
            surfaceWidth <= 0 ||
            surfaceHeight <= 0 ||
            frame.camera.trackingState != TrackingState.TRACKING
        ) {
            setReticleState(false, null)
            return
        }

        if (nowMs - lastHitTestMs < HIT_TEST_INTERVAL_MS) {
            return
        }

        lastHitTestMs = nowMs

        /*
         * The reticle is an interaction feature, not continuous depth
         * analysis. Use ARCore's center-screen hit test at a controlled
         * rate so the indicator follows the camera direction correctly.
         *
         * Priority:
         *   1) tracked Plane inside its polygon
         *   2) tracked DepthPoint
         *   3) tracked Point
         *
         * This restores the normal AR behavior where the reticle moves with
         * the phone and marks the surface the camera is pointing at.
         */
        try {
            val centerX = surfaceWidth * 0.5f
            val centerY = surfaceHeight * 0.5f

            val hit =
                frame.hitTest(centerX, centerY)
                    .firstOrNull { result ->
                        when (val trackable = result.trackable) {
                            is Plane ->
                                trackable.trackingState ==
                                    TrackingState.TRACKING &&
                                    trackable.subsumedBy == null &&
                                    trackable.isPoseInPolygon(
                                        result.hitPose,
                                    )

                            is com.google.ar.core.DepthPoint ->
                                trackable.trackingState ==
                                    TrackingState.TRACKING

                            is com.google.ar.core.Point ->
                                trackable.trackingState ==
                                    TrackingState.TRACKING

                            else -> false
                        }
                    }

            if (hit != null) {
                setReticleState(true, hit.hitPose)
            } else {
                setReticleState(false, null)
            }
        } catch (_: com.google.ar.core.exceptions.NotTrackingException) {
            setReticleState(false, null)
        } catch (_: com.google.ar.core.exceptions.NotYetAvailableException) {
            setReticleState(false, null)
        } catch (_: com.google.ar.core.exceptions.ResourceExhaustedException) {
            setReticleState(false, null)
        } catch (t: Throwable) {
            Log.w(
                TAG,
                "Reticle hit test failed: ${t.message}",
            )
            setReticleState(false, null)
        }
    }

    private fun setReticleState(
        visible: Boolean,
        pose: Pose?,
    ) {
        if (visible != reticleVisible) {
            reticleVisible = visible
            Log.d(
                TAG,
                if (visible) {
                    "RETICLE SURFACE FOUND"
                } else {
                    "RETICLE SURFACE LOST"
                },
            )
        }

        reticlePose = pose
    }

    private fun processPendingTap(frame: Frame) {
        val x = pendingTapX
        val y = pendingTapY

        if (x < 0f || y < 0f) {
            return
        }

        pendingTapX = -1f
        pendingTapY = -1f

        if (frame.camera.trackingState != TrackingState.TRACKING) {
            Log.d(TAG, "Tap ignored: camera is not tracking")
            return
        }

        /*
         * Placement intentionally uses the SAME spatial hit hierarchy as the
         * visible reticle:
         *
         *   1) tracked Plane inside polygon
         *   2) tracked DepthPoint
         *   3) tracked Point
         *
         * This is important: the reticle can legitimately be visible on a
         * DepthPoint/Point even when a Plane is not available yet. The old
         * placement path accepted Plane only, so tapping a visible reticle
         * could do nothing.
         *
         * Hit testing still happens only for the user's explicit tap; the
         * continuous reticle path remains throttled.
         */
        try {
            val hit =
                frame
                    .hitTest(x, y)
                    .firstOrNull { result ->
                        when (val trackable = result.trackable) {
                            is Plane ->
                                trackable.trackingState ==
                                    TrackingState.TRACKING &&
                                    trackable.subsumedBy == null &&
                                    trackable.isPoseInPolygon(
                                        result.hitPose,
                                    )

                            is com.google.ar.core.DepthPoint ->
                                trackable.trackingState ==
                                    TrackingState.TRACKING

                            is com.google.ar.core.Point ->
                                trackable.trackingState ==
                                    TrackingState.TRACKING

                            else -> false
                        }
                    }

            if (hit == null) {
                Log.d(TAG, "No valid spatial hit for placement")
                return
            }

            objectAnchor?.detach()
            objectAnchor = hit.createAnchor()
            resetAnchorStabilizer()

            Log.d(
                TAG,
                "SPATIAL OBJECT PLACED — distance=${"%.2f".format(hit.distance)}m " +
                    "trackable=${hit.trackable.javaClass.simpleName}",
            )
        } catch (_: com.google.ar.core.exceptions.NotTrackingException) {
            Log.d(TAG, "Placement ignored: tracking not ready")
        } catch (_: com.google.ar.core.exceptions.NotYetAvailableException) {
            Log.d(TAG, "Placement ignored: AR hit data not ready")
        } catch (_: com.google.ar.core.exceptions.ResourceExhaustedException) {
            Log.d(TAG, "Placement ignored: AR resources temporarily exhausted")
        } catch (t: Throwable) {
            Log.w(TAG, "Placement hit-test failed: ${t.message}")
        }
    }


    private fun resetAnchorStabilizer() {
        stableAnchorPose = null
        lastStableAnchorUpdateMs = 0L
        anchorLostSinceMs = 0L
        anchorOutlierCount = 0
        anchorStableFrames = 0
    }

    private fun updateStableAnchorPose(
        anchor: com.google.ar.core.Anchor,
        nowMs: Long,
    ): Pose? {
        if (anchor.trackingState != TrackingState.TRACKING) {
            if (anchorLostSinceMs == 0L) {
                anchorLostSinceMs = nowMs
            }

            // Keep the last good pose briefly through transient tracking loss.
            // After the grace period, hide the object rather than letting a
            // stale pose live indefinitely.
            return if (stableAnchorPose != null && nowMs - anchorLostSinceMs <= 350L) {
                stableAnchorPose
            } else {
                null
            }
        }

        anchorLostSinceMs = 0L
        val rawPose = anchor.pose
        val previous = stableAnchorPose

        if (previous == null) {
            stableAnchorPose = rawPose
            lastStableAnchorUpdateMs = nowMs
            anchorStableFrames = 1
            return rawPose
        }

        val dtMs =
            if (lastStableAnchorUpdateMs == 0L) {
                16L
            } else {
                (nowMs - lastStableAnchorUpdateMs).coerceIn(1L, 100L)
            }
        lastStableAnchorUpdateMs = nowMs

        val prevT = previous.translation
        val rawT = rawPose.translation
        val dx = rawT[0] - prevT[0]
        val dy = rawT[1] - prevT[1]
        val dz = rawT[2] - prevT[2]
        val distance = kotlin.math.sqrt(dx * dx + dy * dy + dz * dz)

        // A placed anchor should not teleport. Reject a couple of suspicious
        // frames before accepting a large correction from ARCore.
        if (distance > 0.18f) {
            anchorOutlierCount += 1
            if (anchorOutlierCount < 3) {
                return previous
            }
        } else {
            anchorOutlierCount = 0
        }

        // Treat tiny pose changes as tracking noise while allowing deliberate
        // corrections through quickly enough to avoid a rubber-band effect.
        if (distance < 0.006f) {
            return previous
        }

        val alpha = when {
            distance > 0.08f -> 0.24f
            distance > 0.025f -> 0.12f
            else -> 0.075f
        }

        // Slightly adapt to frame time without letting smoothing become too
        // weak on slow frames.
        val frameFactor = (dtMs / 16.0f).coerceIn(0.75f, 1.75f)
        val adaptiveAlpha = (alpha * frameFactor).coerceIn(0.06f, 0.28f)

        val smoothed =
            Pose.makeInterpolated(
                previous,
                rawPose,
                adaptiveAlpha,
            )

        stableAnchorPose = smoothed
        anchorStableFrames += 1

        if (anchorStableFrames == 30) {
            Log.d(TAG, "ANCHOR STABILIZATION ACTIVE")
        }

        return smoothed
    }

    private fun drawDepthDiagnosticOverlay() {
        if (
            !depthTextureReady ||
            depthDiagnosticProgram == 0 ||
            depthDiagnosticPositionHandle < 0 ||
            depthDiagnosticTextureHandle < 0 ||
            depthDiagnosticUvTransformHandle < 0
        ) {
            return
        }

        try {
            GLES20.glDisable(GLES20.GL_DEPTH_TEST)
            GLES20.glEnable(GLES20.GL_BLEND)
            GLES20.glBlendFunc(
                GLES20.GL_SRC_ALPHA,
                GLES20.GL_ONE_MINUS_SRC_ALPHA,
            )

            GLES20.glUseProgram(depthDiagnosticProgram)

            quad.position(0)
            GLES20.glEnableVertexAttribArray(
                depthDiagnosticPositionHandle,
            )
            GLES20.glVertexAttribPointer(
                depthDiagnosticPositionHandle,
                2,
                GLES20.GL_FLOAT,
                false,
                0,
                quad,
            )

            GLES20.glUniformMatrix3fv(
                depthDiagnosticUvTransformHandle,
                1,
                false,
                depthUvTransform,
                0,
            )

            if (depthDiagnosticNearHandle >= 0) {
                GLES20.glUniform1f(
                    depthDiagnosticNearHandle,
                    0.18f,
                )
            }

            if (depthDiagnosticFarHandle >= 0) {
                GLES20.glUniform1f(
                    depthDiagnosticFarHandle,
                    8.0f,
                )
            }

            GLES20.glActiveTexture(GLES20.GL_TEXTURE1)
            GLES20.glBindTexture(
                GLES20.GL_TEXTURE_2D,
                depthTextureId,
            )
            GLES20.glUniform1i(
                depthDiagnosticTextureHandle,
                1,
            )

            GLES20.glDrawArrays(
                GLES20.GL_TRIANGLE_STRIP,
                0,
                4,
            )

            GLES20.glDisableVertexAttribArray(
                depthDiagnosticPositionHandle,
            )
            GLES20.glBindTexture(
                GLES20.GL_TEXTURE_2D,
                0,
            )
            GLES20.glActiveTexture(GLES20.GL_TEXTURE0)
            GLES20.glUseProgram(0)
        } catch (t: Throwable) {
            Log.e(
                TAG,
                "Depth diagnostic overlay failed",
                t,
            )
        } finally {
            GLES20.glDisable(GLES20.GL_BLEND)
            GLES20.glDisable(GLES20.GL_DEPTH_TEST)
        }
    }

    private fun drawDetectedPlanes(
        currentSession: Session,
        frame: Frame,
    ) {
        if (!DRAW_PLANE_DEBUG) return

        if (frame.camera.trackingState != TrackingState.TRACKING) {
            return
        }

        try {
            val planes =
                currentSession.getAllTrackables(
                    Plane::class.java,
                )

            GLES20.glEnable(GLES20.GL_BLEND)
            GLES20.glDisable(GLES20.GL_DEPTH_TEST)
            GLES20.glLineWidth(3f)

            for (plane in planes) {
                if (
                    plane.trackingState != TrackingState.TRACKING ||
                    plane.subsumedBy != null
                ) {
                    continue
                }

                val vertexCount = updatePlaneVertexBuffer(plane)
                val buffer = planeVertexBuffer ?: continue

                if (vertexCount < 3) {
                    continue
                }

                val planeMatrix = FloatArray(16)
                plane.centerPose.toMatrix(planeMatrix, 0)
                buildMvp(
                    planeMatrix,
                    frame,
                )

                GLES20.glUseProgram(objectProgram)
                if (objectDepthOcclusionEnabledHandle >= 0) {
                    GLES20.glUniform1f(
                        objectDepthOcclusionEnabledHandle,
                        0f,
                    )
                }
                buffer.position(0)
                GLES20.glEnableVertexAttribArray(objectPositionHandle)
                GLES20.glVertexAttribPointer(
                    objectPositionHandle,
                    3,
                    GLES20.GL_FLOAT,
                    false,
                    0,
                    buffer,
                )

                GLES20.glUniformMatrix4fv(
                    objectMvpHandle,
                    1,
                    false,
                    mvpMatrix,
                    0,
                )

                GLES20.glUniform4f(
                    objectColorHandle,
                    0.10f,
                    0.82f,
                    1.00f,
                    0.10f,
                )

                GLES20.glDrawArrays(
                    GLES20.GL_TRIANGLE_FAN,
                    0,
                    vertexCount,
                )

                GLES20.glUniform4f(
                    objectColorHandle,
                    0.10f,
                    0.90f,
                    1.00f,
                    0.90f,
                )

                GLES20.glDrawArrays(
                    GLES20.GL_LINE_LOOP,
                    0,
                    vertexCount,
                )

                GLES20.glDisableVertexAttribArray(objectPositionHandle)
                GLES20.glUseProgram(0)
            }

            GLES20.glLineWidth(1f)
        } catch (t: Throwable) {
            Log.e(
                TAG,
                "Plane rendering failed",
                t,
            )
        } finally {
            GLES20.glDisable(GLES20.GL_DEPTH_TEST)
        }
    }

    private fun updatePlaneVertexBuffer(plane: Plane): Int {
        val polygon = plane.polygon.duplicate()
        polygon.rewind()

        val floatCount = polygon.remaining() * 3
        if (floatCount < 9) {
            return 0
        }

        ensurePlaneBuffer(floatCount)

        var outputIndex = 0
        while (polygon.hasRemaining()) {
            val x = polygon.get()
            val z = polygon.get()

            planeVerticesArray[outputIndex++] = x
            planeVerticesArray[outputIndex++] = 0f
            planeVerticesArray[outputIndex++] = z
        }

        val buffer = planeVertexBuffer ?: return 0
        buffer.clear()
        buffer.put(planeVerticesArray, 0, outputIndex)
        buffer.position(0)

        return outputIndex / 3
    }

    private fun ensurePlaneBuffer(requiredFloatCount: Int) {
        if (planeVerticesArray.size >= requiredFloatCount) {
            return
        }

        var newSize = if (planeVerticesArray.isEmpty()) 96 else planeVerticesArray.size
        while (newSize < requiredFloatCount) {
            newSize *= 2
        }

        planeVerticesArray = FloatArray(newSize)
        planeVertexBuffer =
            ByteBuffer
                .allocateDirect(newSize * 4)
                .order(ByteOrder.nativeOrder())
                .asFloatBuffer()
    }

    private fun drawReticle(frame: Frame) {
        val pose = reticlePose
        if (!reticleVisible || pose == null) {
            return
        }

        try {
            GLES20.glDisable(GLES20.GL_DEPTH_TEST)
            GLES20.glEnable(GLES20.GL_BLEND)
            GLES20.glLineWidth(4f)

            pose.toMatrix(modelMatrix, 0)
            buildMvp(modelMatrix, frame)

            GLES20.glUseProgram(objectProgram)

            // The reticle is UI/debug geometry; it must never participate in
            // world-depth occlusion.
            if (objectDepthOcclusionEnabledHandle >= 0) {
                GLES20.glUniform1f(
                    objectDepthOcclusionEnabledHandle,
                    0f,
                )
            }

            reticleVertices.position(0)
            GLES20.glEnableVertexAttribArray(objectPositionHandle)
            GLES20.glVertexAttribPointer(
                objectPositionHandle,
                3,
                GLES20.GL_FLOAT,
                false,
                0,
                reticleVertices,
            )

            GLES20.glUniformMatrix4fv(
                objectMvpHandle,
                1,
                false,
                mvpMatrix,
                0,
            )

            GLES20.glUniform4f(
                objectColorHandle,
                0.10f,
                0.95f,
                1.00f,
                1.00f,
            )

            GLES20.glDrawArrays(
                GLES20.GL_LINE_LOOP,
                0,
                reticleVertices.capacity() / 3,
            )

            GLES20.glDisableVertexAttribArray(objectPositionHandle)
            GLES20.glUseProgram(0)
            GLES20.glLineWidth(1f)
        } catch (t: Throwable) {
            Log.e(
                TAG,
                "Reticle rendering failed",
                t,
            )
        }
    }

    private fun drawPlacedObject(frame: Frame) {
        val anchor = objectAnchor ?: return

        val nowMs = android.os.SystemClock.uptimeMillis()
        val pose = updateStableAnchorPose(anchor, nowMs) ?: return

        try {
            GLES20.glEnable(GLES20.GL_DEPTH_TEST)
            GLES20.glDisable(GLES20.GL_CULL_FACE)
            GLES20.glEnable(GLES20.GL_BLEND)
            GLES20.glBlendFunc(
                GLES20.GL_SRC_ALPHA,
                GLES20.GL_ONE_MINUS_SRC_ALPHA,
            )

            pose.toMatrix(modelMatrix, 0)

            // Lift the cube so its bottom sits exactly at the anchor position.
            Matrix.translateM(
                modelMatrix,
                0,
                0f,
                0.05f,
                0f,
            )

            buildMvp(modelMatrix, frame)
            val objectOcclusionActive = updateDepthUvTransform(frame)

            GLES20.glUseProgram(objectProgram)

            cubeVertices.position(0)
            cubeNormals.position(0)

            GLES20.glEnableVertexAttribArray(
                objectPositionHandle,
            )
            GLES20.glVertexAttribPointer(
                objectPositionHandle,
                3,
                GLES20.GL_FLOAT,
                false,
                0,
                cubeVertices,
            )

            GLES20.glEnableVertexAttribArray(
                objectNormalHandle,
            )
            GLES20.glVertexAttribPointer(
                objectNormalHandle,
                3,
                GLES20.GL_FLOAT,
                false,
                0,
                cubeNormals,
            )


            GLES20.glUniformMatrix4fv(
                objectMvpHandle,
                1,
                false,
                mvpMatrix,
                0,
            )

            GLES20.glUniformMatrix4fv(
                objectModelHandle,
                1,
                false,
                modelMatrix,
                0,
            )

            GLES20.glUniformMatrix4fv(
                objectViewMatrixHandle,
                1,
                false,
                viewMatrix,
                0,
            )

            if (objectDepthOcclusionEnabledHandle >= 0) {
                GLES20.glUniform1f(
                    objectDepthOcclusionEnabledHandle,
                    if (objectOcclusionActive) 1f else 0f,
                )
            }



            if (objectDepthToleranceHandle >= 0) {
                GLES20.glUniform1f(
                    objectDepthToleranceHandle,
                    0.006f,
                )
            }

            if (objectOcclusionAlphaHandle >= 0) {
                GLES20.glUniform1f(
                    objectOcclusionAlphaHandle,
                    0.0f,
                )
            }

            if (
                objectOcclusionActive &&
                objectDepthUvTransformHandle >= 0
            ) {
                GLES20.glUniformMatrix3fv(
                    objectDepthUvTransformHandle,
                    1,
                    false,
                    depthUvTransform,
                    0,
                )
            }

            if (objectDepthTextureHandle >= 0) {
                GLES20.glActiveTexture(GLES20.GL_TEXTURE1)
                GLES20.glBindTexture(
                    GLES20.GL_TEXTURE_2D,
                    depthTextureId,
                )
                GLES20.glUniform1i(
                    objectDepthTextureHandle,
                    1,
                )
            }

            GLES20.glUniform4f(
                objectColorHandle,
                0.10f,
                0.58f,
                0.92f,
                1.0f,
            )

            GLES20.glUniform1f(
                objectLightIntensityHandle,
                latestLightIntensity,
            )

            GLES20.glUniform3fv(
                objectLightDirectionHandle,
                1,
                lightDirection,
                0,
            )

            GLES20.glUniform3fv(
                objectLightColorHandle,
                1,
                lightColor,
                0,
            )

            GLES20.glUniform3fv(
                objectViewPositionHandle,
                1,
                viewPosition,
                0,
            )

            GLES20.glDrawArrays(
                GLES20.GL_TRIANGLES,
                0,
                36,
            )

            GLES20.glDisableVertexAttribArray(
                objectPositionHandle,
            )
            GLES20.glDisableVertexAttribArray(
                objectNormalHandle,
            )
            GLES20.glActiveTexture(GLES20.GL_TEXTURE1)
            GLES20.glBindTexture(
                GLES20.GL_TEXTURE_2D,
                0,
            )
            GLES20.glActiveTexture(GLES20.GL_TEXTURE0)

            GLES20.glUseProgram(0)
        } catch (t: Throwable) {
            Log.e(
                TAG,
                "Object rendering failed",
                t,
            )
        } finally {
            GLES20.glDisable(GLES20.GL_BLEND)
            GLES20.glDisable(GLES20.GL_DEPTH_TEST)
        }
    }

    private fun updateEnvironmentalLighting(frame: Frame) {
        try {
            val estimate = frame.lightEstimate

            if (estimate.state == com.google.ar.core.LightEstimate.State.VALID) {
                val hdrDirection = estimate.environmentalHdrMainLightDirection
                if (hdrDirection.size >= 3) {
                    val targetX = hdrDirection[0]
                    val targetY = hdrDirection[1]
                    val targetZ = hdrDirection[2]

                    // Smooth light direction slightly so specular highlights
                    // do not sparkle when the camera moves by a few pixels.
                    lightDirection[0] =
                        lightDirection[0] * 0.82f + targetX * 0.18f
                    lightDirection[1] =
                        lightDirection[1] * 0.82f + targetY * 0.18f
                    lightDirection[2] =
                        lightDirection[2] * 0.82f + targetZ * 0.18f

                    val len =
                        kotlin.math.sqrt(
                            lightDirection[0] * lightDirection[0] +
                                lightDirection[1] * lightDirection[1] +
                                lightDirection[2] * lightDirection[2],
                        ).coerceAtLeast(0.0001f)
                    lightDirection[0] /= len
                    lightDirection[1] /= len
                    lightDirection[2] /= len
                }

                val hdrIntensity = estimate.environmentalHdrMainLightIntensity
                if (hdrIntensity.size >= 3) {
                    val r = hdrIntensity[0].coerceAtLeast(0f)
                    val g = hdrIntensity[1].coerceAtLeast(0f)
                    val b = hdrIntensity[2].coerceAtLeast(0f)
                    val maxChannel = maxOf(r, g, b, 0.0001f)

                    // Keep the RGB ratios as the real light color, while the
                    // max channel drives the scalar lighting/shadow energy.
                    val targetColorR = (r / maxChannel).coerceIn(0.15f, 2.0f)
                    val targetColorG = (g / maxChannel).coerceIn(0.15f, 2.0f)
                    val targetColorB = (b / maxChannel).coerceIn(0.15f, 2.0f)

                    lightColor[0] = lightColor[0] * 0.84f + targetColorR * 0.16f
                    lightColor[1] = lightColor[1] * 0.84f + targetColorG * 0.16f
                    lightColor[2] = lightColor[2] * 0.84f + targetColorB * 0.16f

                    val scalar =
                        (maxChannel * 0.55f)
                            .coerceIn(0.35f, 2.25f)
                    latestMainLightIntensity =
                        latestMainLightIntensity * 0.84f + scalar * 0.16f
                    latestLightIntensity = latestMainLightIntensity
                }
            } else {
                // Keep the previous ambient estimate when HDR is not yet valid.
                val intensity = estimate.pixelIntensity
                if (intensity.isFinite() && intensity > 0f) {
                    latestLightIntensity =
                        (latestLightIntensity * 0.85f + intensity * 0.15f)
                            .coerceIn(0.35f, 2.25f)
                    latestMainLightIntensity = latestLightIntensity
                }
            }

            val cameraPose = frame.camera.pose
            val t = cameraPose.translation
            viewPosition[0] = t[0]
            viewPosition[1] = t[1]
            viewPosition[2] = t[2]
        } catch (t: Throwable) {
            Log.v(TAG, "Environmental HDR lighting update skipped: ${t.message}")
        }
    }

    private fun buildMvp(
        model: FloatArray,
        frame: Frame,
    ) {
        frame.camera.getViewMatrix(viewMatrix, 0)
        frame.camera.getProjectionMatrix(
            projectionMatrix,
            0,
            0.01f,
            100f,
        )

        Matrix.multiplyMM(
            mvpMatrix,
            0,
            viewMatrix,
            0,
            model,
            0,
        )

        Matrix.multiplyMM(
            mvpMatrix,
            0,
            projectionMatrix,
            0,
            mvpMatrix,
            0,
        )
    }

    private fun updateTextureCoordinates(frame: Frame) {
        try {
            frame.transformCoordinates2d(
                Coordinates2d.OPENGL_NORMALIZED_DEVICE_COORDINATES,
                ndcCoords,
                Coordinates2d.TEXTURE_NORMALIZED,
                transformedTexCoords,
            )

            texCoords.position(0)
            texCoords.put(transformedTexCoords)
            texCoords.position(0)
        } catch (t: Throwable) {
            onError(
                "Camera texture transform error: ${t.message}",
            )
        }
    }

    private fun drawCamera() {
        GLES20.glDisable(GLES20.GL_DEPTH_TEST)
        GLES20.glDisable(GLES20.GL_BLEND)
        GLES20.glUseProgram(cameraProgram)

        quad.position(0)

        GLES20.glEnableVertexAttribArray(cameraPositionHandle)

        GLES20.glVertexAttribPointer(
            cameraPositionHandle,
            2,
            GLES20.GL_FLOAT,
            false,
            0,
            quad,
        )

        texCoords.position(0)

        GLES20.glEnableVertexAttribArray(cameraTexCoordHandle)

        GLES20.glVertexAttribPointer(
            cameraTexCoordHandle,
            2,
            GLES20.GL_FLOAT,
            false,
            0,
            texCoords,
        )

        GLES20.glActiveTexture(GLES20.GL_TEXTURE0)

        GLES20.glBindTexture(
            GLES11Ext.GL_TEXTURE_EXTERNAL_OES,
            cameraTextureId,
        )

        GLES20.glUniform1i(
            cameraTextureHandle,
            0,
        )

        GLES20.glDrawArrays(
            GLES20.GL_TRIANGLE_STRIP,
            0,
            4,
        )

        GLES20.glDisableVertexAttribArray(cameraPositionHandle)
        GLES20.glDisableVertexAttribArray(cameraTexCoordHandle)

        GLES20.glBindTexture(
            GLES11Ext.GL_TEXTURE_EXTERNAL_OES,
            0,
        )

        GLES20.glUseProgram(0)

        GLES20.glEnable(GLES20.GL_BLEND)
    }

    private fun createReticleVertices(): FloatBuffer {
        val segments = 40
        val data = FloatArray(segments * 3)

        for (index in 0 until segments) {
            val angle =
                (index.toFloat() / segments.toFloat()) *
                    (Math.PI.toFloat() * 2f)

            data[index * 3] =
                kotlin.math.cos(angle) * RETICLE_RADIUS_METERS
            data[index * 3 + 1] = 0f
            data[index * 3 + 2] =
                kotlin.math.sin(angle) * RETICLE_RADIUS_METERS
        }

        return floatBuffer(data)
    }

    private fun createExternalTexture(): Int {
        val textures = IntArray(1)

        GLES20.glGenTextures(
            1,
            textures,
            0,
        )

        val textureId = textures[0]

        GLES20.glBindTexture(
            GLES11Ext.GL_TEXTURE_EXTERNAL_OES,
            textureId,
        )

        GLES20.glTexParameteri(
            GLES11Ext.GL_TEXTURE_EXTERNAL_OES,
            GLES20.GL_TEXTURE_MIN_FILTER,
            GLES20.GL_LINEAR,
        )

        GLES20.glTexParameteri(
            GLES11Ext.GL_TEXTURE_EXTERNAL_OES,
            GLES20.GL_TEXTURE_MAG_FILTER,
            GLES20.GL_LINEAR,
        )

        GLES20.glTexParameteri(
            GLES11Ext.GL_TEXTURE_EXTERNAL_OES,
            GLES20.GL_TEXTURE_WRAP_S,
            GLES20.GL_CLAMP_TO_EDGE,
        )

        GLES20.glTexParameteri(
            GLES11Ext.GL_TEXTURE_EXTERNAL_OES,
            GLES20.GL_TEXTURE_WRAP_T,
            GLES20.GL_CLAMP_TO_EDGE,
        )

        GLES20.glBindTexture(
            GLES11Ext.GL_TEXTURE_EXTERNAL_OES,
            0,
        )

        return textureId
    }

    private fun createProgram(
        vertexSource: String,
        fragmentSource: String,
    ): Int {
        val vertexShader =
            compileShader(
                GLES20.GL_VERTEX_SHADER,
                vertexSource,
            )

        val fragmentShader =
            compileShader(
                GLES20.GL_FRAGMENT_SHADER,
                fragmentSource,
            )

        val program = GLES20.glCreateProgram()

        if (program == 0) {
            throw IllegalStateException(
                "Unable to create OpenGL program",
            )
        }

        GLES20.glAttachShader(program, vertexShader)
        GLES20.glAttachShader(program, fragmentShader)
        GLES20.glLinkProgram(program)

        val status = IntArray(1)

        GLES20.glGetProgramiv(
            program,
            GLES20.GL_LINK_STATUS,
            status,
            0,
        )

        if (status[0] == 0) {
            val log = GLES20.glGetProgramInfoLog(program)

            GLES20.glDeleteProgram(program)

            throw IllegalStateException(
                "AR shader link failed: $log",
            )
        }

        GLES20.glDeleteShader(vertexShader)
        GLES20.glDeleteShader(fragmentShader)

        return program
    }

    private fun compileShader(
        type: Int,
        source: String,
    ): Int {
        val shader = GLES20.glCreateShader(type)

        if (shader == 0) {
            throw IllegalStateException(
                "Unable to create OpenGL shader",
            )
        }

        GLES20.glShaderSource(shader, source)
        GLES20.glCompileShader(shader)

        val status = IntArray(1)

        GLES20.glGetShaderiv(
            shader,
            GLES20.GL_COMPILE_STATUS,
            status,
            0,
        )

        if (status[0] == 0) {
            val log = GLES20.glGetShaderInfoLog(shader)

            GLES20.glDeleteShader(shader)

            throw IllegalStateException(
                "AR shader compile failed: $log",
            )
        }

        return shader
    }

    private fun checkGlError(operation: String) {
        val error = GLES20.glGetError()

        if (error != GLES20.GL_NO_ERROR) {
            onError(
                "$operation OpenGL error: 0x${
                    Integer.toHexString(error)
                }",
            )
        }
    }

    fun dispose() {
        objectAnchor?.detach()
        objectAnchor = null
        resetAnchorStabilizer()
        session = null
        cameraTextureBoundToSession = false
        reticlePose = null
        reticleVisible = false
        depthReady = false
        depthTextureReady = false
        depthOcclusionTransformReady = false
        depthTextureWidth = 0
        depthTextureHeight = 0
        lastDepthTextureUploadMs = 0L
        depthTextureBuffer = null
        latestSpatialSnapshot = null
        latestFusedScene = null
        lastSpatialFusionMs = 0L
        lastDepthSampleMs = 0L
        lastHitTestMs = 0L
        lastPlaneScanMs = 0L
        lastDepthDiagnosticLogMs = 0L

        if (depthDiagnosticProgram != 0) {
            try {
                GLES20.glDeleteProgram(depthDiagnosticProgram)
            } catch (_: Throwable) {
            }
            depthDiagnosticProgram = 0
        }

        visionEngine.close()
    }

    private fun floatBuffer(data: FloatArray): FloatBuffer {
        return ByteBuffer
            .allocateDirect(data.size * 4)
            .order(ByteOrder.nativeOrder())
            .asFloatBuffer()
            .apply {
                put(data)
                position(0)
            }
    }
}
