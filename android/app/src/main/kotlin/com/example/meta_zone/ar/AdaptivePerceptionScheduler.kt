package com.example.meta_zone.ar

import android.app.ActivityManager
import android.content.Context
import android.os.Build
import android.util.Log
import java.util.concurrent.atomic.AtomicLong

/**
 * Adaptive perception scheduler for MetaZone.
 *
 * Goals:
 * - Keep AR rendering and tracking responsive.
 * - Never run more than one ML job at a time.
 * - Give realtime tracking priority.
 * - Make snapshot/label workloads much less aggressive.
 * - Automatically back off when inference becomes expensive.
 */
class AdaptivePerceptionScheduler(
    context: Context,
) {

    enum class Job {
        TRACK,
        MULTI_OBJECT,
        LABELS,
        NONE,
    }

    enum class Tier {
        HIGH,
        BALANCED,
        CONSERVATIVE,
    }

    companion object {
        private const val TAG = "MetaZoneScheduler"

        private const val NANOS_PER_MS = 1_000_000L

        /*
         * Base intervals.
         *
         * Tracking remains the primary perception primitive.
         * Snapshot and whole-image labeling are intentionally sparse.
         */
        private const val HIGH_TRACK_MS = 320L
        private const val HIGH_MULTI_MS = 4_500L
        private const val HIGH_LABEL_MS = 7_000L

        private const val BALANCED_TRACK_MS = 420L
        private const val BALANCED_MULTI_MS = 6_000L
        private const val BALANCED_LABEL_MS = 9_000L

        private const val CONSERVATIVE_TRACK_MS = 600L
        private const val CONSERVATIVE_MULTI_MS = 9_000L
        private const val CONSERVATIVE_LABEL_MS = 12_000L

        /*
         * Dynamic backoff.
         *
         * When ML inference becomes expensive, temporarily widen the
         * tracking interval instead of continuously feeding work into
         * the device.
         */
        private const val SOFT_HEAVY_JOB_MS = 260L
        private const val HARD_HEAVY_JOB_MS = 420L

        private const val SOFT_BACKOFF_MS = 250L
        private const val HARD_BACKOFF_MS = 700L

        private const val MAX_BACKOFF_MS = 1_200L

        /*
         * Do not allow snapshot jobs immediately after expensive tracking.
         */
        private const val POST_HEAVY_GUARD_MS = 450L
    }

    private val appContext = context.applicationContext
    private val tier = detectTier()

    private val lastTrackNs = AtomicLong(0L)
    private val lastMultiNs = AtomicLong(0L)
    private val lastLabelNs = AtomicLong(0L)

    @Volatile
    private var thermalThrottle = false

    @Volatile
    private var lastJob: Job = Job.NONE

    @Volatile
    private var dynamicBackoffMs = 0L

    @Volatile
    private var lastHeavyCompletionNs = 0L

    fun tier(): Tier = tier

    fun setThermalThrottle(enabled: Boolean) {
        thermalThrottle = enabled

        if (enabled) {
            dynamicBackoffMs =
                dynamicBackoffMs
                    .coerceAtLeast(HARD_BACKOFF_MS)
                    .coerceAtMost(MAX_BACKOFF_MS)
        }
    }

    /**
     * Returns at most one perception job.
     *
     * Priority:
     * 1. TRACK
     * 2. MULTI_OBJECT
     * 3. LABELS
     *
     * Tracking always wins because it is the most useful realtime signal.
     */
    fun chooseJob(
        nowNs: Long = System.nanoTime(),
        frameNumber: Long,
    ): Job {

        /*
         * frameNumber intentionally participates in the decision path so
         * the scheduler remains deterministic with respect to the AR loop.
         */
        if (frameNumber < 0L) {
            return Job.NONE
        }

        /*
         * Thermal mode:
         * only tracking survives, and it is slowed down.
         */
        if (thermalThrottle) {
            val thermalTrackInterval =
                (
                    trackIntervalMs() * 2L +
                        dynamicBackoffMs
                    ).coerceAtMost(
                        1_800L,
                    )

            if (
                isDue(
                    nowNs = nowNs,
                    lastNs = lastTrackNs,
                    intervalMs = thermalTrackInterval,
                )
            ) {
                lastTrackNs.set(nowNs)
                lastJob = Job.TRACK
                return Job.TRACK
            }

            return Job.NONE
        }

        /*
         * Main realtime tracker.
         *
         * Dynamic backoff is applied only to tracking. This allows AR
         * perception to automatically become lighter on stressed devices.
         */
        val effectiveTrackInterval =
            (
                trackIntervalMs() +
                    dynamicBackoffMs
                ).coerceAtMost(
                    1_800L,
                )

        if (
            isDue(
                nowNs = nowNs,
                lastNs = lastTrackNs,
                intervalMs = effectiveTrackInterval,
            )
        ) {
            lastTrackNs.set(nowNs)
            lastJob = Job.TRACK
            return Job.TRACK
        }

        /*
         * Snapshot jobs must wait after a heavy inference.
         *
         * This prevents the sequence:
         * TRACK -> MULTI_OBJECT -> LABELS
         * from creating a burst of expensive work.
         */
        val sinceHeavyCompletionMs =
            if (lastHeavyCompletionNs == 0L) {
                Long.MAX_VALUE
            } else {
                (nowNs - lastHeavyCompletionNs) /
                    NANOS_PER_MS
            }

        if (
            sinceHeavyCompletionMs >= POST_HEAVY_GUARD_MS &&
            isDue(
                nowNs = nowNs,
                lastNs = lastMultiNs,
                intervalMs = multiIntervalMs(),
            )
        ) {
            lastMultiNs.set(nowNs)
            lastJob = Job.MULTI_OBJECT
            return Job.MULTI_OBJECT
        }

        if (
            sinceHeavyCompletionMs >= POST_HEAVY_GUARD_MS &&
            isDue(
                nowNs = nowNs,
                lastNs = lastLabelNs,
                intervalMs = labelIntervalMs(),
            )
        ) {
            lastLabelNs.set(nowNs)
            lastJob = Job.LABELS
            return Job.LABELS
        }

        return Job.NONE
    }

    /**
     * Called when a perception job completes.
     *
     * Expensive jobs cause temporary adaptive backoff.
     */
    fun noteJobCompleted(
        job: Job,
        durationMs: Long,
    ) {
        if (job == Job.NONE) return

        val nowNs = System.nanoTime()
        lastHeavyCompletionNs = nowNs

        when {
            durationMs >= HARD_HEAVY_JOB_MS -> {
                dynamicBackoffMs =
                    (
                        dynamicBackoffMs +
                            HARD_BACKOFF_MS
                        ).coerceAtMost(
                            MAX_BACKOFF_MS,
                        )

                Log.d(
                    TAG,
                    "Hard backoff job=$job " +
                        "duration=${durationMs}ms " +
                        "backoff=${dynamicBackoffMs}ms " +
                        "tier=$tier",
                )
            }

            durationMs >= SOFT_HEAVY_JOB_MS -> {
                dynamicBackoffMs =
                    (
                        dynamicBackoffMs +
                            SOFT_BACKOFF_MS
                        ).coerceAtMost(
                            MAX_BACKOFF_MS,
                        )

                Log.d(
                    TAG,
                    "Soft backoff job=$job " +
                        "duration=${durationMs}ms " +
                        "backoff=${dynamicBackoffMs}ms " +
                        "tier=$tier",
                )
            }

            else -> {
                /*
                 * Slowly recover toward the normal schedule after cheap jobs.
                 */
                dynamicBackoffMs =
                    (
                        dynamicBackoffMs - 100L
                        ).coerceAtLeast(
                            0L,
                        )
            }
        }

        /*
         * Only print normal completion logs for genuinely expensive work.
         */
        if (durationMs >= SOFT_HEAVY_JOB_MS) {
            Log.d(
                TAG,
                "Perception job=$job " +
                    "duration=${durationMs}ms " +
                    "backoff=${dynamicBackoffMs}ms " +
                    "tier=$tier",
            )
        }
    }

    /**
     * Renderer-side helper.
     */
    fun shouldYield(
        lastFrameDurationMs: Long,
    ): Boolean =
        lastFrameDurationMs >=
            when (tier) {
                Tier.HIGH -> 55L
                Tier.BALANCED -> 45L
                Tier.CONSERVATIVE -> 35L
            }

    private fun trackIntervalMs(): Long =
        when (tier) {
            Tier.HIGH -> HIGH_TRACK_MS
            Tier.BALANCED -> BALANCED_TRACK_MS
            Tier.CONSERVATIVE -> CONSERVATIVE_TRACK_MS
        }

    private fun multiIntervalMs(): Long =
        when (tier) {
            Tier.HIGH -> HIGH_MULTI_MS
            Tier.BALANCED -> BALANCED_MULTI_MS
            Tier.CONSERVATIVE -> CONSERVATIVE_MULTI_MS
        }

    private fun labelIntervalMs(): Long =
        when (tier) {
            Tier.HIGH -> HIGH_LABEL_MS
            Tier.BALANCED -> BALANCED_LABEL_MS
            Tier.CONSERVATIVE -> CONSERVATIVE_LABEL_MS
        }

    private fun isDue(
        nowNs: Long,
        lastNs: AtomicLong,
        intervalMs: Long,
    ): Boolean {
        val previous = lastNs.get()

        if (previous == 0L) {
            return true
        }

        val elapsedMs =
            (nowNs - previous) /
                NANOS_PER_MS

        return elapsedMs >= intervalMs
    }

    private fun detectTier(): Tier {
        val activityManager =
            appContext.getSystemService(
                Context.ACTIVITY_SERVICE,
            ) as? ActivityManager

        val memoryInfo =
            ActivityManager.MemoryInfo()

        try {
            activityManager?.getMemoryInfo(
                memoryInfo,
            )
        } catch (_: Throwable) {
        }

        val availableRamMb =
            memoryInfo.totalMem
                .coerceAtLeast(0L) /
                (1024L * 1024L)

        val cores =
            Runtime.getRuntime()
                .availableProcessors()
                .coerceAtLeast(1)

        /*
         * Device tier is only the initial budget.
         * Runtime backoff remains responsible for adapting to actual load.
         */
        val detected =
            when {
                availableRamMb >= 7_000L &&
                    cores >= 8 ->
                    Tier.HIGH

                availableRamMb >= 5_000L &&
                    cores >= 6 ->
                    Tier.BALANCED

                else ->
                    Tier.CONSERVATIVE
            }

        Log.d(
            TAG,
            "Perception tier=$detected " +
                "ram=${availableRamMb}MB " +
                "cores=$cores " +
                "sdk=${Build.VERSION.SDK_INT}",
        )

        return detected
    }
}