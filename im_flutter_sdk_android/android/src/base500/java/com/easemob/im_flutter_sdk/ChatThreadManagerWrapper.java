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

public class ChatThreadManagerWrapper extends Wrapper implements MethodChannel.MethodCallHandler {

    private EMChatThreadChangeListener chatThreadChangeListener;

    public ChatThreadManagerWrapper(FlutterPlugin.FlutterPluginBinding flutterPluginBinding, String channelName) {
        super(flutterPluginBinding, channelName);
        registerEaseListener();
    }

    @Override
    protected boolean dispatchMethodCall(
            String method,
            JSONObject params,
            MethodChannel.Result result
    ) throws Exception {
        if (MethodKey.fetchChatThreadDetail.equals(method)) {
            fetchChatThreadDetail(params, method, result);
            return true;
        }
        else if (MethodKey.fetchJoinedChatThreads.equals(method)) {
            fetchJoinedChatThreads(params, method, result);
            return true;
        }
        else if (MethodKey.fetchChatThreadsWithParentId.equals(method)) {
            fetchChatThreadsWithParentId(params, method, result);
            return true;
        }
        else if (MethodKey.fetchJoinedChatThreadsWithParentId.equals(method)) {
            fetchJoinedChatThreadsWithParentId(params, method, result);
            return true;
        }
        else if (MethodKey.fetchChatThreadMember.equals(method)) {
            fetchChatThreadMember(params, method, result);
            return true;
        }
        else if (MethodKey.fetchLastMessageWithChatThreads.equals(method)) {
            fetchLastMessageWithChatThreads(params, method, result);
            return true;
        }
        else if (MethodKey.removeMemberFromChatThread.equals(method)) {
            removeMemberFromChatThread(params, method, result);
            return true;
        }
        else if (MethodKey.updateChatThreadSubject.equals(method)) {
            updateChatThreadSubject(params, method, result);
            return true;
        }
        else if (MethodKey.createChatThread.equals(method)) {
            createChatThread(params, method, result);
            return true;
        }
        else if (MethodKey.joinChatThread.equals(method)) {
            joinChatThread(params, method, result);
            return true;
        }
        else if (MethodKey.leaveChatThread.equals(method)) {
            leaveChatThread(params, method, result);
            return true;
        }
        else if (MethodKey.destroyChatThread.equals(method)) {
            destroyChatThread(params, method, result);
            return true;
        }

        return super.dispatchMethodCall(method, params, result);
    }



    private void fetchChatThreadDetail(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        String threadId = param.getString("threadId");
        EMClient.getInstance().chatThreadManager().getChatThreadFromServer(threadId, new EMValueWrapperCallBack<EMChatThread>(result, channelName){
            @Override
            public void onSuccess(EMChatThread object) {
                super.updateObject(ChatThreadHelper.toJson(object));
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
                super.updateObject(CursorResultHelper.toJson(object));
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
                super.updateObject(CursorResultHelper.toJson(object));
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
                super.updateObject(CursorResultHelper.toJson(object));
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
                super.updateObject(CursorResultHelper.toJson(object));
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
                    map.put(entry.getKey(), MessageHelper.toJson(entry.getValue()));
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
        String messageId = param.getString("msgId");
        String name = param.getString("name");
        String parentId = param.getString("parentId");
        EMClient.getInstance().chatThreadManager().createChatThread(parentId, messageId, name, new EMValueWrapperCallBack<EMChatThread>(result, channelName){
            @Override
            public void onSuccess(EMChatThread object) {
                super.updateObject(ChatThreadHelper.toJson(object));
            }
        });
    }

    private void joinChatThread(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        String threadId = param.getString("threadId");
        EMClient.getInstance().chatThreadManager().joinChatThread(threadId, new EMValueWrapperCallBack<EMChatThread>(result, channelName){
            @Override
            public void onSuccess(EMChatThread object) {
                super.updateObject(ChatThreadHelper.toJson(object));
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
                post(() -> channel.invokeMethod(MethodKey.onChatThreadCreate, ChatThreadEventHelper.toJson(event)));
            }

            @Override
            public void onChatThreadUpdated(EMChatThreadEvent event) {
                post(() -> channel.invokeMethod(MethodKey.onChatThreadUpdate, ChatThreadEventHelper.toJson(event)));
            }

            @Override
            public void onChatThreadDestroyed(EMChatThreadEvent event) {
                post(() -> channel.invokeMethod(MethodKey.onChatThreadDestroy, ChatThreadEventHelper.toJson(event)));
            }

            @Override
            public void onChatThreadUserRemoved(EMChatThreadEvent event) {
                post(() -> channel.invokeMethod(MethodKey.onUserKickOutOfChatThread, ChatThreadEventHelper.toJson(event)));
            }
        };

        EMClient.getInstance().chatThreadManager().addChatThreadChangeListener(chatThreadChangeListener);
    }

    @Override
    public void unRegisterEaseListener() {
        EMClient.getInstance().chatThreadManager().removeChatThreadChangeListener(chatThreadChangeListener);
    }
}
