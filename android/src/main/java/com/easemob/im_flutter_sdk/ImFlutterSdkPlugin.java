package com.easemob.im_flutter_sdk;

import android.os.Handler;
import android.os.Looper;

import com.hyphenate.EMCallBack;
import com.hyphenate.EMValueCallBack;
import com.hyphenate.chat.EMChatRoom;
import com.hyphenate.chat.EMCursorResult;
import com.hyphenate.chat.EMGroup;
import com.hyphenate.chat.EMMucSharedFile;
import com.hyphenate.chat.EMPageResult;
import com.hyphenate.exceptions.HyphenateException;
import com.hyphenate.util.EMLog;

import io.flutter.plugin.common.JSONMethodCodec;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.MethodChannel.Result;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.function.Consumer;


/**
 * ImFlutterSdkPlugin
 */
@SuppressWarnings("unchecked")
public class ImFlutterSdkPlugin {
    private static final String CHANNEL_PREFIX = "com.easemob.im";
    static final Handler handler = new Handler(Looper.getMainLooper());

    private ImFlutterSdkPlugin() {
    }

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        registerClientWith(registrar);
        registerChatManagerWith(registrar);
        registerContactManagerWith(registrar);
        registerConversationWith(registrar);
        registerEMChatRoomManagerWrapper(registrar);
        registerGroupManagerWith(registrar);
        registerPushManagerWith(registrar);
    }

    public static void registerClientWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL_PREFIX + "/em_client", JSONMethodCodec.INSTANCE);
        channel.setMethodCallHandler(new EMClientWrapper(registrar.context(), channel));
    }

    public static void registerChatManagerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL_PREFIX + "/em_chat_manager", JSONMethodCodec.INSTANCE);
        channel.setMethodCallHandler(new EMChatManagerWrapper(channel));
    }

    public static void registerContactManagerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL_PREFIX + "/em_contact_manager", JSONMethodCodec.INSTANCE);
        channel.setMethodCallHandler(new EMContactManagerWrapper(channel));
    }

    public static void registerConversationWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL_PREFIX + "/em_conversation", JSONMethodCodec.INSTANCE);
        channel.setMethodCallHandler(new EMConversationWrapper());
    }

    public static void registerEMChatRoomManagerWrapper(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL_PREFIX + "/em_chat_room_manager", JSONMethodCodec.INSTANCE);
        channel.setMethodCallHandler(new EMChatRoomManagerWrapper(channel));
    }

    public static void registerGroupManagerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL_PREFIX + "/em_group_manager", JSONMethodCodec.INSTANCE);
        channel.setMethodCallHandler(new EMGroupManagerWrapper(channel));
    }

    public static void registerPushManagerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL_PREFIX + "/em_push_manager", JSONMethodCodec.INSTANCE);
        channel.setMethodCallHandler(new EMPushManagerWrapper());
    }

}

@SuppressWarnings("unchecked")
class EMWrapperCallBack implements EMCallBack {

    EMWrapperCallBack(Result result) {
        this.result = result;
    }

    private Result result;

    void post(Runnable runnable) {
        ImFlutterSdkPlugin.handler.post(runnable);
    }

    @Override
    public void onSuccess() {
        post(new Runnable() {
                 @Override
                 public void run() {
                     Map<String, Object> data = new HashMap<String, Object>();
                     data.put("success", Boolean.TRUE);
                     EMLog.e("callback", "onSuccess");
                     result.success(data);
                 }
             }
        );
    }

    @Override
    public void onError(int code, String desc) {
        post(new Runnable() {
            @Override
            public void run() {
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("success", Boolean.FALSE);
                data.put("code", code);
                data.put("desc", desc);
                EMLog.e("callback", "onError");
                result.success(data);
            }
        });
    }

    @Override
    public void onProgress(int progress, String status) {
        // no need
    }
}

@SuppressWarnings("unchecked")
class EMValueWrapperCallBack<T> implements EMValueCallBack<T> {

    EMValueWrapperCallBack(MethodChannel.Result result) {
        this.result = result;
    }

    private MethodChannel.Result result;

    void post(Runnable runnable) {
        ImFlutterSdkPlugin.handler.post(runnable);
    }

    @Override
    public void onSuccess(Object value) {
        post(new Runnable() {
                 @Override
                 public void run() {
                     Map<String, Object> data = new HashMap<String, Object>();
                     data.put("success", Boolean.TRUE);
                     if (value.getClass().getSimpleName().equals("ArrayList")) {
                         if (((List) value).size() > 0) {
                             Object o = ((List) value).get(0);
                             if (o.getClass().getSimpleName().equals("EMGroup")) {
                                 List<Map<String, Object>> list = new LinkedList<Map<String, Object>>();
                                 for (EMGroup emGroup : (List<EMGroup>) value) {
                                     list.add(EMHelper.convertEMGroupToStringMap(emGroup));
                                 }
                                 data.put("value", list);
                             }

                             if (o.getClass().getSimpleName().equals("String")) {
                                 data.put("value", value);
                             }

                             if (o.getClass().getSimpleName().equals("EMMucSharedFile")) {
                                 List<Map<String, Object>> list = new LinkedList<Map<String, Object>>();
                                 for (EMMucSharedFile file : (List<EMMucSharedFile>) value) {
                                     list.add(EMHelper.convertEMMucSharedFileToStringMap(file));
                                 }
                                 data.put("value", list);
                             }
                         }
                     }

                     if (value.getClass().getSimpleName().equals("EMGroup")) {
                         data.put("value", EMHelper.convertEMGroupToStringMap((EMGroup) value));
                     }

                     if (value.getClass().getSimpleName().equals("EMCursorResult")) {
                         data.put("value", EMHelper.convertEMCursorResultToStringMap((EMCursorResult) value));
                     }

                     if (value.getClass().getSimpleName().equals("EMPageResult")) {
                         EMPageResult result = (EMPageResult) value;
                         if (((List) (result.getData())).get(0).getClass().getSimpleName().equals("EMChatRoom")) {
                             data.put("value", EMHelper.convertEMPageResultToStringMap(result));
                         }
                     }

                     if (value.getClass().getSimpleName().equals("EMChatRoom")) {
                         data.put("value", EMHelper.convertEMChatRoomToStringMap((EMChatRoom) value));
                     }

                     if (value.getClass().getSimpleName().equals("HashMap")) {
                         List<String> dataList = new LinkedList<String>();
                         for (Map.Entry<String, Long> m : ((Map<String, Long>) value).entrySet()) {
                             dataList.add(m.getKey());
                         }
                         data.put("value", dataList);
                     }

                     if (value.getClass().getSimpleName().equals("String")) {
                         data.put("value", value);
                     }

                     result.success(data);
                 }
             }
        );
    }

    @Override
    public void onError(int error, String errorMsg) {
        post(new Runnable() {
                 @Override
                 public void run() {
                     Map<String, Object> data = new HashMap<String, Object>();
                     data.put("success", Boolean.FALSE);
                     data.put("code", error);
                     data.put("desc", errorMsg);
                     result.success(data);
                 }
             }
        );
    }
}