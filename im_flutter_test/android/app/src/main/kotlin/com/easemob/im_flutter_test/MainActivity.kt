package com.easemob.im_flutter_test

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.FlutterPlugin

class MainActivity : FlutterActivity() {
    private var nativeSdkBridge: NativeSdkBridge? = null
    private var testControlBridge: TestControlBridge? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        if (BuildConfig.FLAVOR == "sdk423") {
            val plugin = Class
                .forName("com.easemob.im_flutter_sdk.ImFlutterSdkPlugin")
                .getDeclaredConstructor()
                .newInstance() as FlutterPlugin
            flutterEngine.plugins.add(plugin)
        } else {
            nativeSdkBridge = NativeSdkBridge(
                this,
                flutterEngine.dartExecutor.binaryMessenger,
            )
        }
        testControlBridge = TestControlBridge(
            this,
            flutterEngine.dartExecutor.binaryMessenger,
        )
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        testControlBridge?.dispose()
        testControlBridge = null
        nativeSdkBridge?.dispose()
        nativeSdkBridge = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
    }
}
