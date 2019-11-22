package com.easemob.im_flutter_sdk_example;

import android.annotation.TargetApi;
import android.os.Bundle;

import com.easemob.im_flutter_sdk_example.runtimepermissions.PermissionsManager;
import com.easemob.im_flutter_sdk_example.runtimepermissions.PermissionsResultAction;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    requestPermissions();
  }

  @TargetApi(23)
  private void requestPermissions() {
    PermissionsManager.getInstance().requestAllManifestPermissionsIfNecessary(this, new PermissionsResultAction() {
      @Override
      public void onGranted() {
//				Toast.makeText(MainActivity.this, "All permissions have been granted", Toast.LENGTH_SHORT).show();
      }

      @Override
      public void onDenied(String permission) {
        //Toast.makeText(MainActivity.this, "Permission " + permission + " has been denied", Toast.LENGTH_SHORT).show();
      }
    });
  }
}
