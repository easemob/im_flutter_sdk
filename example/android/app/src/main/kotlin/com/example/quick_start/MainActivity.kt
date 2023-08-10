package com.example.quick_start


import android.content.Context
import android.os.Bundle
import android.os.PersistableBundle
import android.util.AttributeSet
import android.view.ActionMode
import android.view.View
import com.easemob.im_flutter_sdk.ImFlutterSdkPlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import java.util.*


class MainActivity: FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val task: TimerTask = object : TimerTask() {
            override fun run() {
                testCode();
            }
        }
        val timer = Timer()
        timer.schedule(task, 3000)
    }

    fun testCode() {
//        if (flutterEngine?.plugins?.has(ImFlutterSdkPlugin::class.java) == true){
//            var p = flutterEngine?.plugins?.get(ImFlutterSdkPlugin::class.java) as ImFlutterSdkPlugin
//            p.sendDataToFlutter(mapOf("key" to "Value"));
//        }
    }
 }
