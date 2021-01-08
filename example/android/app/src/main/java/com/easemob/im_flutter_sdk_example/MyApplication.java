package com.easemob.im_flutter_sdk_example;

import androidx.multidex.MultiDex;

import io.flutter.app.FlutterApplication;

public class MyApplication extends FlutterApplication {

    @Override
    public void onCreate() {
        MultiDex.install(this);
        super.onCreate();
    }
}
