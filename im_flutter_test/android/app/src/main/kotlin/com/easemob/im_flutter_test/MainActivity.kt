package com.easemob.im_flutter_test

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.easemob.im_flutter_test/device"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getDevice" -> {
                        // 从启动参数 --es device <deviceA|deviceB|...> 读取，缺失默认 deviceA
                        val device = intent.getStringExtra("device") ?: "deviceA"
                        result.success(device)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
