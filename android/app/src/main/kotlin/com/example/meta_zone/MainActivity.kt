package com.example.meta_zone

import android.os.Bundle
import com.learntoflutter.flutter_embed_unity_android.unity.FakeUnityPlayerActivity
import io.flutter.embedding.engine.FlutterEngine
import com.example.meta_zone.ar.NativeArPlatformFactory

class MainActivity : FakeUnityPlayerActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory(
                NativeArPlatformFactory.VIEW_TYPE,
                NativeArPlatformFactory(
                    this,
                    flutterEngine.dartExecutor.binaryMessenger,
                )
            )
    }
}
