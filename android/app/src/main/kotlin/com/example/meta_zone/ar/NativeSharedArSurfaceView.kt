package com.example.meta_zone.ar

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.graphics.Color
import android.graphics.SurfaceTexture
import android.hardware.camera2.CameraCaptureSession
import android.hardware.camera2.CameraDevice
import android.hardware.camera2.CameraManager
import android.os.Handler
import android.os.HandlerThread
import android.view.Surface
import android.opengl.GLSurfaceView
import android.widget.FrameLayout
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.google.ar.core.ArCoreApk
import com.google.ar.core.Config
import com.google.ar.core.Session
import com.google.ar.core.TrackingState
import io.flutter.plugin.common.EventChannel
import io.flutter.view.TextureRegistry
import java.util.EnumSet
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicBoolean
import javax.microedition.khronos.egl.EGLConfig
import javax.microedition.khronos.opengles.GL10
import android.opengl.GLES11Ext
import android.opengl.GLES20

class NativeSharedArSurfaceView(
    context: Context,
    private val activity: Activity,
    private val textureRegistry: TextureRegistry,
) : FrameLayout(context) {

    companion object {
        const val CAMERA_PERMISSION_REQUEST = 9201

        private const val TAG = "MetaZoneSharedAR"
        private const val UPDATE_EVENT_MS = 50L
        private const val FLUTTER_TEXTURE_WIDTH = 1280
        private const val FLUTTER_TEXTURE_HEIGHT = 720
    }

    // ============================================================
    // CAMERA
    // ============================================================

    private val cameraManager =
        activity.getSystemService(Context.CAMERA_SERVICE) as CameraManager

    private val cameraThread =
        HandlerThread("MetaZoneSharedAR-Camera").apply {
            start()
        }

    private val cameraHandler =
        Handler(cameraThread.looper)

    // ============================================================
    // ARCORE
    // ============================================================

    @Volatile
    private var sharedSession: Session? = null

    @Volatile
    private var sharedCamera: com.google.ar.core.SharedCamera? = null

    // ============================================================
    // CAMERA2
    // ============================================================

    @Volatile
    private var cameraDevice: CameraDevice? = null

    @Volatile
    private var captureSession: CameraCaptureSession? = null

    @Volatile
    private var previewRequest:
        android.hardware.camera2.CaptureRequest? = null

    // ============================================================
    // FLUTTER TEXTURE
    // ============================================================

    private var textureEntry:
        TextureRegistry.SurfaceTextureEntry? = null

    private var flutterSurfaceTexture:
        SurfaceTexture? = null

    private var previewSurface:
        Surface? = null

    // ============================================================
    // OPENGL
    // ============================================================

    private val glSurfaceView =
    GLSurfaceView(context)

    private val glRenderer =
        ArCoreGlRenderer()

    @Volatile
    private var arCoreCameraTextureId = -1

    @Volatile
    private var glReady = false

    private val glReadyLatch =
        CountDownLatch(1)

    // ============================================================
    // STATE
    // ============================================================

    var eventSink: EventChannel.EventSink? = null

    private val ready =
        AtomicBoolean(false)

    @Volatile
    private var disposed = false

    private var lastTrackingEventNs = 0L

    // ============================================================
    // INIT
    // ============================================================

    init {
        setBackgroundColor(Color.TRANSPARENT)

        setupGlSurface()
        createFlutterTexture()

        // GL surface must exist for ARCore Session.update().
        post {
            if (!disposed) {
                startAr()
            }
        }
    }

    // ============================================================
    // OPENGL SETUP
    // ============================================================

    private fun setupGlSurface() {
        glSurfaceView.setEGLContextClientVersion(2)

        glSurfaceView.setRenderer(glRenderer)

        glSurfaceView.renderMode =
            GLSurfaceView.RENDERMODE_CONTINUOUSLY

        val glParams =
            LayoutParams(
                1,
                1,
            ).apply {
                leftMargin = 0
                topMargin = 0
            }

        glSurfaceView.alpha = 0f

        addView(
            glSurfaceView,
            glParams,
        )
    }

    // ============================================================
    // FLUTTER TEXTURE
    // ============================================================

    private fun createFlutterTexture() {
        val entry =
            textureRegistry.createSurfaceTexture()

        textureEntry = entry

        flutterSurfaceTexture =
            entry.surfaceTexture()

        flutterSurfaceTexture?.setDefaultBufferSize(
            FLUTTER_TEXTURE_WIDTH,
            FLUTTER_TEXTURE_HEIGHT,
        )

        previewSurface =
            flutterSurfaceTexture?.let {
                Surface(it)
            }

        emitEvent(
            mapOf(
                "type" to "texture_created",
                "textureId" to getTextureId(),
            ),
        )
    }

    fun getTextureId(): Long {
        return textureEntry?.id() ?: -1L
    }

    // ============================================================
    // START AR
    // ============================================================

    private fun startAr() {
        if (disposed || ready.get()) {
            return
        }

        if (
            ContextCompat.checkSelfPermission(
                activity,
                Manifest.permission.CAMERA,
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            ActivityCompat.requestPermissions(
                activity,
                arrayOf(
                    Manifest.permission.CAMERA,
                ),
                CAMERA_PERMISSION_REQUEST,
            )

            postDelayed(
                {
                    if (!disposed) {
                        startAr()
                    }
                },
                500,
            )

            return
        }

        cameraHandler.post {
            try {
                // ------------------------------------------------
                // ARCORE INSTALL CHECK
                // ------------------------------------------------

                val installStatus =
                    ArCoreApk
                        .getInstance()
                        .requestInstall(
                            activity,
                            true,
                        )

                if (
                    installStatus !=
                    ArCoreApk.InstallStatus.INSTALLED
                ) {
                    postDelayed(
                        {
                            if (!disposed) {
                                startAr()
                            }
                        },
                        700,
                    )

                    return@post
                }

                // ------------------------------------------------
                // SHARED CAMERA SESSION
                // ------------------------------------------------

                val session =
                    Session(
                        activity,
                        EnumSet.of(
                            Session.Feature.SHARED_CAMERA,
                        ),
                    )

                val config =
                    Config(session).apply {

                        planeFindingMode =
                            Config
                                .PlaneFindingMode
                                .HORIZONTAL_AND_VERTICAL

                        lightEstimationMode =
                            Config
                                .LightEstimationMode
                                .AMBIENT_INTENSITY

                        focusMode =
                            Config
                                .FocusMode
                                .AUTO
                    }

                session.configure(config)

                sharedSession = session
                sharedCamera =
                    session.sharedCamera

                // ------------------------------------------------
                // IMPORTANT
                //
                // ARCore Session.update() requires a GL context.
                // Wait until the GL thread has created the
                // ARCore external texture and attached it to
                // the session before opening Camera2.
                // ------------------------------------------------

                attachSessionToGlAndWait(session)

                if (disposed) {
                    return@post
                }

                openCamera(
                    session.cameraConfig.cameraId,
                )
            } catch (t: Throwable) {
                emitEvent(
                    mapOf(
                        "type" to "error",
                        "message" to (
                            t.message
                                ?: "AR initialization failed"
                            ),
                    ),
                )
            }
        }
    }

    // ============================================================
    // ATTACH ARCORE SESSION TO GL
    // ============================================================

    private fun attachSessionToGlAndWait(
        session: Session,
    ) {
        if (glReady) {
            try {
                glSurfaceView.queueEvent {
                    try {
                        if (arCoreCameraTextureId != -1) {
                            session.setCameraTextureName(
                                arCoreCameraTextureId,
                            )
                        }
                    } catch (t: Throwable) {
                        emitEvent(
                            mapOf(
                                "type" to "error",
                                "message" to (
                                    t.message
                                        ?: "Failed to attach ARCore GL texture"
                                    ),
                            ),
                        )
                    }
                }

                return
            } catch (_: Throwable) {
                // Fall through to normal latch handling.
            }
        }

        try {
            glReadyLatch.await(
                2500,
                TimeUnit.MILLISECONDS,
            )
        } catch (_: InterruptedException) {
            Thread.currentThread().interrupt()
            return
        }

        if (disposed) {
            return
        }

        glSurfaceView.queueEvent {
            try {
                if (arCoreCameraTextureId != -1) {
                    session.setCameraTextureName(
                        arCoreCameraTextureId,
                    )
                }
            } catch (t: Throwable) {
                emitEvent(
                    mapOf(
                        "type" to "error",
                        "message" to (
                            t.message
                                ?: "Failed to set ARCore camera texture"
                            ),
                    ),
                )
            }
        }
    }

    // ============================================================
    // CAMERA2 OPEN
    // ============================================================

    private fun openCamera(
        cameraId: String,
    ) {
        if (
            ActivityCompat.checkSelfPermission(
                activity,
                Manifest.permission.CAMERA,
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            return
        }

        val callback =
            object : CameraDevice.StateCallback() {

                override fun onOpened(
                    camera: CameraDevice,
                ) {
                    if (disposed) {
                        camera.close()
                        return
                    }

                    cameraDevice = camera

                    createCaptureSession()
                }

                override fun onDisconnected(
                    camera: CameraDevice,
                ) {
                    camera.close()

                    cameraDevice = null

                    ready.set(false)

                    emitEvent(
                        mapOf(
                            "type" to "error",
                            "message" to
                                "Camera disconnected",
                        ),
                    )
                }

                override fun onError(
                    camera: CameraDevice,
                    error: Int,
                ) {
                    camera.close()

                    cameraDevice = null

                    ready.set(false)

                    emitEvent(
                        mapOf(
                            "type" to "error",
                            "message" to
                                "Camera error: $error",
                        ),
                    )
                }
            }

        val wrappedCallback =
            sharedCamera
                ?.createARDeviceStateCallback(
                    callback,
                    cameraHandler,
                )
                ?: return

        try {
            cameraManager.openCamera(
                cameraId,
                wrappedCallback,
                cameraHandler,
            )
        } catch (t: Throwable) {
            emitEvent(
                mapOf(
                    "type" to "error",
                    "message" to (
                        t.message
                            ?: "Failed to open camera"
                        ),
                ),
            )
        }
    }

    // ============================================================
    // CAMERA CAPTURE SESSION
    // ============================================================

    private fun createCaptureSession() {
        val device =
            cameraDevice ?: return

        val session =
            sharedSession ?: return

        val shared =
            sharedCamera ?: return

        val flutterSurface =
            previewSurface ?: return

        cameraHandler.post {
            if (disposed) {
                return@post
            }

            try {
                // ------------------------------------------------
                // ARCORE SURFACES
                // ------------------------------------------------

                val surfaces =
                    ArrayList(
                        shared.arCoreSurfaces,
                    )

                // ------------------------------------------------
                // FLUTTER SURFACE
                // ------------------------------------------------

                if (
                    !surfaces.contains(
                        flutterSurface,
                    )
                ) {
                    surfaces.add(
                        flutterSurface,
                    )
                }

                val callback =
                    object :
                        CameraCaptureSession.StateCallback() {

                        override fun onConfigured(
                            configuredSession:
                                CameraCaptureSession,
                        ) {
                            if (disposed) {
                                configuredSession.close()
                                return
                            }

                            captureSession =
                                configuredSession

                            try {
                                // --------------------------------
                                // BUILD CAMERA REQUEST
                                // --------------------------------

                                val requestBuilder =
                                    device.createCaptureRequest(
                                        CameraDevice
                                            .TEMPLATE_RECORD,
                                    )

                                surfaces.forEach {
                                    requestBuilder.addTarget(
                                        it,
                                    )
                                }

                                previewRequest =
                                    requestBuilder.build()

                                // --------------------------------
                                // START CAMERA
                                // --------------------------------

                                configuredSession.setRepeatingRequest(
                                    previewRequest!!,
                                    null,
                                    cameraHandler,
                                )

                                // --------------------------------
                                // START ARCORE
                                // --------------------------------

                                session.resume()

                                ready.set(true)

                                emitEvent(
                                    mapOf(
                                        "type" to "ready",
                                        "textureId" to
                                            getTextureId(),
                                        "cameraId" to
                                            session
                                                .cameraConfig
                                                .cameraId,
                                        "textureWidth" to
                                            session
                                                .cameraConfig
                                                .textureSize
                                                .width,
                                        "textureHeight" to
                                            session
                                                .cameraConfig
                                                .textureSize
                                                .height,
                                    ),
                                )
                            } catch (t: Throwable) {
                                ready.set(false)

                                emitEvent(
                                    mapOf(
                                        "type" to "error",
                                        "message" to (
                                            t.message
                                                ?: "Failed to start camera capture"
                                            ),
                                    ),
                                )
                            }
                        }

                        override fun onConfigureFailed(
                            failedSession:
                                CameraCaptureSession,
                        ) {
                            ready.set(false)

                            emitEvent(
                                mapOf(
                                    "type" to "error",
                                    "message" to
                                        "Camera capture session configuration failed",
                                ),
                            )
                        }
                    }

                val wrappedCallback =
                    shared.createARSessionStateCallback(
                        callback,
                        cameraHandler,
                    )

                device.createCaptureSession(
                    surfaces,
                    wrappedCallback,
                    cameraHandler,
                )
            } catch (t: Throwable) {
                ready.set(false)

                emitEvent(
                    mapOf(
                        "type" to "error",
                        "message" to (
                            t.message
                                ?: "Failed to create capture session"
                            ),
                    ),
                )
            }
        }
    }

    // ============================================================
    // TRACKING
    // ============================================================

    /**
     * IMPORTANT:
     *
     * session.update() is NOT called here.
     *
     * It is called from ArCoreGlRenderer.onDrawFrame(),
     * which runs while an EGL/OpenGL context is active.
     */
    private fun emitTrackingEvent(
        session: Session,
        frame: com.google.ar.core.Frame,
    ) {
        val now =
            System.nanoTime()

        if (
            now -
                lastTrackingEventNs <
            UPDATE_EVENT_MS * 1_000_000L
        ) {
            return
        }

        lastTrackingEventNs = now

        try {
            val camera =
                frame.camera

            val pose =
                camera.pose

            val planeCount =
                session
                    .getAllTrackables(
                        com.google.ar.core.Plane::class.java,
                    )
                    .count {
                        it.trackingState ==
                            TrackingState.TRACKING
                    }

            emitEvent(
                mapOf(
                    "type" to "tracking",
                    "trackingState" to
                        camera.trackingState.name,
                    "failureReason" to
                        camera.trackingFailureReason.name,
                    "planeCount" to
                        planeCount,
                    "timestampNanos" to
                        frame.timestamp,
                    "cameraPose" to
                        listOf(
                            pose.tx(),
                            pose.ty(),
                            pose.tz(),
                            pose.qx(),
                            pose.qy(),
                            pose.qz(),
                            pose.qw(),
                        ),
                ),
            )
        } catch (t: Throwable) {
            emitEvent(
                mapOf(
                    "type" to "tracking_error",
                    "message" to (
                        t.message
                            ?: "Tracking event failed"
                        ),
                ),
            )
        }
    }

    // ============================================================
    // SNAPSHOT
    // ============================================================

    fun currentTrackingSnapshot():
        Map<String, Any?> {

        return mapOf(
            "ready" to
                ready.get(),

            "sharedCamera" to
                (sharedCamera != null),

            "textureId" to
                getTextureId(),

            "glReady" to
                glReady,
        )
    }

    // ============================================================
    // EVENTS
    // ============================================================

    fun emitEvent(
        event: Map<String, Any?>,
    ) {
        post {
            eventSink?.success(event)
        }
    }

    // ============================================================
    // DISPOSE
    // ============================================================

    fun disposeAr() {
        if (disposed) {
            return
        }

        disposed = true

        ready.set(false)

        // Stop GL rendering first.
        try {
            glSurfaceView.queueEvent {
                try {
                    sharedSession?.pause()
                } catch (_: Throwable) {
                }
            }
        } catch (_: Throwable) {
        }

        cameraHandler.post {

            // --------------------------------------------
            // CAMERA CAPTURE
            // --------------------------------------------

            try {
                captureSession?.stopRepeating()
            } catch (_: Throwable) {
            }

            try {
                captureSession?.abortCaptures()
            } catch (_: Throwable) {
            }

            try {
                captureSession?.close()
            } catch (_: Throwable) {
            }

            captureSession = null

            // --------------------------------------------
            // CAMERA DEVICE
            // --------------------------------------------

            try {
                cameraDevice?.close()
            } catch (_: Throwable) {
            }

            cameraDevice = null

            // --------------------------------------------
            // ARCORE
            // --------------------------------------------

            try {
                sharedSession?.pause()
            } catch (_: Throwable) {
            }

            try {
                sharedSession?.close()
            } catch (_: Throwable) {
            }

            sharedSession = null
            sharedCamera = null

            // --------------------------------------------
            // FLUTTER SURFACE
            // --------------------------------------------

            try {
                previewSurface?.release()
            } catch (_: Throwable) {
            }

            previewSurface = null

            flutterSurfaceTexture = null

            // --------------------------------------------
            // FLUTTER TEXTURE ENTRY
            // --------------------------------------------

            try {
                textureEntry?.release()
            } catch (_: Throwable) {
            }

            textureEntry = null

            // --------------------------------------------
            // CAMERA THREAD
            // --------------------------------------------

            cameraThread.quitSafely()
        }

        // --------------------------------------------
        // GL VIEW
        // --------------------------------------------

        try {
            glSurfaceView.onPause()
        } catch (_: Throwable) {
        }
    }

    // ============================================================
    // ARCORE GL RENDERER
    // ============================================================

    private inner class ArCoreGlRenderer :
        GLSurfaceView.Renderer {

        override fun onSurfaceCreated(
            gl: GL10?,
            config: EGLConfig?,
        ) {
            try {
                val textureIds =
                    IntArray(1)

                GLES20.glGenTextures(
                    1,
                    textureIds,
                    0,
                )

                arCoreCameraTextureId =
                    textureIds[0]

                GLES20.glBindTexture(
                    GLES11Ext.GL_TEXTURE_EXTERNAL_OES,
                    arCoreCameraTextureId,
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

                glReady = true

                glReadyLatch.countDown()

                // If Session already exists, attach it now.
                sharedSession?.let { session ->

                    try {
                        session.setCameraTextureName(
                            arCoreCameraTextureId,
                        )
                    } catch (t: Throwable) {
                        emitEvent(
                            mapOf(
                                "type" to "error",
                                "message" to (
                                    t.message
                                        ?: "Failed to bind ARCore camera texture"
                                    ),
                            ),
                        )
                    }
                }
            } catch (t: Throwable) {
                emitEvent(
                    mapOf(
                        "type" to "error",
                        "message" to (
                            t.message
                                ?: "Failed to create GL texture"
                            ),
                    ),
                )
            }
        }

        override fun onSurfaceChanged(
            gl: GL10?,
            width: Int,
            height: Int,
        ) {
            GLES20.glViewport(
                0,
                0,
                width,
                height,
            )
        }

        override fun onDrawFrame(
            gl: GL10?,
        ) {
            if (disposed) {
                return
            }

            if (!ready.get()) {
                return
            }

            val session =
                sharedSession ?: return

            try {
                /**
                 * THIS is the critical part.
                 *
                 * session.update() now runs on the
                 * GLSurfaceView GL thread, where an EGL
                 * context is active.
                 */
                val frame =
                    session.update()

                emitTrackingEvent(
                    session,
                    frame,
                )
            } catch (t: Throwable) {

                emitEvent(
                    mapOf(
                        "type" to "tracking_error",
                        "message" to (
                            t.message
                                ?: "ARCore frame update failed"
                            ),
                    ),
                )
            }
        }
    }
}