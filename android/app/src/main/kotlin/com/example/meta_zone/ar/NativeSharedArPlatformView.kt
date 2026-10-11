package com.example.meta_zone.ar

import android.app.Activity
import android.content.Context
import android.view.View
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import io.flutter.view.TextureRegistry

class NativeSharedArPlatformView(
    context: Context,
    viewId: Int,
    messenger: BinaryMessenger,
    textureRegistry: TextureRegistry,
) : PlatformView,
    EventChannel.StreamHandler,
    MethodChannel.MethodCallHandler {

    private val activity: Activity =
        findActivity(context)
            ?: throw IllegalStateException(
                "Unable to find Activity from PlatformView context"
            )

    private val surfaceView =
        NativeSharedArSurfaceView(
            context = context,
            activity = activity,
            textureRegistry = textureRegistry,
        )

    private val eventChannel =
        EventChannel(
            messenger,
            "metazone/shared_ar/events/$viewId",
        )

    private val methodChannel =
        MethodChannel(
            messenger,
            "metazone/shared_ar/methods/$viewId",
        )

    init {
        eventChannel.setStreamHandler(this)
        methodChannel.setMethodCallHandler(this)
    }

    override fun getView(): View {
        return surfaceView
    }

    override fun onListen(
        arguments: Any?,
        events: EventChannel.EventSink?,
    ) {
        surfaceView.eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        surfaceView.eventSink = null
    }

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        when (call.method) {

            "getTextureId" -> {
                result.success(
                    surfaceView.getTextureId()
                )
            }

            "getTrackingState" -> {
                result.success(
                    surfaceView.currentTrackingSnapshot()
                )
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    override fun dispose() {
        eventChannel.setStreamHandler(null)
        methodChannel.setMethodCallHandler(null)
        surfaceView.disposeAr()
    }

    private fun findActivity(
        context: Context,
    ): Activity? {

        var currentContext = context

        while (currentContext is android.content.ContextWrapper) {

            if (currentContext is Activity) {
                return currentContext
            }

            val baseContext =
                currentContext.baseContext

            if (baseContext === currentContext) {
                break
            }

            currentContext = baseContext
        }

        return null
    }
}