package com.example.flutter_demo

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        flutterEngine?.let { NativeUtils.registerNativePlugin(it,context) }
    }
}