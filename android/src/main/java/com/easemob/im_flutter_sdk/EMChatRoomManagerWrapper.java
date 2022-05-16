package com.easemob.im_flutter_sdk;

import com.hyphenate.EMChatRoomChangeListener;
import com.hyphenate.chat.EMChatRoom;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMCursorResult;
import com.hyphenate.chat.EMGroupInfo;
import com.hyphenate.chat.EMPageResult;
import com.hyphenate.exceptions.HyphenateException;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.JSONMethodCodec;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class EMChatRoomManagerWrapper extends EMWrapper implements MethodChannel.MethodCallHandler {

    EMChatRoomManagerWrapper(FlutterPlugin.FlutterPluginBinding flutterPluginBinding, String channelName) {
        super(flutterPluginBinding, channelName);
        registerEaseListener();
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {

        JSONObject param = (JSONObject) call.arguments;
        try {
            if (EMSDKMethod.joinChatRoom.equals(call.method)) {
                joinChatRoom(param, call.method, result);
            } else if (EMSDKMethod.leaveChatRoom.equals(call.method)) {
                leaveChatRoom(param, call.method, result);
            } else if (EMSDKMethod.fetchPublicChatRoomsFromServer.equals(call.method)) {
                fetchPublicChatRoomsFromServer(param, call.method, result);
            } else if (EMSDKMethod.fetchChatRoomInfoFromServer.equals(call.method)) {
                fetchChatRoomInfoFromServer(param, call.method, result);
            } else if (EMSDKMethod.getChatRoom.equals(call.method)) {
                getChatRoom(param, call.method, result);
            } else if (EMSDKMethod.getAllChatRooms.equals(call.method)) {
                getAllChatRooms(param, call.method, result);
            } else if (EMSDKMethod.createChatRoom.equals(call.method)) {
                createChatRoom(param, call.method, result);
            } else if (EMSDKMethod.destroyChatRoom.equals(call.method)) {
                destroyChatRoom(param, call.method, result);
            } else if (EMSDKMethod.changeChatRoomSubject.equals(call.method)) {
                changeChatRoomSubject(param, call.method, result);
            } else if (EMSDKMethod.changeChatRoomDescription.equals(call.method)) {
                changeChatRoomDescription(param, call.method, result);
            } else if (EMSDKMethod.fetchChatRoomMembers.equals(call.method)) {
                fetchChatRoomMembers(param, call.method, result);
            } else if (EMSDKMethod.muteChatRoomMembers.equals(call.method)) {
                muteChatRoomMembers(param, call.method, result);
            } else if (EMSDKMethod.unMuteChatRoomMembers.equals(call.method)) {
                unMuteChatRoomMembers(param, call.method, result);
            } else if (EMSDKMethod.changeChatRoomOwner.equals(call.method)) {
                changeChatRoomOwner(param, call.method, result);
            } else if (EMSDKMethod.addChatRoomAdmin.equals(call.method)) {
                addChatRoomAdmin(param, call.method, result);
            } else if (EMSDKMethod.removeChatRoomAdmin.equals(call.method)) {
                removeChatRoomAdmin(param, call.method, result);
            } else if (EMSDKMethod.fetchChatRoomMuteList.equals(call.method)) {
                fetchChatRoomMuteList(param, call.method, result);
            } else if (EMSDKMethod.removeChatRoomMembers.equals(call.method)) {
                removeChatRoomMembers(param, call.method, result);
            } else if (EMSDKMethod.blockChatRoomMembers.equals(call.method)) {
                blockChatRoomMembers(param, call.method, result);
            } else if (EMSDKMethod.unBlockChatRoomMembers.equals(call.method)) {
                unBlockChatRoomMembers(param, call.method, result);
            } else if (EMSDKMethod.fetchChatRoomBlockList.equals(call.method)) {
                fetchChatRoomBlockList(param, call.method, result);
            } else if (EMSDKMethod.updateChatRoomAnnouncement.equals(call.method)) {
                updateChatRoomAnnouncement(param, call.method, result);
            } else if (EMSDKMethod.fetchChatRoomAnnouncement.equals(call.method)) {
                fetchChatRoomAnnouncement(param, call.method, result);
            } else if (EMSDKMethod.addMembersToChatRoomWhiteList.equals(call.method)) {
                addMembersToChatRoomWhiteList(param, call.method, result);
            } else if (EMSDKMethod.removeMembersFromChatRoomWhiteList.equals(call.method)) {
                removeMembersFromChatRoomWhiteList(param, call.method, result);
            } else if (EMSDKMethod.isMemberInChatRoomWhiteListFromServer.equals(call.method)) {
                isMemberInChatRoomWhiteListFromServer(param, call.method, result);
            } else if (EMSDKMethod.fetchChatRoomWhiteListFromServer.equals(call.method)) {
                fetchChatRoomWhiteListFromServer(param, call.method, result);
            } else if (EMSDKMethod.muteAllChatRoomMembers.equals(call.method)) {
                muteAllChatRoomsMembers(param, call.method, result);
            } else if (EMSDKMethod.unMuteAllChatRoomMembers.equals(call.method)) {
                unMuteAllChatRoomsMembers(param, call.method, result);
            } else {
                super.onMethodCall(call, result);
            }
        } catch (JSONException ignored) {

        }
    }

    private void joinChatRoom(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        String roomId = param.getString("roomId");
        EMValueWrapperCallBack<EMChatRoom> callBack = new EMValueWrapperCallBack<EMChatRoom>(result, channelName) {
            @Override
            public void onSuccess(EMChatRoom object) {
                updateObject(EMChatRoomHelper.toJson(object));
            }
        };

        EMClient.getInstance().chatroomManager().joinChatRoom(roomId, callBack);
    }

    private void leaveChatRoom(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        String roomId = param.getString("roomId");

        asyncRunnable(() -> {
            EMClient.getInstance().chatroomManager().leaveChatRoom(roomId);
            onSuccess(result, channelName, true);
        });
    }

    private void fetchPublicChatRoomsFromServer(JSONObject param, String channelName, MethodChannel.Result result)
            throws JSONException {
        int pageNum = param.getInt("pageNum");
        int pageSize = param.getInt("pageSize");

        EMClient.getInstance().chatroomManager().asyncFetchPublicChatRoomsFromServer(pageNum, pageSize,
                new EMValueWrapperCallBack<EMPageResult<EMChatRoom>>(result, channelName) {
                    @Override
                    public void onSuccess(EMPageResult object) {
                        updateObject(EMPageResultHelper.toJson(object));
                    }

                    @Override
                    public void onError(int code, String desc) {
                        super.onError(code, desc);
                    }
                });
    }

    private void fetchChatRoomInfoFromServer(JSONObject param, String channelName, MethodChannel.Result result)
            throws JSONException {
        String roomId = param.getString("roomId");
        boolean fetchMembers = param.getBoolean("fetchMembers");
        asyncRunnable(() -> {
            EMChatRoom room = null;
            try {
                if (fetchMembers) {
                    room = EMClient.getInstance().chatroomManager().fetchChatRoomFromServer(roomId, true);
                }else {
                    room = EMClient.getInstance().chatroomManager().fetchChatRoomFromServer(roomId);
                }
                onSuccess(result, channelName, EMChatRoomHelper.toJson(room));
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void getChatRoom(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        String roomId = param.getString("roomId");

        asyncRunnable(() -> {
            EMChatRoom room = EMClient.getInstance().chatroomManager().getChatRoom(roomId);
            onSuccess(result, channelName,room != null ? EMChatRoomHelper.toJson(room) : null);
        });
    }

    private void getAllChatRooms(JSONObject param, String channelName, MethodChannel.Result result)
            throws JSONException {
        asyncRunnable(() -> {
            List<EMChatRoom> list = EMClient.getInstance().chatroomManager().getAllChatRooms();
            List<Map<String, Object>> roomList = new ArrayList<>();
            for (EMChatRoom room : list) {
                roomList.add(EMChatRoomHelper.toJson(room));
            }
            onSuccess(result, channelName, roomList);
        });
    }

    private void createChatRoom(JSONObject param, String channelName, MethodChannel.Result result)
            throws JSONException {
        String subject = param.getString("subject");
        String description = param.getString("desc");
        String welcomeMessage = param.getString("welcomeMsg");
        int maxUserCount = param.getInt("maxUserCount");
        JSONArray members = param.getJSONArray("members");
        List<String> membersList = new ArrayList<>();
        for (int i = 0; i < members.length(); i++) {
            membersList.add((String) members.get(i));
        }
        asyncRunnable(() -> {
            try {
                EMChatRoom room = EMClient.getInstance().chatroomManager().createChatRoom(subject, description,
                        welcomeMessage, maxUserCount, membersList);
                onSuccess(result, channelName, EMChatRoomHelper.toJson(room));
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void destroyChatRoom(JSONObject param, String channelName, MethodChannel.Result result)
            throws JSONException {
        String roomId = param.getString("roomId");

        asyncRunnable(() -> {
            try {
                EMClient.getInstance().chatroomManager().destroyChatRoom(roomId);
                onSuccess(result, channelName, true);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void changeChatRoomSubject(JSONObject param, String channelName, MethodChannel.Result result)
            throws JSONException {
        String roomId = param.getString("roomId");
        String subject = param.getString("subject");

        asyncRunnable(() -> {
            try {
                EMChatRoom room = EMClient.getInstance().chatroomManager().changeChatRoomSubject(roomId, subject);
                onSuccess(result, channelName, EMChatRoomHelper.toJson(room));
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void changeChatRoomDescription(JSONObject param, String channelName, MethodChannel.Result result)
            throws JSONException {
        String roomId = param.getString("roomId");
        String description = param.getString("description");

        asyncRunnable(() -> {
            try {
                EMChatRoom room = EMClient.getInstance().chatroomManager().changeChatroomDescription(roomId,
                        description);
                onSuccess(result, channelName, EMChatRoomHelper.toJson(room));
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void fetchChatRoomMembers(JSONObject param, String channelName, MethodChannel.Result result)
            throws JSONException {
        String roomId = param.getString("roomId");
        String cursor = null;
        if(param.has("cursor")) {
            cursor = param.getString("cursor");
        }
        int pageSize = param.getInt("pageSize");

        String finalCursor = cursor;
        asyncRunnable(() -> {
            try {
                EMCursorResult<String> cursorResult = EMClient.getInstance().chatroomManager()
                        .fetchChatRoomMembers(roomId, finalCursor, pageSize);
                onSuccess(result, channelName, EMCursorResultHelper.toJson(cursorResult));
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void muteChatRoomMembers(JSONObject param, String channelName, MethodChannel.Result result)
            throws JSONException {
        String roomId = param.getString("roomId");
        long duration = Long.parseLong(param.getString("duration"));
        JSONArray muteMembers = param.getJSONArray("muteMembers");
        List<String> muteMembersList = new ArrayList<>();
        for (int i = 0; i < muteMembers.length(); i++) {
            muteMembersList.add((String) muteMembers.get(i));
        }

        asyncRunnable(() -> {
            try {
                EMChatRoom room = EMClient.getInstance().chatroomManager().muteChatRoomMembers(roomId, muteMembersList,
                        duration);
                onSuccess(result, channelName, EMChatRoomHelper.toJson(room));
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void unMuteChatRoomMembers(JSONObject param, String channelName, MethodChannel.Result result)
            throws JSONException {
        String roomId = param.getString("roomId");
        JSONArray muteMembers = param.getJSONArray("unMuteMembers");
        List<String> unMuteMembersList = new ArrayList<>();
        for (int i = 0; i < muteMembers.length(); i++) {
            unMuteMembersList.add((String) muteMembers.get(i));
        }

        asyncRunnable(() -> {
            try {
                EMChatRoom room = EMClient.getInstance().chatroomManager().unMuteChatRoomMembers(roomId,
                        unMuteMembersList);
                onSuccess(result, channelName, EMChatRoomHelper.toJson(room));
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void changeChatRoomOwner(JSONObject param, String channelName, MethodChannel.Result result)
            throws JSONException {
        String roomId = param.getString("roomId");
        String newOwner = param.getString("newOwner");

        asyncRunnable(() -> {
            try {
                EMChatRoom room = EMClient.getInstance().chatroomManager().changeOwner(roomId, newOwner);
                onSuccess(result, channelName, EMChatRoomHelper.toJson(room));
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void addChatRoomAdmin(JSONObject param, String channelName, MethodChannel.Result result)
            throws JSONException {
        String roomId = param.getString("roomId");
        String admin = param.getString("admin");

        asyncRunnable(() -> {
            try {
                EMChatRoom room = EMClient.getInstance().chatroomManager().addChatRoomAdmin(roomId, admin);
                onSuccess(result, channelName, EMChatRoomHelper.toJson(room));
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void removeChatRoomAdmin(JSONObject param, String channelName, MethodChannel.Result result)
            throws JSONException {
        String roomId = param.getString("roomId");
        String admin = param.getString("admin");

        asyncRunnable(() -> {
            try {
                EMChatRoom room = EMClient.getInstance().chatroomManager().removeChatRoomAdmin(roomId, admin);
                onSuccess(result, channelName, EMChatRoomHelper.toJson(room));
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void fetchChatRoomMuteList(JSONObject param, String channelName, MethodChannel.Result result)
            throws JSONException {
        String roomId = param.getString("roomId");
        int pageNum = param.getInt("pageNum");
        int pageSize = param.getInt("pageSize");

        asyncRunnable(() -> {
            try {
                Map map = EMClient.getInstance().chatroomManager().fetchChatRoomMuteList(roomId, pageNum, pageSize);
                onSuccess(result, channelName, map.keySet().toArray());
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void removeChatRoomMembers(JSONObject param, String channelName, MethodChannel.Result result)
            throws JSONException {
        String roomId = param.getString("roomId");
        JSONArray members = param.getJSONArray("members");
        List<String> membersList = new ArrayList<>();
        for (int i = 0; i < members.length(); i++) {
            membersList.add((String) members.get(i));
        }

        asyncRunnable(() -> {
            try {
                EMChatRoom room = EMClient.getInstance().chatroomManager().removeChatRoomMembers(roomId, membersList);
                onSuccess(result, channelName, EMChatRoomHelper.toJson(room));
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void blockChatRoomMembers(JSONObject param, String channelName, MethodChannel.Result result)
            throws JSONException {
        String roomId = param.getString("roomId");
        JSONArray blockMembers = param.getJSONArray("members");
        List<String> blockMembersList = new ArrayList<>();
        for (int i = 0; i < blockMembers.length(); i++) {
            blockMembersList.add((String) blockMembers.get(i));
        }

        asyncRunnable(() -> {
            try {
                EMChatRoom room = EMClient.getInstance().chatroomManager().blockChatroomMembers(roomId,
                        blockMembersList);
                onSuccess(result, channelName, EMChatRoomHelper.toJson(room));
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void unBlockChatRoomMembers(JSONObject param, String channelName, MethodChannel.Result result)
            throws JSONException {
        String roomId = param.getString("roomId");
        JSONArray blockMembers = param.getJSONArray("members");
        List<String> blockMembersList = new ArrayList<>();
        for (int i = 0; i < blockMembers.length(); i++) {
            blockMembersList.add((String) blockMembers.get(i));
        }

        asyncRunnable(() -> {
            try {
                EMChatRoom room = EMClient.getInstance().chatroomManager().unblockChatRoomMembers(roomId,
                        blockMembersList);
                onSuccess(result, channelName, EMChatRoomHelper.toJson(room));
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void fetchChatRoomBlockList(JSONObject param, String channelName, MethodChannel.Result result)
            throws JSONException {
        String roomId = param.getString("roomId");
        int pageNum = param.getInt("pageNum");
        int pageSize = param.getInt("pageSize");

        asyncRunnable(() -> {
            try {
                List<String> blockList = EMClient.getInstance().chatroomManager().fetchChatRoomBlackList(roomId,
                        pageNum, pageSize);
                onSuccess(result, channelName, blockList);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void updateChatRoomAnnouncement(JSONObject param, String channelName, MethodChannel.Result result)
            throws JSONException {
        String roomId = param.getString("roomId");
        String announcement = param.getString("announcement");

        asyncRunnable(() -> {
            try {
                EMClient.getInstance().chatroomManager().updateChatRoomAnnouncement(roomId, announcement);
                onSuccess(result, channelName, true);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void fetchChatRoomAnnouncement(JSONObject param, String channelName, MethodChannel.Result result)
            throws JSONException {
        String roomId = param.getString("roomId");

        asyncRunnable(() -> {
            try {
                String announcement = EMClient.getInstance().chatroomManager().fetchChatRoomAnnouncement(roomId);
                onSuccess(result, channelName, announcement);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void addMembersToChatRoomWhiteList(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        String roomId = param.getString("roomId");
        JSONArray jsonAry = param.getJSONArray("members");
        List<String> members = new ArrayList<>();
        for (int i = 0; i < jsonAry.length(); i++) {
            members.add((String) jsonAry.get(i));
        }
        EMValueWrapperCallBack<EMChatRoom> callBack = new EMValueWrapperCallBack<EMChatRoom>(
                result, channelName) {
            @Override
            public void onSuccess(EMChatRoom object) {
                updateObject(null);
            }
        };

        EMClient.getInstance().chatroomManager().addToChatRoomWhiteList(roomId, members, callBack);

    }

    private void removeMembersFromChatRoomWhiteList(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        String roomId = param.getString("roomId");
        JSONArray jsonAry = param.getJSONArray("members");
        List<String> members = new ArrayList<>();
        for (int i = 0; i < jsonAry.length(); i++) {
            members.add((String) jsonAry.get(i));
        }
        EMValueWrapperCallBack<EMChatRoom> callBack = new EMValueWrapperCallBack<EMChatRoom>(
                result, channelName) {
            @Override
            public void onSuccess(EMChatRoom object) {
                updateObject(null);
            }
        };

        EMClient.getInstance().chatroomManager().removeFromChatRoomWhiteList(roomId, members, callBack);
    }

    private void isMemberInChatRoomWhiteListFromServer(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        String roomId = param.getString("roomId");
        EMClient.getInstance().chatroomManager().checkIfInChatRoomWhiteList(roomId, new EMValueWrapperCallBack<Boolean>(result, channelName));
    }

    private void fetchChatRoomWhiteListFromServer(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        String roomId = param.getString("roomId");
        EMClient.getInstance().chatroomManager().fetchChatRoomWhiteList(roomId, new EMValueWrapperCallBack<List<String>>(result, channelName));
    }

    private void muteAllChatRoomsMembers(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        String roomId = param.getString("roomId");

        EMValueWrapperCallBack<EMChatRoom> callback = new EMValueWrapperCallBack<EMChatRoom>(result, channelName) {
            @Override
            public void onSuccess(EMChatRoom object) {
                updateObject(null);
            }
        };

        EMClient.getInstance().chatroomManager().muteAllMembers(roomId, callback);
    }

    private void unMuteAllChatRoomsMembers(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {
        String roomId = param.getString("roomId");

        EMValueWrapperCallBack<EMChatRoom> callback = new EMValueWrapperCallBack<EMChatRoom>(result, channelName) {
            @Override
            public void onSuccess(EMChatRoom object) {
                updateObject(null);
            }
        };

        EMClient.getInstance().chatroomManager().unmuteAllMembers(roomId, callback);
    }

    private void registerEaseListener() {
        EMClient.getInstance().chatroomManager().addChatRoomChangeListener(new EMChatRoomChangeListener() {

            @Override
            public void onWhiteListAdded(String chatRoomId, List<String> whitelist) {
                EMListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("roomId", chatRoomId);
                            data.put("whitelist", whitelist);
                            data.put("type", "onWhiteListAdded");
                            post(() -> channel.invokeMethod(EMSDKMethod.chatRoomChange, data));
                        }
                );

            }

            @Override
            public void onWhiteListRemoved(String chatRoomId, List<String> whitelist) {
                EMListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("roomId", chatRoomId);
                            data.put("whitelist", whitelist);
                            data.put("type", "onWhiteListRemoved");
                            post(() -> channel.invokeMethod(EMSDKMethod.chatRoomChange, data));
                        }
                );
            }

            @Override
            public void onAllMemberMuteStateChanged(String chatRoomId, boolean isMuted) {
                EMListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("roomId", chatRoomId);
                            data.put("isMuted", isMuted);
                            data.put("type", "onAllMemberMuteStateChanged");
                            post(() -> channel.invokeMethod(EMSDKMethod.chatRoomChange, data));
                        }
                );

            }

            @Override
            public void onChatRoomDestroyed(String roomId, String roomName) {
                EMListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("roomId", roomId);
                            data.put("roomName", roomName);
                            data.put("type", "onChatRoomDestroyed");
                            post(() -> channel.invokeMethod(EMSDKMethod.chatRoomChange, data));
                        }
                );

            }

            @Override
            public void onMemberJoined(String roomId, String participant) {
                EMListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("roomId", roomId);
                            data.put("participant", participant);
                            data.put("type", "onMemberJoined");
                            post(() -> channel.invokeMethod(EMSDKMethod.chatRoomChange, data));
                        }
                );
            }

            @Override
            public void onMemberExited(String roomId, String roomName, String participant) {
                EMListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("roomId", roomId);
                            data.put("roomName", roomName);
                            data.put("participant", participant);
                            data.put("type", "onMemberExited");
                            post(() -> channel.invokeMethod(EMSDKMethod.chatRoomChange, data));
                        }
                );

            }

            @Override
            public void onRemovedFromChatRoom(int reason, String roomId, String roomName, String participant) {
                EMListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("roomId", roomId);
                            data.put("roomName", roomName);
                            data.put("participant", participant);
                            data.put("type", "onRemovedFromChatRoom");
                            post(() -> channel.invokeMethod(EMSDKMethod.chatRoomChange, data));
                        }
                );

            }

            @Override
            public void onMuteListAdded(String chatRoomId, List<String> mutes, long expireTime) {
                EMListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("roomId", chatRoomId);
                            data.put("mutes", mutes);
                            data.put("expireTime", String.valueOf(expireTime));
                            data.put("type", "onMuteListAdded");
                            post(() -> channel.invokeMethod(EMSDKMethod.chatRoomChange, data));
                        }
                );
            }

            @Override
            public void onMuteListRemoved(String chatRoomId, List<String> mutes) {
                EMListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("roomId", chatRoomId);
                            data.put("mutes", mutes);
                            data.put("type", "onMuteListRemoved");
                            post(() -> channel.invokeMethod(EMSDKMethod.chatRoomChange, data));
                        }
                );

            }

            @Override
            public void onAdminAdded(String chatRoomId, String admin) {
                EMListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("roomId", chatRoomId);
                            data.put("admin", admin);
                            data.put("type", "onAdminAdded");
                            post(() -> channel.invokeMethod(EMSDKMethod.chatRoomChange, data));
                        }
                );

            }

            @Override
            public void onAdminRemoved(String chatRoomId, String admin) {
                EMListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("roomId", chatRoomId);
                            data.put("admin", admin);
                            data.put("type", "onAdminRemoved");
                            post(() -> channel.invokeMethod(EMSDKMethod.chatRoomChange, data));
                        }
                );
            }

            @Override
            public void onOwnerChanged(String chatRoomId, String newOwner, String oldOwner) {
                EMListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("roomId", chatRoomId);
                            data.put("newOwner", newOwner);
                            data.put("oldOwner", oldOwner);
                            data.put("type", "onOwnerChanged");
                            post(() -> channel.invokeMethod(EMSDKMethod.chatRoomChange, data));
                        }
                );

            }

            @Override
            public void onAnnouncementChanged(String chatRoomId, String announcement) {
                EMListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("roomId", chatRoomId);
                            data.put("announcement", announcement);
                            data.put("type", "onAnnouncementChanged");
                            post(() -> channel.invokeMethod(EMSDKMethod.chatRoomChange, data));
                        }
                );
            }
        });
    }
}
