package com.easemob.im_flutter_sdk;

import com.easemob.im_flutter_sdk.call.view.EMFlutterReaderViewFactory;
import com.hyphenate.EMConferenceListener;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMConference;
import com.hyphenate.chat.EMConferenceManager;
import com.hyphenate.chat.EMConferenceMember;
import com.hyphenate.chat.EMConferenceStream;
import com.hyphenate.chat.EMStreamParam;
import com.hyphenate.chat.EMStreamStatistics;
import com.hyphenate.exceptions.HyphenateException;
import com.hyphenate.media.EMCallSurfaceView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class EMConferenceManagerWrapper extends EMWrapper implements MethodChannel.MethodCallHandler {

    private EMFlutterReaderViewFactory _factory;
    private Map<String, EMConferenceStream> _confereneMap = new HashMap<>();

    public EMConferenceManagerWrapper(PluginRegistry.Registrar registrar, String channelName) {
        super(registrar, channelName);
        _factory = EMFlutterReaderViewFactory.factoryWithRegistrar(registrar, "com.easemob.rtc/CallView");
        registerEaseListener();
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {

        JSONObject param = (JSONObject)call.arguments;
        try {
            if(EMSDKMethod.setConferenceAppKey.equals(call.method)) {
                setConferenceAppKey(param, EMSDKMethod.setConferenceAppKey, result);
            }
            else if (EMSDKMethod.conferenceHasExists.equals(call.method)) {
                conferenceHasExists(param, EMSDKMethod.conferenceHasExists, result);
            }
            else if (EMSDKMethod.joinConference.equals(call.method)) {
                joinConference(param, EMSDKMethod.joinConference, result);
            }
            else if (EMSDKMethod.joinRoom.equals(call.method)) {
                joinRoom(param, EMSDKMethod.joinRoom, result);
            }
            else if (EMSDKMethod.createWhiteboardRoom.equals(call.method)) {
                createWhiteboardRoom(param, EMSDKMethod.createWhiteboardRoom, result);
            }
            else if (EMSDKMethod.destroyWhiteboardRoom.equals(call.method)) {
                destroyWhiteboardRoom(param, EMSDKMethod.destroyWhiteboardRoom, result);
            }
            else if (EMSDKMethod.joinWhiteboardRoom.equals(call.method)) {
                joinWhiteboardRoom(param, EMSDKMethod.joinWhiteboardRoom, result);
            }
            else if (EMSDKMethod.publishConference.equals(call.method)) {
                publishConference(param, EMSDKMethod.publishConference, result);
            }
            else if (EMSDKMethod.unPublishConference.equals(call.method)) {
                unPublishConference(param, EMSDKMethod.unPublishConference, result);
            }
            else if (EMSDKMethod.subscribeConference.equals(call.method)) {
                subscribeConference(param, EMSDKMethod.subscribeConference, result);
            }
            else if (EMSDKMethod.unSubscribeConference.equals(call.method)) {
                unSubscribeConference(param, EMSDKMethod.unSubscribeConference, result);
            }
            else if (EMSDKMethod.changeMemberRoleWithMemberName.equals(call.method)) {
                changeMemberRoleWithMemberName(param, EMSDKMethod.changeMemberRoleWithMemberName, result);
            }
            else if (EMSDKMethod.kickConferenceMember.equals(call.method)) {
                kickConferenceMember(param, EMSDKMethod.kickConferenceMember, result);
            }
            else if (EMSDKMethod.destroyConference.equals(call.method)) {
                destroyConference(param, EMSDKMethod.destroyConference, result);
            }
            else if (EMSDKMethod.leaveConference.equals(call.method)) {
                leaveConference(param, EMSDKMethod.leaveConference, result);
            }
            else if (EMSDKMethod.startMonitorSpeaker.equals(call.method)) {
                startMonitorSpeaker(param, EMSDKMethod.startMonitorSpeaker, result);
            }
            else if (EMSDKMethod.stopMonitorSpeaker.equals(call.method)) {
                stopMonitorSpeaker(param, EMSDKMethod.stopMonitorSpeaker, result);
            }
            else if (EMSDKMethod.requestTobeConferenceSpeaker.equals(call.method)) {
                requestTobeConferenceSpeaker(param, EMSDKMethod.requestTobeConferenceSpeaker, result);
            }
            else if (EMSDKMethod.requestTobeConferenceAdmin.equals(call.method)) {
                requestTobeConferenceAdmin(param, EMSDKMethod.requestTobeConferenceAdmin, result);
            }
            else if (EMSDKMethod.muteConferenceMember.equals(call.method)) {
                muteConferenceMember(param, EMSDKMethod.muteConferenceMember, result);
            }
            else if (EMSDKMethod.responseReqSpeaker.equals(call.method)) {
                responseReqSpeaker(param, EMSDKMethod.responseReqSpeaker, result);
            }
            else if (EMSDKMethod.muteConferenceMember.equals(call.method)) {
                muteConferenceMember(param, EMSDKMethod.muteConferenceMember, result);
            }
            else if (EMSDKMethod.responseReqAdmin.equals(call.method)) {
                responseReqAdmin(param, EMSDKMethod.responseReqAdmin, result);
            }
            else if (EMSDKMethod.updateConferenceWithSwitchCamera.equals(call.method)) {
                updateConferenceWithSwitchCamera(param, EMSDKMethod.updateConferenceWithSwitchCamera, result);
            }
            else if (EMSDKMethod.updateConferenceMute.equals(call.method)) {
                updateConferenceMute(param, EMSDKMethod.updateConferenceMute, result);
            }
            else if (EMSDKMethod.updateConferenceVideo.equals(call.method)) {
                updateConferenceVideo(param, EMSDKMethod.updateConferenceVideo, result);
            }
            else if (EMSDKMethod.updateRemoteView.equals(call.method)) {
                updateRemoteView(param, EMSDKMethod.updateRemoteView, result);
            }
            else if (EMSDKMethod.updateMaxVideoKbps.equals(call.method)) {
                updateMaxVideoKbps(param, EMSDKMethod.updateMaxVideoKbps, result);
            }
            else if (EMSDKMethod.setConferenceAttribute.equals(call.method)) {
                setConferenceAttribute(param, EMSDKMethod.setConferenceAttribute, result);
            }
            else if (EMSDKMethod.deleteAttributeWithKey.equals(call.method)) {
                deleteAttributeWithKey(param, EMSDKMethod.deleteAttributeWithKey, result);
            }
            else if (EMSDKMethod.setConferenceAttribute.equals(call.method)) {
                setConferenceAttribute(param, EMSDKMethod.setConferenceAttribute, result);
            }
            else if (EMSDKMethod.muteConferenceRemoteAudio.equals(call.method)) {
                muteConferenceRemoteAudio(param, EMSDKMethod.muteConferenceRemoteAudio, result);
            }
            else if (EMSDKMethod.muteConferenceRemoteVideo.equals(call.method)) {
                muteConferenceRemoteVideo(param, EMSDKMethod.muteConferenceRemoteVideo, result);
            }
            else if (EMSDKMethod.muteConferenceAll.equals(call.method)) {
                muteConferenceAll(param, EMSDKMethod.muteConferenceAll, result);
            }
            else if (EMSDKMethod.addVideoWatermark.equals(call.method)) {
                addVideoWatermark(param, EMSDKMethod.addVideoWatermark, result);
            }
            else if (EMSDKMethod.clearVideoWatermark.equals(call.method)) {
                clearVideoWatermark(param, EMSDKMethod.clearVideoWatermark, result);
            }
            else  {
                super.onMethodCall(call, result);
            }

        }catch (JSONException ignored) {

        }
    }

    private void setConferenceAppKey(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        String appKey = param.getString("appKey");
        String accessToken = param.getString("token");
        String username = param.getString("username");
        asyncRunnable(()->{
            EMClient.getInstance().conferenceManager().set(accessToken, appKey, username);
            onSuccess(result, channelName, true);
        });
    }

    private void conferenceHasExists(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        String confId = param.getString("conf_id");
        String pwd = param.getString("pwd");
        EMClient.getInstance().conferenceManager().getConferenceInfo(confId, pwd, new EMValueWrapperCallBack<EMConference>(result, channelName) {
            @Override
            public void onSuccess(EMConference object) {
                super.updateObject(EMConferenceHelper.toJson(object));
            }
        });
    }

    private void joinConference(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        String confId = param.getString("conf_id");
        String pwd = param.getString("pwd");
        asyncRunnable(()->{
            EMClient.getInstance().conferenceManager().joinConference(confId, pwd, new EMValueWrapperCallBack<EMConference>(result, channelName) {
                @Override
                public void onSuccess(EMConference object) {
                    super.updateObject(EMConferenceHelper.toJson(object));
                }
            });
        });
    }

    private void joinRoom(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        String roomName = param.getString("roomName");
        String pwd = param.getString("pwd");
        EMConferenceManager.EMConferenceRole finalRole = roleFromInt(param.getInt("role"));
        asyncRunnable(()->{
            EMClient.getInstance().conferenceManager().joinRoom(roomName, pwd, finalRole, new EMValueWrapperCallBack<EMConference>(result, channelName) {
                @Override
                public void onSuccess(EMConference object) {
                    super.updateObject(EMConferenceHelper.toJson(object));
                }
            });
        });
    }

    private void createWhiteboardRoom(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        // TODO:
        onSuccess(result, channelName, false);
    }

    private void joinWhiteboardRoom(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        // TODO:
        onSuccess(result, channelName, false);
    }

    private void destroyWhiteboardRoom(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        // TODO:
        onSuccess(result, channelName, false);
    }

    private void publishConference(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        int viewId = param.getInt("view_id");
        EMStreamParam streamParam = EMStreamParamHelper.fromJson(param.getJSONObject("stream"));
        EMCallSurfaceView view = _factory.getLocalViewWithId(viewId);
        EMClient.getInstance().conferenceManager().setLocalSurfaceView(view);
        EMClient.getInstance().conferenceManager().publish(streamParam, new EMValueWrapperCallBack<>(result, channelName));
    }

    private void unPublishConference(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        String streamId = param.getString("stream_id");
        EMClient.getInstance().conferenceManager().unpublish(streamId, new EMValueWrapperCallBack<>(result, channelName));
    }

    private void subscribeConference(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        EMConferenceStream stream = _confereneMap.get(param.getString("conf_id"));
        int viewId = param.getInt("view_id");
        EMCallSurfaceView view = _factory.getRemoteViewWithId(viewId);
        EMClient.getInstance().conferenceManager().subscribe(stream, view, new EMValueWrapperCallBack<>(result, channelName));
    }

    private void unSubscribeConference(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        EMConferenceStream stream = _confereneMap.get(param.getString("conf_id"));
        EMClient.getInstance().conferenceManager().unsubscribe(stream, new EMValueWrapperCallBack<>(result, channelName));
    }

    private void changeMemberRoleWithMemberName(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        String confId = param.getString("conf_id");
        String memberName = param.getString("memberName");
        EMConferenceManager.EMConferenceRole finalRole = roleFromInt(param.getInt("role"));
        EMConferenceMember member = null;
        for (EMConferenceMember m: EMClient.getInstance().conferenceManager().getConferenceMemberList()) {
            if (m.memberId.equals(memberName)) {
                member = m;
                break;
            }
        }
        EMClient.getInstance().conferenceManager().grantRole(confId, member, finalRole, new EMValueWrapperCallBack<>(result, channelName));
    }

    private void kickConferenceMember(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        String confId = param.getString("conf_id");
        JSONArray memberNames = param.getJSONArray("memberNames");
        List<String> list = new ArrayList<>();
        for (int i = 0; i < memberNames.length(); i++) {
            list.add(memberNames.getString(i));
        }
        EMClient.getInstance().conferenceManager().kickMember(confId, list, new EMValueWrapperCallBack<>(result, channelName));
    }

    private void destroyConference(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        EMClient.getInstance().conferenceManager().destroyConference(new EMValueWrapperCallBack(result, channelName));
    }

    private void leaveConference(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        EMClient.getInstance().conferenceManager().exitConference(new EMValueWrapperCallBack(result, channelName));
    }
    private void startMonitorSpeaker(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        int time = param.getInt("time");
        EMClient.getInstance().conferenceManager().startMonitorSpeaker(time);
        onSuccess(result, channelName, true);
    }

    private void stopMonitorSpeaker(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        EMClient.getInstance().conferenceManager().stopMonitorSpeaker();
        onSuccess(result, channelName, true);
    }
    private void requestTobeConferenceSpeaker(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        String adminId = param.getString("admin_id");
        EMClient.getInstance().conferenceManager().applyTobeSpeaker(adminId);
        onSuccess(result, channelName, true);
    }

    private void requestTobeConferenceAdmin(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        String adminId = param.getString("admin_id");
        EMClient.getInstance().conferenceManager().applyTobeAdmin(adminId);
        onSuccess(result, channelName, true);
    }
    private void muteConferenceMember(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        String memberId = param.getString("member_id");
        boolean isMute = param.getBoolean("isMute");
        if (isMute) {
            EMClient.getInstance().conferenceManager().muteMember(memberId);
        }else {
            EMClient.getInstance().conferenceManager().unmuteMember(memberId);
        }

        onSuccess(result, channelName, true);
    }

    private void responseReqSpeaker(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        String memberId = param.getString("member_id");
        boolean agree = param.getBoolean("agree");
        EMClient.getInstance().conferenceManager().handleSpeakerApplication(memberId, agree);
        onSuccess(result, channelName, true);
    }

    private void responseReqAdmin(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        String memberId = param.getString("member_id");
        boolean agree = param.getBoolean("agree");
        EMClient.getInstance().conferenceManager().handleAdminApplication(memberId, agree);
        onSuccess(result, channelName, true);
    }

    private void updateConferenceWithSwitchCamera(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        EMClient.getInstance().conferenceManager().switchCamera();
        onSuccess(result, channelName, true);
    }

    private void updateConferenceMute(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        boolean mute = param.getBoolean("mute");
        if (mute) {
            EMClient.getInstance().conferenceManager().closeVoiceTransfer();
        }else {
            EMClient.getInstance().conferenceManager().openVoiceTransfer();
        }

        onSuccess(result, channelName, true);
    }

    private void updateConferenceVideo(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        boolean mute = param.getBoolean("mute");
        if (mute) {
            EMClient.getInstance().conferenceManager().closeVideoTransfer();
        }else {
            EMClient.getInstance().conferenceManager().openVideoTransfer();
        }
        onSuccess(result, channelName, true);
    }
    private void updateRemoteView(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        // TODO:
        onSuccess(result, channelName, false);
    }

    private void updateMaxVideoKbps(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        // TODO:
        onSuccess(result, channelName, false);
    }
    private void setConferenceAttribute(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        String key = param.getString("key");
        String value = param.getString("value");
        EMClient.getInstance().conferenceManager().setConferenceAttribute(key, value, new EMValueWrapperCallBack<Void>(result, channelName) {
            @Override
            public void onSuccess(Void object) {
                updateObject(true);
            }
        });
    }

    private void deleteAttributeWithKey(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        String key = param.getString("key");
        EMClient.getInstance().conferenceManager().deleteConferenceAttribute(key, new EMValueWrapperCallBack<Void>(result, channelName) {
            @Override
            public void onSuccess(Void object) {
                updateObject(true);
            }
        });
    }
    private void muteConferenceRemoteAudio(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        String streamId = param.getString("steam_id");
        boolean isMute = param.getBoolean("isMute");
        EMClient.getInstance().conferenceManager().muteRemoteAudio(streamId, isMute);
        onSuccess(result, channelName, true);
    }

    private void muteConferenceRemoteVideo(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        String streamId = param.getString("steam_id");
        boolean isMute = param.getBoolean("isMute");
        EMClient.getInstance().conferenceManager().muteRemoteVideo(streamId, isMute);
        onSuccess(result, channelName, true);
    }

    private void muteConferenceAll(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        String confId = param.getString("conf_id");
        boolean isMute = param.getBoolean("isMute");
        EMClient.getInstance().conferenceManager().muteAll(confId, isMute, new EMValueWrapperCallBack<String>(result, channelName) {
            @Override
            public void onSuccess(String object) {
                updateObject(true);
            }
        });
    }

    private void addVideoWatermark(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        // TODO:
        onSuccess(result, channelName, false);
    }
    private void clearVideoWatermark(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        // TODO:
        onSuccess(result, channelName, false);
    }


    private void  registerEaseListener() {
        EMClient.getInstance().conferenceManager().addConferenceListener(new EMConferenceListener() {
            @Override
            public void onMemberJoined(EMConferenceMember member) {
                channel.invokeMethod(EMSDKMethod.onMemberJoined, EMConferenceMemberHelper.toJson(member));
            }

            @Override
            public void onMemberExited(EMConferenceMember member) {
                channel.invokeMethod(EMSDKMethod.onMemberExited, EMConferenceMemberHelper.toJson(member));
            }

            @Override
            public void onStreamAdded(EMConferenceStream stream) {
                channel.invokeMethod(EMSDKMethod.onStreamAdded, EMConferenceStreamHelper.toJson(stream));
            }

            @Override
            public void onStreamRemoved(EMConferenceStream stream) {
                channel.invokeMethod(EMSDKMethod.onStreamRemoved, EMConferenceStreamHelper.toJson(stream));
            }

            @Override
            public void onStreamUpdate(EMConferenceStream stream) {
                channel.invokeMethod(EMSDKMethod.onStreamUpdate, EMConferenceStreamHelper.toJson(stream));
            }

            @Override
            public void onPassiveLeave(int error, String message) {
                channel.invokeMethod(EMSDKMethod.onPassiveLeave, new HyphenateException(error, message));
            }

            @Override
            public void onAdminAdded(String memName) {
                channel.invokeMethod(EMSDKMethod.onAdminAdded, memName);
            }

            @Override
            public void onAdminRemoved(String memName) {
                channel.invokeMethod(EMSDKMethod.onAdminRemoved, memName);
            }

            @Override
            public void onPubStreamFailed(int error, String message) {
                channel.invokeMethod(EMSDKMethod.onPubStreamFailed, new HyphenateException(error, message));
            }

            @Override
            public void onStreamSetup(String streamId) {
                channel.invokeMethod(EMSDKMethod.onStreamSetup, streamId);
            }

            @Override
            public void onUpdateStreamFailed(int error, String message) {
                channel.invokeMethod(EMSDKMethod.onUpdateStreamFailed, new HyphenateException(error, message));
            }

            @Override
            public void onSpeakers(List<String> speakers) {
                channel.invokeMethod(EMSDKMethod.onSpeakers, speakers);
            }

            @Override
            public void onReceiveInvite(String confId, String password, String extension) {
                Map<String, String> map = new HashMap<>();
                map.put("conf_id", confId);
                map.put("pwd", password);
                map.put("ext", extension);
                channel.invokeMethod(EMSDKMethod.onReceiveInvite, map);
            }

            @Override
            public void onRoleChanged(EMConferenceManager.EMConferenceRole role) {
                channel.invokeMethod(EMSDKMethod.onRoleChanged, role.code);
            }

            @Override
            public void onReqSpeaker(String memId, String memName, String nickname) {
                Map<String, String> map = new HashMap<>();
                map.put("mem_id", memId);
                map.put("memName", memName);
                map.put("nickname", nickname);
                channel.invokeMethod(EMSDKMethod.onReqSpeaker, map);
            }

            @Override
            public void onReqAdmin(String memId, String memName, String nickname) {
                Map<String, String> map = new HashMap<>();
                map.put("mem_id", memId);
                map.put("memName", memName);
                map.put("nickname", nickname);
                channel.invokeMethod(EMSDKMethod.onReqAdmin, map);
            }

            @Override
            public void onMute(String adminId, String memId) {
                channel.invokeMethod(EMSDKMethod.onMute, true);
            }

            @Override
            public void onUnMute(String adminId, String memId) {
                channel.invokeMethod(EMSDKMethod.onMute, false);
            }

            @Override
            public void onMuteAll(boolean mute) {
                channel.invokeMethod(EMSDKMethod.onMute, mute);
            }

            @Override
            public void onApplySpeakerRefused(String memId, String adminId) {
                channel.invokeMethod(EMSDKMethod.onApplySpeakerRefused, adminId);
            }

            @Override
            public void onApplyAdminRefused(String memId, String adminId) {
                channel.invokeMethod(EMSDKMethod.onApplyAdminRefused, adminId);
            }

            @Override
            public void onStreamStateUpdated(String streamId, StreamState state) {
//                Map<String, Object> map = new HashMap<>();
//                map.put("stream_id", streamId);
//                map.put("state", state);
//                channel.invokeMethod(EMSDKMethod.onApplyAdminRefused, map);
            }

            @Override
            public void onConferenceState(ConferenceState state) {
//                channel.invokeMethod(EMSDKMethod.onConferenceState, EMConferenceMemberHelper.toJson(member));
            }

            @Override
            public void onStreamStatistics(EMStreamStatistics statistics) {
//                channel.invokeMethod(EMSDKMethod.onStreamStatistics, EMConferenceMemberHelper.toJson(member));
            }

        });
    }

    private EMConferenceManager.EMConferenceRole roleFromInt(int intRole) {
        EMConferenceManager.EMConferenceRole role =  EMConferenceManager.EMConferenceRole.NoType;
        if (intRole == 1) {
            role = EMConferenceManager.EMConferenceRole.Audience;
        }else if (intRole == 3) {
            role = EMConferenceManager.EMConferenceRole.Talker;
        }else if (intRole == 7) {
            role = EMConferenceManager.EMConferenceRole.Admin;
        }

        return role;
    }
}