package com.easemob.im_flutter_sdk.view;

import android.content.Context;

import com.hyphenate.media.EMCallSurfaceView;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class EMFlutterReaderViewFactory extends PlatformViewFactory {

    static EMFlutterReaderViewFactory factory = null;

    private BinaryMessenger messenger;
    private Map<String, EMFlutterRenderView> localViewMap;
    private Map<String, EMFlutterRenderView> remoteViewMap;


    static public EMFlutterReaderViewFactory factoryWithRegistrar(Registrar registrar, String factoryId) {
        if (factory == null) {
            factory = new EMFlutterReaderViewFactory(registrar.messenger());
            registrar.platformViewRegistry().registerViewFactory(factoryId, factory);
        }
        return factory;
    }

    public EMCallSurfaceView getLocalViewWithId(int viewId) {
        String key = String.valueOf(viewId);
        EMFlutterRenderView view = localViewMap.get(key);

        return (EMCallSurfaceView)view.getView();
    }

    public EMCallSurfaceView getRemoteViewWithId(int viewId) {
        String key = String.valueOf(viewId);
        EMFlutterRenderView view = remoteViewMap.get(key);

        return (EMCallSurfaceView)view.getView();
    }

    public void releaseView(int viewId) {
        String key = String.valueOf(viewId);
        localViewMap.remove(key);
        remoteViewMap.remove(key);
    }

    private EMFlutterReaderViewFactory(BinaryMessenger messenger) {
        super(StandardMessageCodec.INSTANCE);
        this.messenger = messenger;
        this.localViewMap = new HashMap<>();
        this.remoteViewMap = new HashMap<>();
    }


    @Override
    public PlatformView create(Context context, int viewId, Object args) {
        HashMap params = (HashMap) args;
        int tag = (int)params.get("tag");
        EMFlutterRenderViewType type = tag == 0 ? EMFlutterRenderViewType.Local : EMFlutterRenderViewType.Remote;
        EMFlutterRenderView view = new EMFlutterRenderView(context, messenger, viewId, type);
        switch (type) {
            case Local: localViewMap.put(String.valueOf(viewId), view); break;
            case Remote: remoteViewMap.put(String.valueOf(viewId), view); break;
        }
        return view;
    }
}
