package com.easemob.im_flutter_sdk_example.model;

import android.os.Build;
import android.view.WindowManager;

public class EaseCompat {

    public static int getSupportedWindowType() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            return WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY;
        } else {
            return WindowManager.LayoutParams.TYPE_SYSTEM_ALERT;
        }
    }
}
