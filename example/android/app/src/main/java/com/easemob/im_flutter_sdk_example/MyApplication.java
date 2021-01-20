package com.easemob.im_flutter_sdk_example;

import android.app.ActivityManager;
import android.content.Context;

import androidx.multidex.MultiDex;

import com.heytap.msp.push.HeytapPushManager;

import io.flutter.app.FlutterApplication;

public class MyApplication extends FlutterApplication {

    @Override
    public void onCreate() {
        MultiDex.install(this);
        if(isMainProcess(this)){
            //OPPO SDK升级到2.1.0后需要进行初始化
            HeytapPushManager.init(this, true);
        }
        super.onCreate();
    }

    public boolean isMainProcess(Context context) {
        int pid = android.os.Process.myPid();
        ActivityManager activityManager = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
        for (ActivityManager.RunningAppProcessInfo appProcess : activityManager.getRunningAppProcesses()) {
            if (appProcess.pid == pid) {
                return context.getApplicationInfo().packageName.equals(appProcess.processName);
            }
        }
        return false;
    }
}
