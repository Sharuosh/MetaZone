package com.example.meta_zone.ar

import android.app.Activity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class NativeArPlatformFactory(
    private val activity: Activity,
    private val messenger: BinaryMessenger,
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    companion object {
        const val VIEW_TYPE = "metazone/native_ar_view"
    }

    override fun create(
        context: android.content.Context,
        viewId: Int,
        args: Any?,
    ): PlatformView {

        val creationArgs = args as? Map<*, *>

        val visionMode =
            when {
                creationArgs?.get("visionMode") is Boolean ->
                    creationArgs["visionMode"] as Boolean

                creationArgs?.get("mode") is String ->
                    (creationArgs["mode"] as String) == "sense"

                else ->
                    false
            }

        return NativeArPlatformView(
            activity = activity,
            viewId = viewId,
            messenger = messenger,
            visionMode = visionMode,
        )
    }
}