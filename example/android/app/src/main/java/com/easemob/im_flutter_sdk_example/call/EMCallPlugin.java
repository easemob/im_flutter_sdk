package com.easemob.im_flutter_sdk_example.call;

import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;

import androidx.annotation.NonNull;

import com.easemob.im_flutter_sdk.EMSDKMethod;
import com.easemob.im_flutter_sdk.EMWrapper;
import com.easemob.im_flutter_sdk_example.receiver.CallReceiver;
import com.hyphenate.chat.EMCallManager;
import com.hyphenate.chat.EMCallOptions;
import com.hyphenate.chat.EMCallSession;
import com.hyphenate.chat.EMCallStateChangeListener;
import com.hyphenate.chat.EMClient;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.JSONMethodCodec;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class EMCallPlugin implements FlutterPlugin, MethodChannel.MethodCallHandler,EMWrapper{
    static final String CALL = "com.easemob.im/em_call_manager";
    static MethodChannel channel;
    private Context activity;
    private CallReceiver callReceiver;
    private EMCallManager emCallManager;
    private EMCallSession callSession;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getFlutterEngine().getDartExecutor(), CALL, JSONMethodCodec.INSTANCE);
        activity = binding.getApplicationContext();
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        channel = null;
    }

    static void registerWith(PluginRegistry.Registrar registrar) {
        channel = new MethodChannel(registrar.messenger(), CALL , JSONMethodCodec.INSTANCE);
        EMCallPlugin imCallPlugin = new EMCallPlugin();
        channel.setMethodCallHandler(imCallPlugin);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall methodCall, @NonNull MethodChannel.Result result) {
        if (emCallManager == null){
            emCallManager = EMClient.getInstance().callManager();
            registerStateListener();
        }
        Intent intent = null;
        JSONObject argMap = (JSONObject) methodCall.arguments;
            if (methodCall.method.equals(EMSDKMethod.setCallOptions)){
                setCallOptions(argMap);
            }else if(methodCall.method.equals(EMSDKMethod.startCall)){
                try {
                    if (argMap.getInt("callType") == 1){
                        intent = new Intent(activity, VideoCallActivity.class);
                        try {
                            intent.putExtra("username",argMap.getString("remoteName"));
                            intent.putExtra("isComingCall",false);
                            if (!argMap.getString("ext").isEmpty() && null != argMap.getString("ext")){
                                intent.putExtra("ext",argMap.getString("ext"));
                            }
                            intent.putExtra("record",argMap.getBoolean("record"));
                            intent.putExtra("mergeStream",argMap.getBoolean("mergeStream"));
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                        activity.startActivity(intent);
                    }else {
                        intent = new Intent(activity, VoiceCallActivity.class);
                        try {
                            intent.putExtra("username",argMap.getString("remoteName"));
                            intent.putExtra("isComingCall",false);
                            if (!argMap.getString("ext").isEmpty() && null != argMap.getString("ext")){
                                intent.putExtra("ext",argMap.getString("ext"));
                            }
                            intent.putExtra("record",argMap.getBoolean("record"));
                            intent.putExtra("mergeStream",argMap.getBoolean("mergeStream"));
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                        activity.startActivity(intent);
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }

            }else if (methodCall.method.equals(EMSDKMethod.registerCallReceiver)){
                IntentFilter callFilter = new IntentFilter(EMClient.getInstance().callManager().getIncomingCallBroadcastAction());
                if (callReceiver == null){
                    callReceiver = new CallReceiver();
                }
                activity.registerReceiver(callReceiver,callFilter);
            }
            else if (methodCall.method.equals(EMSDKMethod.getCallId)){
                if (callSession != null){ getCallId(result); }
            }else if (methodCall.method.equals(EMSDKMethod.getConnectType)){
                if (callSession != null){ getConnectType(result); }
            }else if (methodCall.method.equals(EMSDKMethod.getExt)){
                if (callSession != null){ getExt(result); }
            }else if (methodCall.method.equals(EMSDKMethod.getLocalName)){
                if (callSession != null){ getLocalName(result); }
            }else if (methodCall.method.equals(EMSDKMethod.getRemoteName)){
                if (callSession != null){ getRemoteName(result); }
            }else if (methodCall.method.equals(EMSDKMethod.getServerRecordId)){
                if (callSession != null){ getServerRecordId(result); }
            }else if (methodCall.method.equals(EMSDKMethod.getCallType)){
                if (callSession != null){ getCallType(result); }
            }else if (methodCall.method.equals(EMSDKMethod.isRecordOnServer)){
                if (callSession != null){ isRecordOnServer(result); }
            }
    }

    private void setCallOptions(JSONObject jsonObject) {
        EMCallOptions callOptions = emCallManager.getCallOptions();
        try {   //不为默认值再去设置
            if (jsonObject.getInt("pingInterval") != 30){
                callOptions.setPingInterval(jsonObject.getInt("pingInterval"));
            }
            if (jsonObject.getInt("maxVideoKbps") != 0){
                callOptions.setMaxVideoKbps(jsonObject.getInt("maxVideoKbps"));
            }
            if (jsonObject.getInt("minVideoKbps") != 0){
                callOptions.setMinVideoKbps(jsonObject.getInt("minVideoKbps"));
            }
            if (jsonObject.getInt("maxVideoFrameRate") != 0){
                callOptions.setMaxVideoFrameRate(jsonObject.getInt("maxVideoFrameRate"));
            }
            if (jsonObject.getInt("maxAudioKbps") != 0){
                callOptions.setMaxAudioKbps(jsonObject.getInt("maxAudioKbps"));
            }
            if (!jsonObject.getBoolean("userSetAutoResizing")){
                callOptions.enableFixedVideoResolution(jsonObject.getBoolean("userSetAutoResizing"));
            }
            if (jsonObject.getBoolean("isSendPushIfOffline")){
                callOptions.setIsSendPushIfOffline(jsonObject.getBoolean("isSendPushIfOffline"));
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    public void registerStateListener(){
        EMCallStateChangeListener callStateListener = new EMCallStateChangeListener() {
            @Override
            public void onCallStateChanged(CallState callState, CallError error) {
                switch (callState) {
                    case CONNECTING: // is connecting
                        post(new Runnable() {
                            @Override
                            public void run() {
                            Map<String, Object> data = new HashMap<String, Object>();
                            data.put("type",EMSDKMethod.callStatusConnecting);
                            channel.invokeMethod(EMSDKMethod.onCallChanged,data);
                            }});
                        callSession = EMClient.getInstance().callManager().getCurrentCallSession();
                        break;
                    case CONNECTED: // connected
                        post(new Runnable() {
                            @Override
                            public void run() {
                            Map<String, Object> data = new HashMap<String, Object>();
                            data.put("type",EMSDKMethod.callStatusConnected);
                            channel.invokeMethod(EMSDKMethod.onCallChanged,data);
                            }});
                        break;
                    case ACCEPTED: // call is accepted
                        post(new Runnable() {
                            @Override
                            public void run() {
                            Map<String, Object> data = new HashMap<String, Object>();
                            data.put("type",EMSDKMethod.callStatusAccepted);
                            channel.invokeMethod(EMSDKMethod.onCallChanged,data);
                        }});
                        break;
                    case NETWORK_DISCONNECTED:
                        post(new Runnable() {
                            @Override
                            public void run() {
                            Map<String, Object> data = new HashMap<String, Object>();
                            data.put("type",EMSDKMethod.netWorkDisconnected);
                            channel.invokeMethod(EMSDKMethod.onCallChanged,data);
                            }});
                        break;
                    case NETWORK_UNSTABLE:
                        post(new Runnable() {
                            @Override
                            public void run() {
                            Map<String, Object> data = new HashMap<String, Object>();
                            data.put("type",EMSDKMethod.netWorkUnstable);
                            channel.invokeMethod(EMSDKMethod.onCallChanged,data);
                        }});
                        break;
                    case NETWORK_NORMAL:
                        post(new Runnable() {
                            @Override
                            public void run() {
                            Map<String, Object> data = new HashMap<String, Object>();
                            data.put("type",EMSDKMethod.netWorkNormal);
                            channel.invokeMethod(EMSDKMethod.onCallChanged,data);
                            }});
                        break;
                    case  VIDEO_PAUSE:
                        post(new Runnable() {
                            @Override
                            public void run() {
                            Map<String, Object> data = new HashMap<String, Object>();
                            data.put("type",EMSDKMethod.netVideoPause);
                            channel.invokeMethod(EMSDKMethod.onCallChanged,data);
                        }});
                        break;
                    case VIDEO_RESUME:
                        post(new Runnable() {
                            @Override
                            public void run() {
                            Map<String, Object> data = new HashMap<String, Object>();
                            data.put("type",EMSDKMethod.netVideoResume);
                            channel.invokeMethod(EMSDKMethod.onCallChanged,data);
                            }});
                        break;
                    case VOICE_PAUSE:
                        post(new Runnable() {
                            @Override
                            public void run() {
                            Map<String, Object> data = new HashMap<String, Object>();
                            data.put("type",EMSDKMethod.netVoicePause);
                            channel.invokeMethod(EMSDKMethod.onCallChanged,data);
                        }});
                        break;
                    case VOICE_RESUME:
                        post(new Runnable() {
                            @Override
                            public void run() {
                            Map<String, Object> data = new HashMap<String, Object>();
                            data.put("type",EMSDKMethod.netVoiceResume);
                            channel.invokeMethod(EMSDKMethod.onCallChanged,data);
                            }});
                        break;
                    case DISCONNECTED:
                        post(new Runnable() {
                            @Override
                            public void run() {
                            Map<String, Object> data = new HashMap<String, Object>();
                            data.put("type",EMSDKMethod.callStatusDisconnected);
                            data.put("reason",EndReasonToInt(error));
                            channel.invokeMethod(EMSDKMethod.onCallChanged,data);
                        }});
                        break;
                }
            }
        };
        emCallManager.addCallStateChangeListener(callStateListener);
    }

    private int EndReasonToInt(EMCallStateChangeListener.CallError error){
        switch (error){
            case ERROR_NONE:
                return 0;
            case ERROR_NORESPONSE:
                return 1;
            case REJECTED:
                return 2;
            case ERROR_BUSY:
                return 3;
            case ERROR_TRANSPORT:
                return 4;
            case ERROR_UNAVAILABLE:
                return 5;
            case ERROR_SERVICE_NOT_ENABLE:
                return 101;
            case ERROR_SERVICE_ARREARAGES:
                return 102;
            case ERROR_SERVICE_FORBIDDEN:
                return 103;
            default:
                break;
        }
        return -1;
    }

    private void getCallId(MethodChannel.Result result){
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.TRUE);
        data.put("value", callSession.getCallId());
        result.success(data);
    }

    private void getConnectType(MethodChannel.Result result){
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.TRUE);
        if (callSession.getConnectType() == EMCallSession.ConnectType.NONE){
            data.put("value", 0);
        }else if (callSession.getConnectType() == EMCallSession.ConnectType.DIRECT){
            data.put("value", 1);
        }else if (callSession.getConnectType() == EMCallSession.ConnectType.RELAY){
            data.put("value", 2);
        }
        result.success(data);
    }

    private void getExt(MethodChannel.Result result){
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.TRUE);
        data.put("value", callSession.getExt());
        result.success(data);
    }

    private void getLocalName(MethodChannel.Result result){
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.TRUE);
        data.put("value", callSession.getLocalName());
        result.success(data);
    }

    private void getRemoteName(MethodChannel.Result result){
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.TRUE);
        data.put("value", callSession.getRemoteName());
        result.success(data);
    }

    private void getServerRecordId(MethodChannel.Result result){
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.TRUE);
        data.put("value", callSession.getServerRecordId());
        result.success(data);
    }

    private void getCallType(MethodChannel.Result result){
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.TRUE);
        if (callSession.getType() == EMCallSession.Type.VOICE){
            data.put("value", 0);
        }else {
            data.put("value", 1);
        }
        result.success(data);
    }

    private void isRecordOnServer(MethodChannel.Result result){
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.TRUE);
        data.put("value", callSession.isRecordOnServer());
        result.success(data);
    }
}
