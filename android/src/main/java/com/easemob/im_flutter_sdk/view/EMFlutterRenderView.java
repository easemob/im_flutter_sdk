package com.easemob.im_flutter_sdk.view;

import android.content.Context;
import android.view.View;

import com.hyphenate.media.EMCallSurfaceView;
import com.superrtc.sdk.VideoView;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.platform.PlatformView;


enum EMFlutterRenderViewType {
    Local, Remote
}


public class EMFlutterRenderView implements PlatformView {

    private EMCallSurfaceView _androidView;

    EMFlutterRenderView(Context context, BinaryMessenger messenger, int viewId, EMFlutterRenderViewType type) {
        switch (type) {
            case Local:
            {
                createLocalView(context ,viewId);
            }
            case Remote:
            {
                createRemoteView(context ,viewId);
            }
        }
    }

    private void createLocalView(Context context, int viewId) {
        EMCallSurfaceView view = new EMCallSurfaceView(context);
        view.setScaleMode(VideoView.EMCallViewScaleMode.EMCallViewScaleModeAspectFill);
        _androidView = view;
    }

    private void createRemoteView(Context context, int viewId) {
        EMCallSurfaceView view = new EMCallSurfaceView(context);
        view.setScaleMode(VideoView.EMCallViewScaleMode.EMCallViewScaleModeAspectFill);
        _androidView = view;
    }

    @Override
    public View getView() {
        return _androidView;
    }

    @Override
    public void dispose() {
        _androidView = null;
    }
}
