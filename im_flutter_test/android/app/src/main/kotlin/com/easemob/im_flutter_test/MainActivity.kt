package com.easemob.im_flutter_test

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.FlutterPlugin

class MainActivity : FlutterActivity() {
    private var testControlBridge: TestControlBridge? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // 4.23 / 5.0 统一使用生产 Wrapper（im_flutter_sdk_android）；410/414 旧路径已移除
        val plugin = Class
            .forName("com.easemob.im_flutter_sdk.ImFlutterSdkPlugin")
            .getDeclaredConstructor()
            .newInstance() as FlutterPlugin
        flutterEngine.plugins.add(plugin)
        testControlBridge = TestControlBridge(
            this,
            flutterEngine.dartExecutor.binaryMessenger,
        )
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        testControlBridge?.dispose()
        testControlBridge = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
    }
}
