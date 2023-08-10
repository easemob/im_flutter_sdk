package com.easemob.im_flutter_sdk;

import com.hyphenate.EMChatThreadChangeListener;
import com.hyphenate.chat.EMChatThread;
import com.hyphenate.chat.EMChatThreadEvent;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMCursorResult;
import com.hyphenate.chat.EMMessage;


import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class EMChatThreadManagerWrapper extends EMWrapper implements MethodChannel.MethodCallHandler {

    private EMChatThreadChangeListener chatThreadChangeListener;

    public EMChatThreadManagerWrapper(FlutterPlugin.FlutterPluginBinding flutterPluginBinding, String channelName) {
        super(flutterPluginBinding, channelName);
        registerEaseListener();
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {

        JSONObject param = (JSONObject) call.arguments;
        try {
            if (EMSDKMethod.fetchChatThreadDetail.equals(call.method)) {
                fetchChatThreadDetail(param, call.method, result);
            } else if (EMSDKMethod.fetchJoinedChatThreads.equals(call.method)) {
                fetchJoinedChatThreads(param, call.method, result);
            } else if (EMSDKMethod.fetchChatThreadsWithParentId.equals(call.method)) {
                fetchChatThreadsWithParentId(param, call.method, result);
            } else if (EMSDKMethod.fetchJoinedChatThreadsWithParentId.equals(call.method)) {
                fetchJoinedChatThreadsWithParentId(param, call.method, result);
            } else if (EMSDKMethod.fetchChatThreadMember.equals(call.method)) {
                fetchChatThreadMember(param, call.method, result);
            } else if (EMSDKMethod.fetchLastMessageWithChatThreads.equals(call.method)) {
                fetchLastMessageWithChatThreads(param, call.method, result);
            } else if (EMSDKMethod.removeMemberFromChatThread.equals(call.method)) {
                removeMemberFromChatThread(param, call.method, result);
            } else if (EMSDKMethod.updateChatThreadSubject.equals(call.method)) {
                updateChatThreadSubject(param, call.method, result);
            } else if (EMSDKMethod.createChatThread.equals(call.method)) {
                createChatThread(param, call.method, result);
            } else if (EMSDKMethod.joinChatThread.equals(call.method)) {
                joinChatThread(param, call.method, result);
            } else if (EMSDKMethod.leaveChatThread.equals(call.method)) {
                leaveChatThread(param, call.method, result);
            } else if (EMSDKMethod.destroyChatThread.equals(call.method)) {
                destroyChatThread(param, call.method, result);
            }
            else {
                super.onMethodCall(call, result);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void fetchChatThreadDetail(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        String threadId = param.getString("threadId");
        EMClient.getInstance().chatThreadManager().getChatThreadFromServer(threadId, new EMValueWrapperCallBack<EMChatThread>(result, channelName){
            @Override
            public void onSuccess(EMChatThread object) {
                super.updateObject(EMChatThreadHelper.toJson(object));
            }
        });
    }

    private void fetchJoinedChatThreads(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        int pageSize = param.getInt("pageSize");
        String cursor = null;
        if (param.has("cursor")) {
            cursor = param.getString("cursor");
        }

        EMClient.getInstance().chatThreadManager().getJoinedChatThreadsFromServer(pageSize, cursor, new EMValueWrapperCallBack<EMCursorResult<EMChatThread>>(result, channelName){
            @Override
            public void onSuccess(EMCursorResult<EMChatThread> object) {
                super.updateObject(EMCursorResultHelper.toJson(object));
            }
        });
    }

    private void fetchChatThreadsWithParentId(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        int pageSize = param.getInt("pageSize");
        String cursor = null;
        if (param.has("cursor")) {
            cursor = param.getString("cursor");
        }
        String parentId = param.getString("parentId");
        EMClient.getInstance().chatThreadManager().getChatThreadsFromServer(parentId, pageSize, cursor, new EMValueWrapperCallBack<EMCursorResult<EMChatThread>>(result, channelName){
            @Override
            public void onSuccess(EMCursorResult<EMChatThread> object) {
                super.updateObject(EMCursorResultHelper.toJson(object));
            }
        });
    }

    private void fetchJoinedChatThreadsWithParentId(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        int pageSize = param.getInt("pageSize");
        String cursor = null;
        if (param.has("cursor")) {
            cursor = param.getString("cursor");
        }
        String parentId = param.getString("parentId");

        EMClient.getInstance().chatThreadManager().getJoinedChatThreadsFromServer(parentId, pageSize, cursor, new EMValueWrapperCallBack<EMCursorResult<EMChatThread>>(result, channelName) {
            @Override
            public void onSuccess(EMCursorResult<EMChatThread> object) {
                super.updateObject(EMCursorResultHelper.toJson(object));
            }
        });
    }

    private void fetchChatThreadMember(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        int pageSize = param.getInt("pageSize");
        String cursor = null;
        if (param.has("cursor")) {
            cursor = param.getString("cursor");
        }
        String threadId = param.getString("threadId");
        EMClient.getInstance().chatThreadManager().getChatThreadMembers(threadId, pageSize, cursor, new EMValueWrapperCallBack<EMCursorResult<String>>(result, channelName) {
            @Override
            public void onSuccess(EMCursorResult<String> object) {
                super.updateObject(EMCursorResultHelper.toJson(object));
            }
        });
    }

    private void fetchLastMessageWithChatThreads(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        List<String> threadIds = new ArrayList<>();
        JSONArray ja = param.getJSONArray("threadIds");
        for (int i = 0; i < ja.length(); i++) {
            String threadId = ja.getString(i);
            threadIds.add(threadId);
        }
        EMClient.getInstance().chatThreadManager().getChatThreadLatestMessage(threadIds, new EMValueWrapperCallBack<Map<String, EMMessage>>(result, channelName) {
            @Override
            public void onSuccess(Map<String, EMMessage> object) {
                HashMap<String, Object> map = new HashMap<>();
                for (Map.Entry<String, EMMessage> entry: object.entrySet()) {
                    map.put(entry.getKey(), EMMessageHelper.toJson(entry.getValue()));
                }
                super.updateObject(map);
            }
        });
    }

    private void removeMemberFromChatThread(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        String threadId = param.getString("threadId");
        String memberId = param.getString("memberId");
        EMClient.getInstance().chatThreadManager().removeMemberFromChatThread(threadId, memberId, new EMWrapperCallBack(result, channelName, true));
    }

    private void updateChatThreadSubject(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        String threadId = param.getString("threadId");
        String name = param.getString("name");
        EMClient.getInstance().chatThreadManager().updateChatThreadName(threadId, name, new EMWrapperCallBack(result, channelName, true));
    }

    private void createChatThread(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        String messageId = param.getString("messageId");
        String name = param.getString("name");
        String parentId = param.getString("parentId");
        EMClient.getInstance().chatThreadManager().createChatThread(parentId, messageId, name, new EMValueWrapperCallBack<EMChatThread>(result, channelName){
            @Override
            public void onSuccess(EMChatThread object) {
                super.updateObject(EMChatThreadHelper.toJson(object));
            }
        });
    }

    private void joinChatThread(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        String threadId = param.getString("threadId");
        EMClient.getInstance().chatThreadManager().joinChatThread(threadId, new EMValueWrapperCallBack<EMChatThread>(result, channelName){
            @Override
            public void onSuccess(EMChatThread object) {
                super.updateObject(EMChatThreadHelper.toJson(object));
            }
        });
    }

    private void leaveChatThread(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        String threadId = param.getString("threadId");
        EMClient.getInstance().chatThreadManager().leaveChatThread(threadId, new EMWrapperCallBack(result, channelName, true));
    }

    private void destroyChatThread(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        String threadId = param.getString("threadId");
        EMClient.getInstance().chatThreadManager().destroyChatThread(threadId, new EMWrapperCallBack(result, channelName, true));
    }

    private void registerEaseListener() {

        if (chatThreadChangeListener != null) {
            EMClient.getInstance().chatThreadManager().removeChatThreadChangeListener(chatThreadChangeListener);
        }
        chatThreadChangeListener = new EMChatThreadChangeListener() {
            @Override
            public void onChatThreadCreated(EMChatThreadEvent event) {
                post(() -> channel.invokeMethod(EMSDKMethod.onChatThreadCreate, EMChatThreadEventHelper.toJson(event)));
            }

            @Override
            public void onChatThreadUpdated(EMChatThreadEvent event) {
                post(() -> channel.invokeMethod(EMSDKMethod.onChatThreadUpdate, EMChatThreadEventHelper.toJson(event)));
            }

            @Override
            public void onChatThreadDestroyed(EMChatThreadEvent event) {
                post(() -> channel.invokeMethod(EMSDKMethod.onChatThreadDestroy, EMChatThreadEventHelper.toJson(event)));
            }

            @Override
            public void onChatThreadUserRemoved(EMChatThreadEvent event) {
                post(() -> channel.invokeMethod(EMSDKMethod.onUserKickOutOfChatThread, EMChatThreadEventHelper.toJson(event)));
            }
        };

        EMClient.getInstance().chatThreadManager().addChatThreadChangeListener(chatThreadChangeListener);
    }

    @Override
    public void unRegisterEaseListener() {
        EMClient.getInstance().chatThreadManager().removeChatThreadChangeListener(chatThreadChangeListener);
    }
}
