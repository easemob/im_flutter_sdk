package com.example.flutter_demo

import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class NativeUtils {
    companion object StaticParams {
        val CHANNEL = "com.example/native_plugin"
        fun registerNativePlugin(flutterEngine: FlutterEngine, context: Context) {
            MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result -> // TODO
                if (call.method == "getRandom") {
                    result.success(Math.random());
                }
            }
        }
    }
}