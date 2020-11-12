package com.easemob.im_flutter_sdk;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Color;

import com.easemob.im_flutter_sdk.view.EMFlutterReaderViewFactory;
import com.hyphenate.chat.EMCallSession;
import com.hyphenate.chat.EMCallStateChangeListener;
import com.hyphenate.chat.EMClient;
import com.hyphenate.exceptions.EMNoActiveCallException;
import com.hyphenate.exceptions.EMServiceNotReadyException;
import com.hyphenate.exceptions.HyphenateException;
import com.hyphenate.media.EMCallSurfaceView;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.JSONMethodCodec;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;

public class EMCallManagerWrapper extends EMWrapper implements MethodChannel.MethodCallHandler, EMCallReceiverListener{

    private MethodChannel callSessionChannel;
    private EMCallReceiver callReceiver;
    private EMFlutterReaderViewFactory factory;

    private int _currentLocalViewId;
    private int _currentRemoteViewId;

    EMCallManagerWrapper(PluginRegistry.Registrar registrar, String channelName) {
        super(registrar, channelName);
        registrar.context().registerReceiver(
                new EMCallReceiver(this),
                new IntentFilter(EMClient.getInstance().callManager().getIncomingCallBroadcastAction())
        );
        factory = EMFlutterReaderViewFactory.factoryWithRegistrar(registrar, "com.easemob.rtc/CallView");
        callSessionChannel = new MethodChannel(registrar.messenger(), "com.easemob.im/em_call_session", JSONMethodCodec.INSTANCE);
        registerEaseListener();
    }

    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        JSONObject param = (JSONObject)call.arguments;
        try{
            if(EMSDKMethod.makeCall.equals(call.method)) {
                makeCall(param, EMSDKMethod.makeCall, result);
            }
            else if (EMSDKMethod.answerCall.equals(call.method)){
                answerCall(param, EMSDKMethod.answerCall, result);
            }
            else if (EMSDKMethod.rejectCall.equals(call.method)){
                rejectCall(param, EMSDKMethod.rejectCall, result);
            }
            else if (EMSDKMethod.endCall.equals(call.method)){
                endCall(param, EMSDKMethod.endCall, result);
            }
            else if (EMSDKMethod.releaseView.equals(call.method)) {
                releaseView(param, EMSDKMethod.releaseView, result);
            }
            else if (EMSDKMethod.enableVoiceTransfer.equals(call.method)){
                enableVoiceTransfer(param, EMSDKMethod.enableVoiceTransfer, result);
            }
            else if (EMSDKMethod.enableVideoTransfer.equals(call.method)){
                enableVideoTransfer(param, EMSDKMethod.enableVideoTransfer, result);
            }
            else if (EMSDKMethod.muteRemoteAudio.equals(call.method)){
                muteRemoteAudio(param, EMSDKMethod.muteRemoteAudio, result);
            }
            else if (EMSDKMethod.muteRemoteVideo.equals(call.method)){
                muteRemoteVideo(param, EMSDKMethod.muteRemoteVideo, result);
            }
            else if (EMSDKMethod.switchCamera.equals(call.method)){
                switchCamera(param, EMSDKMethod.switchCamera, result);
            }
            else if (EMSDKMethod.setSurfaceView.equals(call.method)){
                setSurfaceView(param, EMSDKMethod.setSurfaceView, result);
            }
            else {
                super.onMethodCall(call, result);
            }
        }catch (JSONException ignored) {

        }

    }

    private void makeCall(JSONObject param, String channelName, Result result) throws JSONException {
        int callType = param.getInt("type");
        String username = param.getString("username");
        String ext = param.getString("ext");
        boolean recordOnServer = param.getBoolean("recordOnServer");
        boolean mergeStream = param.getBoolean("mergeStream");

        asyncRunnable(()->{
            try {
                if (callType == 0) {
                    EMClient.getInstance().callManager().makeVoiceCall(username, ext, recordOnServer, mergeStream);
                }else {
                    EMClient.getInstance().callManager().makeVideoCall(username, ext, recordOnServer, mergeStream);
                }
                onSuccess(result, channelName, true);
            }catch (EMServiceNotReadyException e) {
                onError(result, e);
            }
        });
    }


    private void answerCall(JSONObject param, String channelName, Result result) throws JSONException {
        asyncRunnable(()->{
            try {
                EMClient.getInstance().callManager().answerCall();
                onSuccess(result, channelName, true);
            } catch (EMNoActiveCallException e) {
                onError(result, e);
            }
        });
    }

    private void rejectCall(JSONObject param, String channelName, Result result) throws JSONException {
        asyncRunnable(()->{
            try {
                EMClient.getInstance().callManager().rejectCall();
                onSuccess(result, channelName, true);
            } catch (EMNoActiveCallException e) {
                onError(result, e);
            }
        });
    }

    private void endCall(JSONObject param, String channelName, Result result) throws JSONException {
        asyncRunnable(()->{
            try {
                EMClient.getInstance().callManager().endCall();
                onSuccess(result, channelName, true);
            } catch (EMNoActiveCallException e) {
                onError(result, new HyphenateException(e.getErrorCode(), "no incoming active call"));
            }
        });
    }


    private void enableVoiceTransfer(JSONObject param, String channelName, Result result) throws JSONException {
        boolean enable = param.getBoolean("enable");

        asyncRunnable(()->{
            try {
                if (enable) {
                    EMClient.getInstance().callManager().resumeVoiceTransfer();
                }else {
                    EMClient.getInstance().callManager().pauseVoiceTransfer();
                };
                onSuccess(result, channelName, true);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void enableVideoTransfer(JSONObject param, String channelName, Result result) throws JSONException {
        boolean enable = param.getBoolean("enable");

        asyncRunnable(()->{
            try {
                if (enable) {
                    EMClient.getInstance().callManager().resumeVideoTransfer();
                }else {
                    EMClient.getInstance().callManager().pauseVideoTransfer();
                }

                onSuccess(result, channelName, true);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void muteRemoteAudio(JSONObject param, String channelName, Result result) throws JSONException {
        boolean mute = param.getBoolean("mute");
        asyncRunnable(()->{
            EMClient.getInstance().callManager().muteRemoteAudio(mute);
            onSuccess(result, channelName, true);
        });
    }

    private void muteRemoteVideo(JSONObject param, String channelName, Result result) throws JSONException {
        boolean mute = param.getBoolean("mute");
        asyncRunnable(()->{
            EMClient.getInstance().callManager().muteRemoteVideo(mute);
            onSuccess(result, channelName, true);
        });
    }

    private void switchCamera(JSONObject param, String channelName, Result result) throws JSONException {
        asyncRunnable(()->{
            EMClient.getInstance().callManager().switchCamera();
            onSuccess(result, channelName, true);
        });
    }

    private void setSurfaceView(JSONObject param, String channelName, Result result) throws JSONException {
        boolean isLocal = param.getBoolean("isLocal");
        int viewId = param.getInt("view_id");

        if (isLocal) {
            _currentLocalViewId = viewId;
        }else {
            _currentRemoteViewId = viewId;
        }
        EMCallSurfaceView finalLocalView = factory.getLocalViewWithId(_currentLocalViewId);
        EMCallSurfaceView finalRemoteView = factory.getRemoteViewWithId(_currentRemoteViewId);

        asyncRunnable(()->{
            EMClient.getInstance().callManager().setSurfaceView(finalLocalView, finalRemoteView);
            onSuccess(result, channelName, true);
        });
    }

    private void releaseView(JSONObject param, String channelName, Result result) throws JSONException {
        int viewId = param.getInt("view_Id");
        asyncRunnable(()->{
            factory.releaseView(viewId);
            onSuccess(result, channelName, true);
        });
    }

    private void registerEaseListener() {
        EMClient.getInstance().callManager().getIncomingCallBroadcastAction();
        this.callReceiver = new EMCallReceiver(this);
        EMClient.getInstance().callManager().addCallStateChangeListener((callState, error) -> {
            post(()->{
                switch (callState) {
                    case IDLE:
                    case CONNECTED:
                    case ANSWERING:
                    case CONNECTING:
                    case RINGING: break;
                    case ACCEPTED: {
                        channel.invokeMethod(EMSDKMethod.onCallAccepted, null);
                        return;
                    }
                    case DISCONNECTED: {
                        if (error == EMCallStateChangeListener.CallError.ERROR_BUSY)
                        {
                            channel.invokeMethod(EMSDKMethod.onCallBusy, null);
                        }
                        else if (error == EMCallStateChangeListener.CallError.REJECTED)
                        {
                            channel.invokeMethod(EMSDKMethod.onCallRejected, null);
                        }
                        else {
                            channel.invokeMethod(EMSDKMethod.onCallHangup, null);
                        }
                        return;
                    }
                    case VIDEO_PAUSE: {
                        channel.invokeMethod(EMSDKMethod.onCallVideoPause, null);
                        return;
                    }
                    case VIDEO_RESUME: {
                        channel.invokeMethod(EMSDKMethod.onCallVideoResume, null);
                        return;
                    }
                    case VOICE_PAUSE: {
                        channel.invokeMethod(EMSDKMethod.onCallVoicePause, null);
                        return;
                    }
                    case VOICE_RESUME: {
                        channel.invokeMethod(EMSDKMethod.onCallVoiceResume, null);
                        return;
                    }
                    case NETWORK_NORMAL: {
                        channel.invokeMethod(EMSDKMethod.onCallNetworkNormal, null);
                        return;
                    }
                    case NETWORK_UNSTABLE: {
                        channel.invokeMethod(EMSDKMethod.onCallNetworkUnStable, null);
                        return;
                    }
                    case NETWORK_DISCONNECTED: {
                        channel.invokeMethod(EMSDKMethod.onCallNetworkDisconnect, null);
                        return;
                    }
                }
            });
        });
    }

    @Override
    public void onReceive(EMCallSession.Type type, String from) {
        Map<String, Object> data = new HashMap<>();
        data.put("type",type == EMCallSession.Type.VOICE ? 0 : 1);
        data.put("from",from);
        channel.invokeMethod(EMSDKMethod.onCallReceived,data);
    }
}

interface EMCallReceiverListener {
    void onReceive(EMCallSession.Type type, String from);
}

class EMCallReceiver extends BroadcastReceiver {

    EMCallReceiver(EMCallReceiverListener listener) {
        super();
        this.mListener = listener;
    }

    EMCallReceiverListener mListener;

    @Override
    public void onReceive(Context context, Intent intent) {
        String from = intent.getStringExtra("from");
        String typeStr = intent.getStringExtra("type");
        if (mListener != null) {
            EMCallSession.Type type = typeStr == "video" ? EMCallSession.Type.VIDEO : EMCallSession.Type.VOICE;
            mListener.onReceive(type, from);
        }
    }
}