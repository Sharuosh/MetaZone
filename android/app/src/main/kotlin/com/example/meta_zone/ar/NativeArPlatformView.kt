package com.example.meta_zone.ar

import android.app.Activity
import android.graphics.Bitmap
import android.os.Handler
import android.os.HandlerThread
import android.os.Looper
import android.view.PixelCopy
import android.view.View
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import java.io.ByteArrayOutputStream
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import kotlin.math.roundToInt

/**
 * Flutter bridge for MetaZone Sense -> Vision.
 *
 * The existing NativeArSurfaceView remains the only ARCore camera surface.
 * Vision mode is read-only from the AR placement system:
 * no placement request, reticle, or AR object is created here.
 *
 * captureVisionFrame() uses Android PixelCopy to capture the already-rendered
 * ARCore surface. It does NOT create a second camera stack and does NOT call
 * ARCore frame acquisition from Flutter.
 */
class NativeArPlatformView(
    private val activity: Activity,
    viewId: Int,
    messenger: BinaryMessenger,
    private val visionMode: Boolean,
) : PlatformView, MethodChannel.MethodCallHandler {

    companion object {
        private const val CHANNEL_PREFIX =
            "metazone/native_ar/vision/methods/"

        private const val MAX_CAPTURE_DIMENSION = 1280
        private const val JPEG_QUALITY = 85
    }

    private val mainHandler =
        Handler(Looper.getMainLooper())

    private val captureHandlerThread =
        HandlerThread("MetaZoneVisionCapture").apply {
            start()
        }

    private val captureHandler =
        Handler(captureHandlerThread.looper)

    private val encodeExecutor: ExecutorService =
        Executors.newSingleThreadExecutor { runnable ->
            Thread(
                runnable,
                "MetaZoneVisionJpeg",
            ).apply {
                isDaemon = true
            }
        }

    private val arView =
        NativeArSurfaceView(
            context = activity,
            activity = activity,
            visionMode = visionMode,
        )

    private val visionChannel =
        MethodChannel(
            messenger,
            "$CHANNEL_PREFIX$viewId",
        )

    @Volatile
    private var disposed = false

    init {
        arView.isFocusable = true
        arView.isFocusableInTouchMode = true
        arView.isClickable = true
        visionChannel.setMethodCallHandler(this)
    }

    override fun getView(): View = arView

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        when (call.method) {
            "getVisionScene" -> {
                try {
                    result.success(
                        arView.currentVisionSnapshot(),
                    )
                } catch (t: Throwable) {
                    result.error(
                        "VISION_SCENE_ERROR",
                        t.message
                            ?: "Unable to read the latest Vision scene",
                        null,
                    )
                }
            }

            "getVisionMode" -> {
                result.success(visionMode)
            }

            "captureVisionFrame" -> {
                captureVisionFrame(result)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    /**
     * Captures one frame of the existing NativeArSurfaceView.
     *
     * Returns JPEG bytes through StandardMessageCodec so Flutter receives
     * them as Uint8List.
     */
    private fun captureVisionFrame(
        result: MethodChannel.Result,
    ) {
        if (!visionMode) {
            result.error(
                "VISION_ONLY_METHOD",
                "captureVisionFrame is available only in Sense Vision mode.",
                null,
            )
            return
        }

        if (disposed) {
            result.error(
                "VISION_DISPOSED",
                "Sense Vision view has already been disposed.",
                null,
            )
            return
        }

        if (!arView.isShown || !arView.isAttachedToWindow) {
            result.error(
                "VISION_SURFACE_UNAVAILABLE",
                "Sense Vision surface is not currently visible.",
                null,
            )
            return
        }

        val sourceWidth = arView.width
        val sourceHeight = arView.height

        if (sourceWidth <= 0 || sourceHeight <= 0) {
            result.error(
                "VISION_SURFACE_UNAVAILABLE",
                "Sense Vision surface has no valid size yet.",
                null,
            )
            return
        }

        val scale =
            minOf(
                1f,
                MAX_CAPTURE_DIMENSION.toFloat() /
                    maxOf(
                        sourceWidth,
                        sourceHeight,
                    ).toFloat(),
            )

        val bitmapWidth =
            (sourceWidth * scale)
                .roundToInt()
                .coerceAtLeast(1)

        val bitmapHeight =
            (sourceHeight * scale)
                .roundToInt()
                .coerceAtLeast(1)

        val destination =
            try {
                Bitmap.createBitmap(
                    bitmapWidth,
                    bitmapHeight,
                    Bitmap.Config.ARGB_8888,
                )
            } catch (t: Throwable) {
                result.error(
                    "VISION_BITMAP_ERROR",
                    t.message
                        ?: "Unable to allocate Vision capture bitmap.",
                    null,
                )
                return
            }

        mainHandler.post {
            if (disposed) {
                destination.recycle()
                result.error(
                    "VISION_DISPOSED",
                    "Sense Vision view has already been disposed.",
                    null,
                )
                return@post
            }

            try {
                PixelCopy.request(
                    arView,
                    destination,
                    { copyResult ->
                        if (copyResult != PixelCopy.SUCCESS) {
                            destination.recycle()

                            mainHandler.post {
                                result.error(
                                    "VISION_CAPTURE_ERROR",
                                    "PixelCopy failed with result=$copyResult.",
                                    null,
                                )
                            }

                            return@request
                        }

                        encodeExecutor.execute {
                            try {
                                val output =
                                    ByteArrayOutputStream(
                                        bitmapWidth * bitmapHeight / 3,
                                    )

                                val compressed =
                                    destination.compress(
                                        Bitmap.CompressFormat.JPEG,
                                        JPEG_QUALITY,
                                        output,
                                    )

                                destination.recycle()

                                if (!compressed) {
                                    mainHandler.post {
                                        result.error(
                                            "VISION_JPEG_ERROR",
                                            "Unable to encode the captured Vision frame.",
                                            null,
                                        )
                                    }
                                    return@execute
                                }

                                val bytes =
                                    output.toByteArray()

                                mainHandler.post {
                                    if (disposed) {
                                        result.error(
                                            "VISION_DISPOSED",
                                            "Sense Vision view was disposed during capture.",
                                            null,
                                        )
                                    } else {
                                        result.success(bytes)
                                    }
                                }
                            } catch (t: Throwable) {
                                try {
                                    destination.recycle()
                                } catch (_: Throwable) {
                                }

                                mainHandler.post {
                                    result.error(
                                        "VISION_JPEG_ERROR",
                                        t.message
                                            ?: "Unable to encode the captured Vision frame.",
                                        null,
                                    )
                                }
                            }
                        }
                    },
                    captureHandler,
                )
            } catch (t: Throwable) {
                destination.recycle()

                result.error(
                    "VISION_CAPTURE_ERROR",
                    t.message
                        ?: "Unable to request PixelCopy capture.",
                    null,
                )
            }
        }
    }

    override fun dispose() {
        disposed = true

        visionChannel.setMethodCallHandler(null)
        arView.onDispose()

        encodeExecutor.shutdownNow()

        captureHandler.removeCallbacksAndMessages(null)
        captureHandlerThread.quitSafely()
    }
}
