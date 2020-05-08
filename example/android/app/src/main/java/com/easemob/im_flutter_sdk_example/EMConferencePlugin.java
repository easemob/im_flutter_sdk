package com.easemob.im_flutter_sdk_example;

import android.app.Activity;

import com.easemob.im_flutter_sdk.EMWrapper;
import com.easemob.im_flutter_sdk.ImFlutterSdkPlugin;
import com.easemob.im_flutter_sdk_example.conference.ConferenceActivity;
import com.easemob.im_flutter_sdk_example.receiver.CallReceiver;
import com.hyphenate.EMConferenceListener;
import com.hyphenate.EMValueCallBack;
import com.hyphenate.chat.EMCallManager;
import com.hyphenate.chat.EMCallSession;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMConference;
import com.hyphenate.chat.EMConferenceManager;
import com.hyphenate.chat.EMConferenceMember;
import com.hyphenate.chat.EMConferenceStream;
import com.hyphenate.chat.EMStreamStatistics;
import com.hyphenate.util.EMLog;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.JSONMethodCodec;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class EMConferencePlugin implements MethodChannel.MethodCallHandler, EMWrapper {
    static final String Conference = "com.easemob.im/em_conference_manager";
    static MethodChannel channel;
    private static Activity activity;
    private static MethodChannel.Result result;
    private EMConferencePlugin(Activity activity) {
        this.activity = activity;
    }

    static void registerWith(PluginRegistry.Registrar registrar) {
        channel = new MethodChannel(registrar.messenger(), Conference , JSONMethodCodec.INSTANCE);
        EMConferencePlugin emConferencePlugin = new EMConferencePlugin(registrar.activity());
        channel.setMethodCallHandler(emConferencePlugin);
    }

    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        if(methodCall.method.equals("createAndJoinConference")){
            createAndJoinConference(methodCall.arguments, result);
        }else if(methodCall.method.equals("joinConference")){
            joinConference(methodCall.arguments, result);
        }
    }

    private void createAndJoinConference(Object args, MethodChannel.Result result){
        try {
            this.result = result;
            JSONObject argMap = (JSONObject) args;
            int conferenceType = argMap.getInt("conferenceType");
            String password = argMap.getString("password");
            Boolean record = argMap.getBoolean("record");
            Boolean merge = argMap.getBoolean("merge");
            ConferenceActivity.startConferenceCall(activity, conferenceType, password, record, merge);
        } catch (JSONException e) {
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void joinConference(Object args, MethodChannel.Result result){
        try {
            this.result = result;
            JSONObject argMap = (JSONObject) args;
            String confId = argMap.getString("confId");
            String password = argMap.getString("password");
            ConferenceActivity.receiveConferenceCall(activity, confId, password);
        } catch (JSONException e) {
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private static Map<String, Object> emConferenceToMap(EMConference conference){
        Map<String, Object> emConference = new HashMap<String, Object>();
        emConference.put("conferenceId", conference.getConferenceId());
        emConference.put("password", conference.getPassword());
        if(conference.getConferenceType() == EMConferenceManager.EMConferenceType.SmallCommunication){
            emConference.put("conferenceType", 10);
        }else if(conference.getConferenceType() == EMConferenceManager.EMConferenceType.LargeCommunication){
            emConference.put("conferenceType", 11);
        }else if(conference.getConferenceType() == EMConferenceManager.EMConferenceType.LiveStream){
            emConference.put("conferenceType", 12);
        }
        if(conference.getConferenceRole() == EMConferenceManager.EMConferenceRole.Admin){
            emConference.put("conferenceRole", 7);
        }else if(conference.getConferenceRole() == EMConferenceManager.EMConferenceRole.Talker){
            emConference.put("conferenceRole", 3);
        }else if(conference.getConferenceRole() == EMConferenceManager.EMConferenceRole.Audience){
            emConference.put("conferenceRole", 1);
        }else if(conference.getConferenceRole() == EMConferenceManager.EMConferenceRole.NoType){
            emConference.put("conferenceRole", 0);
        }
        emConference.put("memberNum", conference.getMemberNum());
        List<String> admins = new ArrayList<String>();
        if(conference.getAdmins() != null){
            for(int i = 0;i < conference.getAdmins().length; i++){
                admins.add(conference.getAdmins()[i]);
            }
        }
        emConference.put("admins", admins);
        List<String> speakers = new ArrayList<String>();
        if(conference.getSpeakers() != null){
            for(int i = 0;i < conference.getSpeakers().length; i++){
                speakers.add(conference.getSpeakers()[i]);
            }
        }
        emConference.put("speakers", speakers);
        emConference.put("isRecordOnServer", conference.isRecordOnServer());
        return emConference;
    }

    public static void onResult(EMConference conference, int error, String errorMsg){
        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Map<String, Object> data = new HashMap<String, Object>();
                if(conference != null) {
                    data.put("success", Boolean.TRUE);
                    data.put("value", emConferenceToMap(conference));
                    result.success(data);
                }else{
                    data.put("success", Boolean.FALSE);
                    data.put("code", error);
                    data.put("desc", errorMsg);
                    result.success(data);
                }
            }
        });
    }
}
