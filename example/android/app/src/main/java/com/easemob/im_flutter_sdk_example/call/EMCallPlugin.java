package com.easemob.im_flutter_sdk_example.call;

import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import com.easemob.im_flutter_sdk.EMSDKMethod;
import com.easemob.im_flutter_sdk.EMWrapper;
import com.easemob.im_flutter_sdk_example.receiver.CallReceiver;
import com.hyphenate.chat.EMCallManager;
import com.hyphenate.chat.EMCallOptions;
import com.hyphenate.chat.EMCallSession;
import com.hyphenate.chat.EMCallStateChangeListener;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMConference;
import com.hyphenate.exceptions.EMServiceNotReadyException;
import com.hyphenate.exceptions.HyphenateException;

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

    private static MethodChannel.Result result;
    private static Handler handler = new Handler(Looper.getMainLooper());

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), CALL, JSONMethodCodec.INSTANCE);
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
        this.result = result;
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
                        intent.putExtra("username",argMap.getString("remoteName"));
                        intent.putExtra("isComingCall",false);
                        if (!argMap.getString("ext").isEmpty() && null != argMap.getString("ext")){
                            intent.putExtra("ext",argMap.getString("ext"));
                        }
                        intent.putExtra("record",argMap.getBoolean("record"));
                        intent.putExtra("mergeStream",argMap.getBoolean("mergeStream"));

                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                        activity.startActivity(intent);

                    }else {
                        intent = new Intent(activity, VoiceCallActivity.class);
                        intent.putExtra("username",argMap.getString("remoteName"));
                        intent.putExtra("isComingCall",false);
                        if (!argMap.getString("ext").isEmpty() && null != argMap.getString("ext")){
                            intent.putExtra("ext",argMap.getString("ext"));
                        }
                        intent.putExtra("record",argMap.getBoolean("record"));
                        intent.putExtra("mergeStream",argMap.getBoolean("mergeStream"));

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
              else if(methodCall.method.equals(EMSDKMethod.singleOpenVideoTransfer)){
                openVideoTransfer();
            } else if(methodCall.method.equals(EMSDKMethod.singleOpenVoiceTransfer)){
                openVoiceTransfer();
            } else if(methodCall.method.equals(EMSDKMethod.singleCloseVideoTransfer)){
                closeVideoTransfer();
            } else if(methodCall.method.equals(EMSDKMethod.singleCloseVoiceTransfer)){
                closeVoiceTransfer();
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
            if(jsonObject.getBoolean("isClarityFirst")){
                callOptions.setClarityFirst(jsonObject.getBoolean("isClarityFirst"));
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    public void registerStateListener(){
        EMCallStateChangeListener callStateListener = (callState, error) -> {
            EMCallSession session = EMClient.getInstance().callManager().getCurrentCallSession();
            switch (callState) {
                case CONNECTING: // is connecting
                    post(() -> {
                    Map<String, Object> data = new HashMap<>();
                    data.put("type",EMSDKMethod.callStatusConnecting);
                    if (session.getLocalName().length() > 0) {
                        data.put("localName", session.getLocalName());
                    }

                    if (session.getRemoteName().length() > 0) {
                        data.put("remoteName", session.getRemoteName());
                    }

                    if (session.getServerRecordId().length() > 0) {
                        data.put("serverVideoId", session.getServerRecordId());
                    }

                    if (session.getCallId().length() > 0) {
                        data.put("callId", session.getCallId());
                    }

                    if (session.getExt().length() > 0) {
                        data.put("callExt", session.getExt());
                    }

                    data.put("isRecordOnServer", Boolean.valueOf(session.isRecordOnServer()));

                    if (session.getType() == EMCallSession.Type.VOICE) {
                        data.put("callType", Integer.valueOf(0));
                    }else {
                        data.put("callType", Integer.valueOf(1));
                    }
                    channel.invokeMethod(EMSDKMethod.onCallChanged,data);
                 });

                    break;
                case CONNECTED: // connected
                    post(() -> {
                    Map<String, Object> data = new HashMap<>();
                    data.put("type",EMSDKMethod.callStatusConnected);
                    channel.invokeMethod(EMSDKMethod.onCallChanged,data);
                    });
                    break;
                case ACCEPTED: // call is accepted
                    post(() -> {
                        Map<String, Object> data = new HashMap<>();
                    data.put("type",EMSDKMethod.callStatusAccepted);
                    if (session.getServerRecordId().length() > 0) {
                        data.put("serverVideoId",session.getServerRecordId());
                    }

                    channel.invokeMethod(EMSDKMethod.onCallChanged,data);
                });
                    break;
                case NETWORK_DISCONNECTED:
                    post(() -> {
                    Map<String, Object> data = new HashMap<>();
                    data.put("type",EMSDKMethod.networkDisconnected);
                    channel.invokeMethod(EMSDKMethod.onCallChanged,data);
                    });
                    break;
                case NETWORK_UNSTABLE:
                    post(() -> {
                    Map<String, Object> data = new HashMap<>();
                    data.put("type",EMSDKMethod.networkUnstable);
                    channel.invokeMethod(EMSDKMethod.onCallChanged,data);
                });
                    break;
                case NETWORK_NORMAL:
                    post(() -> {
                    Map<String, Object> data = new HashMap<>();
                    data.put("type",EMSDKMethod.networkNormal);
                    channel.invokeMethod(EMSDKMethod.onCallChanged,data);
                    });
                    break;
                case  VIDEO_PAUSE:
                    post(() -> {
                    Map<String, Object> data = new HashMap<>();
                    data.put("type",EMSDKMethod.netVideoPause);
                    channel.invokeMethod(EMSDKMethod.onCallChanged,data);
                });
                    break;
                case VIDEO_RESUME:
                    post(() -> {
                    Map<String, Object> data = new HashMap<>();
                    data.put("type",EMSDKMethod.netVideoResume);
                    channel.invokeMethod(EMSDKMethod.onCallChanged,data);
                    });
                    break;
                case VOICE_PAUSE:
                    post(() -> {
                    Map<String, Object> data = new HashMap<>();
                    data.put("type",EMSDKMethod.netVoicePause);
                    channel.invokeMethod(EMSDKMethod.onCallChanged,data);
                });
                    break;
                case VOICE_RESUME:
                    post(() -> {
                    Map<String, Object> data = new HashMap<>();
                    data.put("type",EMSDKMethod.netVoiceResume);
                    channel.invokeMethod(EMSDKMethod.onCallChanged,data);
                    });
                    break;
                case DISCONNECTED:
                    post(() -> {
                    Map<String, Object> data = new HashMap<>();
                    data.put("type",EMSDKMethod.callStatusDisconnected);
                    data.put("reason",EndReasonToInt(error));
                    channel.invokeMethod(EMSDKMethod.onCallChanged,data);
                });
                    break;
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

    private void openVoiceTransfer() {
        try {
            emCallManager.resumeVoiceTransfer();
        } catch (HyphenateException e) {
            e.printStackTrace();
        }
    }

    private void openVideoTransfer() {
        try {
            emCallManager.resumeVideoTransfer();
        } catch (HyphenateException e) {
            e.printStackTrace();
        }
    }

    private void closeVoiceTransfer() {
        try {
            emCallManager.pauseVoiceTransfer();
        } catch (HyphenateException e) {
            e.printStackTrace();
        }
    }

    private void closeVideoTransfer() {
        try {
            emCallManager.pauseVideoTransfer();
        } catch (HyphenateException e) {
            e.printStackTrace();
        }
    }

    // public static void onResult(Map map){
    //     handler.post(() -> channel.invokeMethod(EMSDKMethod.getResult,map));
    // }
}
