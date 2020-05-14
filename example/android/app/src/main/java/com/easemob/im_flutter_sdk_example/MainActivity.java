package com.easemob.im_flutter_sdk_example;

import android.annotation.TargetApi;
import android.os.Bundle;

import androidx.annotation.NonNull;

import com.easemob.im_flutter_sdk_example.call.EMCallPlugin;
import com.easemob.im_flutter_sdk_example.conference.EMConferencePlugin;
import com.easemob.im_flutter_sdk_example.runtimepermissions.PermissionsManager;
import com.easemob.im_flutter_sdk_example.runtimepermissions.PermissionsResultAction;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;

public class MainActivity extends FlutterActivity {

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    super.configureFlutterEngine(flutterEngine);
    registerCustomPlugin(flutterEngine);
  }

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    requestPermissions();
  }

  private void registerCustomPlugin(FlutterEngine flutterEngine) {
    flutterEngine.getPlugins().add(new ImDemoPlugin());
    flutterEngine.getPlugins().add(new EMCallPlugin());
    flutterEngine.getPlugins().add(new EMConferencePlugin());
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
