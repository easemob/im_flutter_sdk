package com.easemob.im_flutter_sdk;

import com.hyphenate.EMChatRoomChangeListener;
import com.hyphenate.chat.EMChatRoom;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMCursorResult;
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
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {

        JSONObject param = (JSONObject) methodCall.arguments;
        try {
            if (EMSDKMethod.joinChatRoom.equals(methodCall.method)) {
                joinChatRoom(param, EMSDKMethod.joinChatRoom, result);
            } else if (EMSDKMethod.leaveChatRoom.equals(methodCall.method)) {
                leaveChatRoom(param, EMSDKMethod.joinChatRoom, result);
            } else if (EMSDKMethod.fetchPublicChatRoomsFromServer.equals(methodCall.method)) {
                fetchPublicChatRoomsFromServer(param, EMSDKMethod.fetchPublicChatRoomsFromServer, result);
            } else if (EMSDKMethod.fetchChatRoomInfoFromServer.equals(methodCall.method)) {
                fetchChatRoomInfoFromServer(param, EMSDKMethod.fetchChatRoomInfoFromServer, result);
            } else if (EMSDKMethod.getChatRoom.equals(methodCall.method)) {
                getChatRoom(param, EMSDKMethod.getChatRoom, result);
            } else if (EMSDKMethod.getAllChatRooms.equals(methodCall.method)) {
                getAllChatRooms(param, EMSDKMethod.getAllChatRooms, result);
            } else if (EMSDKMethod.createChatRoom.equals(methodCall.method)) {
                createChatRoom(param, EMSDKMethod.createChatRoom, result);
            } else if (EMSDKMethod.destroyChatRoom.equals(methodCall.method)) {
                destroyChatRoom(param, EMSDKMethod.destroyChatRoom, result);
            } else if (EMSDKMethod.changeChatRoomSubject.equals(methodCall.method)) {
                changeChatRoomSubject(param, EMSDKMethod.changeChatRoomSubject, result);
            } else if (EMSDKMethod.changeChatRoomDescription.equals(methodCall.method)) {
                changeChatRoomDescription(param, EMSDKMethod.changeChatRoomDescription, result);
            } else if (EMSDKMethod.fetchChatRoomMembers.equals(methodCall.method)) {
                fetchChatRoomMembers(param, EMSDKMethod.fetchChatRoomMembers, result);
            } else if (EMSDKMethod.muteChatRoomMembers.equals(methodCall.method)) {
                muteChatRoomMembers(param, EMSDKMethod.muteChatRoomMembers, result);
            } else if (EMSDKMethod.unMuteChatRoomMembers.equals(methodCall.method)) {
                unMuteChatRoomMembers(param, EMSDKMethod.unMuteChatRoomMembers, result);
            } else if (EMSDKMethod.changeChatRoomOwner.equals(methodCall.method)) {
                changeChatRoomOwner(param, EMSDKMethod.changeChatRoomOwner, result);
            } else if (EMSDKMethod.addChatRoomAdmin.equals(methodCall.method)) {
                addChatRoomAdmin(param, EMSDKMethod.addChatRoomAdmin, result);
            } else if (EMSDKMethod.removeChatRoomAdmin.equals(methodCall.method)) {
                removeChatRoomAdmin(param, EMSDKMethod.removeChatRoomAdmin, result);
            } else if (EMSDKMethod.fetchChatRoomMuteList.equals(methodCall.method)) {
                fetchChatRoomMuteList(param, EMSDKMethod.fetchChatRoomMuteList, result);
            } else if (EMSDKMethod.removeChatRoomMembers.equals(methodCall.method)) {
                removeChatRoomMembers(param, EMSDKMethod.removeChatRoomMembers, result);
            } else if (EMSDKMethod.blockChatRoomMembers.equals(methodCall.method)) {
                blockChatRoomMembers(param, EMSDKMethod.blockChatRoomMembers, result);
            } else if (EMSDKMethod.unBlockChatRoomMembers.equals(methodCall.method)) {
                unBlockChatRoomMembers(param, EMSDKMethod.unBlockChatRoomMembers, result);
            } else if (EMSDKMethod.fetchChatRoomBlockList.equals(methodCall.method)) {
                fetchChatRoomBlockList(param, EMSDKMethod.fetchChatRoomBlockList, result);
            } else if (EMSDKMethod.updateChatRoomAnnouncement.equals(methodCall.method)) {
                updateChatRoomAnnouncement(param, EMSDKMethod.updateChatRoomAnnouncement, result);
            } else if (EMSDKMethod.fetchChatRoomAnnouncement.equals(methodCall.method)) {
                fetchChatRoomAnnouncement(param, EMSDKMethod.fetchChatRoomAnnouncement, result);
            } else if (EMSDKMethod.addMembersToChatRoomWhiteList.equals(methodCall.method)) {
                addMembersToChatRoomWhiteList(param, EMSDKMethod.addMembersToChatRoomWhiteList, result);
            } else if (EMSDKMethod.removeMembersFromChatRoomWhiteList.equals(methodCall.method)) {
                removeMembersFromChatRoomWhiteList(param, EMSDKMethod.removeMembersFromChatRoomWhiteList, result);
            } else if (EMSDKMethod.isMemberInChatRoomWhiteListFromServer.equals(methodCall.method)) {
                isMemberInChatRoomWhiteListFromServer(param, EMSDKMethod.isMemberInChatRoomWhiteListFromServer, result);
            } else if (EMSDKMethod.fetchChatRoomWhiteListFromServer.equals(methodCall.method)) {
                fetchChatRoomWhiteListFromServer(param, EMSDKMethod.fetchChatRoomWhiteListFromServer, result);
            } else if (EMSDKMethod.muteAllChatRoomMembers.equals(methodCall.method)) {
                muteAllChatRoomsMembers(param, EMSDKMethod.fetchChatRoomWhiteListFromServer, result);
            } else if (EMSDKMethod.unMuteAllChatRoomMembers.equals(methodCall.method)) {
                unMuteAllChatRoomsMembers(param, EMSDKMethod.fetchChatRoomWhiteListFromServer, result);
            } else {
                super.onMethodCall(methodCall, result);
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

        asyncRunnable(() -> {
            try {
                EMChatRoom room = EMClient.getInstance().chatroomManager().fetchChatRoomFromServer(roomId);
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
            onSuccess(result, channelName, EMChatRoomHelper.toJson(room));
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
        String cursor = param.getString("cursor");
        int pageSize = param.getInt("pageSize");

        asyncRunnable(() -> {
            try {
                EMCursorResult<String> cursorResult = EMClient.getInstance().chatroomManager()
                        .fetchChatRoomMembers(roomId, cursor, pageSize);
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
                onSuccess(result, channelName, map);
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

    private void addMembersToChatRoomWhiteList(JSONObject param, String channelName, MethodChannel.Result result) {

    }

    private void removeMembersFromChatRoomWhiteList(JSONObject param, String channelName, MethodChannel.Result result) {

    }

    private void isMemberInChatRoomWhiteListFromServer(JSONObject param, String channelName, MethodChannel.Result result) {

    }

    private void fetchChatRoomWhiteListFromServer(JSONObject param, String channelName, MethodChannel.Result result) {

    }

    private void muteAllChatRoomsMembers(JSONObject param, String channelName, MethodChannel.Result result) {

    }

    private void unMuteAllChatRoomsMembers(JSONObject param, String channelName, MethodChannel.Result result) {

    }

    private void registerEaseListener() {
        EMClient.getInstance().chatroomManager().addChatRoomChangeListener(new EMChatRoomChangeListener() {

            @Override
            public void onWhiteListAdded(String chatRoomId, List<String> whitelist) {
                post(() -> {
                    Map<String, Object> data = new HashMap<>();
                    data.put("roomId", chatRoomId);
                    data.put("whitelist", whitelist);
                    data.put("type", "onWhiteListAdded");
                    channel.invokeMethod(EMSDKMethod.chatRoomChange, data);
                });
            }

            @Override
            public void onWhiteListRemoved(String chatRoomId, List<String> whitelist) {
                post(() -> {
                    Map<String, Object> data = new HashMap<>();
                    data.put("roomId", chatRoomId);
                    data.put("whitelist", whitelist);
                    data.put("type", "onWhiteListRemoved");
                    channel.invokeMethod(EMSDKMethod.chatRoomChange, data);
                });
            }

            @Override
            public void onAllMemberMuteStateChanged(String chatRoomId, boolean isMuted) {
                post(() -> {
                    Map<String, Object> data = new HashMap<>();
                    data.put("roomId", chatRoomId);
                    data.put("isMuted", isMuted);
                    data.put("type", "onAllMemberMuteStateChanged");
                    channel.invokeMethod(EMSDKMethod.chatRoomChange, data);
                });
            }

            @Override
            public void onChatRoomDestroyed(String roomId, String roomName) {
                post(() -> {
                    Map<String, Object> data = new HashMap<>();
                    data.put("roomId", roomId);
                    data.put("roomName", roomName);
                    data.put("type", "onChatRoomDestroyed");
                    channel.invokeMethod(EMSDKMethod.chatRoomChange, data);
                });
            }

            @Override
            public void onMemberJoined(String roomId, String participant) {
                post(() -> {
                    Map<String, Object> data = new HashMap<>();
                    data.put("roomId", roomId);
                    data.put("participant", participant);
                    data.put("type", "onMemberJoined");
                    channel.invokeMethod(EMSDKMethod.chatRoomChange, data);
                });
            }

            @Override
            public void onMemberExited(String roomId, String roomName, String participant) {
                post(() -> {
                    Map<String, Object> data = new HashMap<>();
                    data.put("roomId", roomId);
                    data.put("roomName", roomName);
                    data.put("participant", participant);
                    data.put("type", "onMemberExited");
                    channel.invokeMethod(EMSDKMethod.chatRoomChange, data);
                });
            }

            @Override
            public void onRemovedFromChatRoom(int reason, String roomId, String roomName, String participant) {
                post(() -> {
                    Map<String, Object> data = new HashMap<>();
                    data.put("roomId", roomId);
                    data.put("roomName", roomName);
                    data.put("participant", participant);
                    data.put("type", "onRemovedFromChatRoom");
                    channel.invokeMethod(EMSDKMethod.chatRoomChange, data);
                });
            }

            @Override
            public void onMuteListAdded(String chatRoomId, List<String> mutes, long expireTime) {
                post(() -> {
                    Map<String, Object> data = new HashMap<>();
                    data.put("roomId", chatRoomId);
                    data.put("mutes", mutes);
                    data.put("expireTime", String.valueOf(expireTime));
                    data.put("type", "onMuteListAdded");
                    channel.invokeMethod(EMSDKMethod.chatRoomChange, data);
                });
            }

            @Override
            public void onMuteListRemoved(String chatRoomId, List<String> mutes) {
                post(() -> {
                    Map<String, Object> data = new HashMap<>();
                    data.put("roomId", chatRoomId);
                    data.put("mutes", mutes);
                    data.put("type", "onMuteListRemoved");
                    channel.invokeMethod(EMSDKMethod.chatRoomChange, data);
                });
            }

            @Override
            public void onAdminAdded(String chatRoomId, String admin) {
                post(() -> {
                    Map<String, Object> data = new HashMap<>();
                    data.put("roomId", chatRoomId);
                    data.put("admin", admin);
                    data.put("type", "onAdminAdded");
                    channel.invokeMethod(EMSDKMethod.chatRoomChange, data);
                });
            }

            @Override
            public void onAdminRemoved(String chatRoomId, String admin) {
                post(() -> {
                    Map<String, Object> data = new HashMap<>();
                    data.put("roomId", chatRoomId);
                    data.put("admin", admin);
                    data.put("type", "onAdminRemoved");
                    channel.invokeMethod(EMSDKMethod.chatRoomChange, data);
                });
            }

            @Override
            public void onOwnerChanged(String chatRoomId, String newOwner, String oldOwner) {
                post(() -> {
                    Map<String, Object> data = new HashMap<>();
                    data.put("roomId", chatRoomId);
                    data.put("newOwner", newOwner);
                    data.put("oldOwner", oldOwner);
                    data.put("chatRoomChange", "onOwnerChanged");
                    channel.invokeMethod(EMSDKMethod.chatRoomChange, data);
                });
            }

            @Override
            public void onAnnouncementChanged(String chatRoomId, String announcement) {
                post(() -> {
                    Map<String, Object> data = new HashMap<>();
                    data.put("roomId", chatRoomId);
                    data.put("announcement", announcement);
                    data.put("chatRoomChange", "onAnnouncementChanged");
                    channel.invokeMethod(EMSDKMethod.chatRoomChange, data);
                });
            }
        });
    }
}
