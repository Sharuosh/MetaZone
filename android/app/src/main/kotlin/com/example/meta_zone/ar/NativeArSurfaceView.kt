package com.example.meta_zone.ar

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.opengl.GLSurfaceView
import android.util.Log
import android.view.MotionEvent
import android.view.SurfaceHolder
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.google.ar.core.ArCoreApk
import com.google.ar.core.Config
import com.google.ar.core.Session

class NativeArSurfaceView(
    context: Context,
    private val activity: Activity,
    private val visionMode: Boolean = false,
) : GLSurfaceView(context) {

    companion object {
        const val CAMERA_PERMISSION_REQUEST = 9101
        private const val TAG = "MetaZoneNativeAR"
        private const val PERMISSION_RETRY_DELAY_MS = 500L
    }

    @Volatile
    private var session: Session? = null

    @Volatile
    private var disposed = false

    private val renderer =
        NativeArRenderer(
            context = context,
            onError = { error ->
                Log.e(TAG, error)
            },
            visionMode = visionMode,
        )

    init {
        setEGLContextClientVersion(2)
        setPreserveEGLContextOnPause(true)
        setRenderer(renderer)
        renderMode = RENDERMODE_CONTINUOUSLY
        isFocusable = true
        isFocusableInTouchMode = true

        holder.addCallback(
            object : SurfaceHolder.Callback {
                override fun surfaceCreated(holder: SurfaceHolder) {
                    disposed = false
                    post {
                        startArIfReady()
                    }
                }

                override fun surfaceChanged(
                    holder: SurfaceHolder,
                    format: Int,
                    width: Int,
                    height: Int,
                ) {
                    if (width <= 0 || height <= 0) return

                    try {
                        session?.setDisplayGeometry(
                            display.rotation,
                            width,
                            height,
                        )
                    } catch (t: Throwable) {
                        Log.e(
                            TAG,
                            "Failed to update AR display geometry",
                            t,
                        )
                    }
                }

                override fun surfaceDestroyed(holder: SurfaceHolder) {
                    pauseAr()
                }
            },
        )
    }

    override fun onTouchEvent(event: MotionEvent): Boolean {
        if (disposed) return false

        when (event.actionMasked) {
            MotionEvent.ACTION_DOWN -> {
                return true
            }

            MotionEvent.ACTION_UP -> {
                renderer.requestPlacement(
                    event.x,
                    event.y,
                )
                performClick()
                return true
            }
        }

        return true
    }

    override fun performClick(): Boolean {
        super.performClick()
        return true
    }

    private fun startArIfReady() {
        if (disposed) return

        if (
            ContextCompat.checkSelfPermission(
                activity,
                Manifest.permission.CAMERA,
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            ActivityCompat.requestPermissions(
                activity,
                arrayOf(Manifest.permission.CAMERA),
                CAMERA_PERMISSION_REQUEST,
            )

            postDelayed(
                {
                    if (!disposed) {
                        startArIfReady()
                    }
                },
                PERMISSION_RETRY_DELAY_MS,
            )

            return
        }

        if (session != null) {
            resumeAr()
            return
        }

        try {
            val installStatus =
                ArCoreApk
                    .getInstance()
                    .requestInstall(
                        activity,
                        true,
                    )

            if (
                installStatus ==
                    ArCoreApk.InstallStatus.INSTALL_REQUESTED
            ) {
                Log.d(
                    TAG,
                    "ARCore installation requested",
                )
                return
            }

            val newSession = Session(activity)

            val config =
                Config(newSession).apply {
                    planeFindingMode =
                        Config.PlaneFindingMode.HORIZONTAL_AND_VERTICAL

                    lightEstimationMode =
                        Config.LightEstimationMode.ENVIRONMENTAL_HDR

                    focusMode =
                        Config.FocusMode.AUTO

                    // Depth is required by MetaZone's real per-pixel
                    // occlusion pipeline. Keep AR working with a clear
                    // diagnostic when the device cannot expose Depth.
                    if (newSession.isDepthModeSupported(
                            Config.DepthMode.AUTOMATIC,
                        )
                    ) {
                        depthMode = Config.DepthMode.AUTOMATIC
                        Log.d(TAG, "ARCore Depth API enabled")
                    } else {
                        depthMode = Config.DepthMode.DISABLED
                        Log.d(
                            TAG,
                            "ARCore Depth API not supported; occlusion unavailable",
                        )
                    }
                }

            newSession.configure(config)

            session = newSession
            renderer.attachSession(newSession)

            if (width > 0 && height > 0) {
                newSession.setDisplayGeometry(
                    display.rotation,
                    width,
                    height,
                )
            }

            newSession.resume()

            Log.d(
                TAG,
                "ARCore session started successfully",
            )
        } catch (t: Throwable) {
            Log.e(
                TAG,
                "AR initialization failed",
                t,
            )
        }
    }

    /**
     * Returns the latest normalized VisionScene as Flutter-safe values.
     *
     * The renderer owns the real scene; this method only exposes its current
     * snapshot and does not start inference or touch the camera.
     */
    fun currentVisionSnapshot(): Map<String, Any> =
        renderer.latestVisionSnapshot()

    fun onCameraPermissionResult(granted: Boolean) {
        if (disposed) return

        if (granted) {
            post {
                startArIfReady()
            }
        } else {
            Log.e(
                TAG,
                "Camera permission denied",
            )
        }
    }

    private fun resumeAr() {
        if (disposed) return

        try {
            session?.resume()

            Log.d(
                TAG,
                "AR session resumed",
            )
        } catch (t: Throwable) {
            Log.e(
                TAG,
                "AR resume failed",
                t,
            )
        }
    }

    private fun pauseAr() {
        try {
            session?.pause()

            Log.d(
                TAG,
                "AR session paused",
            )
        } catch (t: Throwable) {
            Log.e(
                TAG,
                "AR pause failed",
                t,
            )
        }
    }

    fun onDispose() {
        if (disposed) return
        disposed = true

        try {
            onPause()
        } catch (_: Throwable) {
        }

        try {
            session?.pause()
        } catch (_: Throwable) {
        }

        try {
            session?.close()
        } catch (_: Throwable) {
        }

        session = null

        queueEvent {
            try {
                renderer.dispose()
            } catch (_: Throwable) {
            }
        }
    }
}
