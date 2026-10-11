package com.example.meta_zone.ar

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.view.TextureRegistry

class NativeSharedArPlatformFactory(
    private val messenger: BinaryMessenger,
    private val textureRegistry: TextureRegistry,
) : PlatformViewFactory(null) {

    override fun create(
        context: Context,
        viewId: Int,
        args: Any?,
    ): PlatformView {

        return NativeSharedArPlatformView(
            context = context,
            viewId = viewId,
            messenger = messenger,
            textureRegistry = textureRegistry,
        )
    }
}