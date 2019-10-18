package com.easemob.im_flutter_sdk;

import android.support.annotation.NonNull;

import com.hyphenate.EMCallBack;
import com.hyphenate.EMChatRoomChangeListener;
import com.hyphenate.EMValueCallBack;
import com.hyphenate.chat.EMChatRoom;
import com.hyphenate.chat.EMChatRoomManager;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMCursorResult;
import com.hyphenate.chat.EMPageResult;
import com.hyphenate.exceptions.HyphenateException;
import com.hyphenate.util.EMLog;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class EMChatRoomManagerWrapper implements MethodChannel.MethodCallHandler, EMWrapper  {

    private static final String TAG = "EMChatRoomManager";

    private EMChatRoomManager emChatRoomManager = null;

    private MethodChannel channel;

    EMChatRoomManagerWrapper(MethodChannel channel){
        this.channel = channel;
    }

    private void init() {
        registerChatRoomChangeListener();
    }

    /**
     * 注册聊天室监听
     */
    private void registerChatRoomChangeListener(){
        emChatRoomManager.addChatRoomChangeListener(new EMChatRoomChangeListener() {
            @Override
            public void onChatRoomDestroyed(String roomId, String roomName) {
                EMLog.d(TAG,"<---onChatRoomDestroyed--->"+"roomId: "+ roomId + " roomName: " + roomName );
                post((Void)->{
                   Map<String, Object> data = new HashMap<String, Object>();
                   data.put("roomId",roomId);
                   data.put("roomName",roomName);
                   channel.invokeMethod(EMSDKMethod.onChatRoomDestroyed,data);
                });
            }

            @Override
            public void onMemberJoined(String roomId, String participant) {
                EMLog.d(TAG,"<---onMemberJoined--->"+"roomId: "+ roomId + " participant: " + participant );
                post((Void)->{
                    Map<String, Object> data = new HashMap<String, Object>();
                    data.put("roomId",roomId);
                    data.put("participant",participant);
                    channel.invokeMethod(EMSDKMethod.onMemberJoined,data);
                });
            }

            @Override
            public void onMemberExited(String roomId, String roomName, String participant) {
                EMLog.d(TAG,"<---onMemberExited--->"+"roomId: "+ roomId + " roomName: " + roomName +" participant: "+ participant);
                post((Void)->{
                    Map<String, Object> data = new HashMap<String, Object>();
                    data.put("roomId",roomId);
                    data.put("roomName",roomName);
                    data.put("participant",participant);
                    channel.invokeMethod(EMSDKMethod.onMemberExited,data);
                });
            }

            @Override
            public void onRemovedFromChatRoom(int reason, String roomId, String roomName, String participant) {
                EMLog.d(TAG,"<---onRemovedFromChatRoom--->"+"roomId: "+ roomId + " roomName: " + roomName +" participant: "+ participant);
                post((Void)->{
                    Map<String, Object> data = new HashMap<String, Object>();
                    data.put("roomId",roomId);
                    data.put("roomName",roomName);
                    data.put("participant",participant);
                    channel.invokeMethod(EMSDKMethod.onRemovedFromChatRoom,data);
                });
            }

            @Override
            public void onMuteListAdded(String chatRoomId, List<String> mutes, long expireTime) {
                EMLog.d(TAG,"<---onMuteListAdded--->"+"roomId: "+ chatRoomId + " mutesList: " + mutes.toString() + " expireTime: " + expireTime);
                post((Void)->{
                    Map<String, Object> data = new HashMap<String, Object>();
                    data.put("roomId",chatRoomId);
                    data.put("roomName",mutes);
                    data.put("participant",expireTime);
                    channel.invokeMethod(EMSDKMethod.onMuteListAdded,data);
                });
            }

            @Override
            public void onMuteListRemoved(String chatRoomId, List<String> mutes) {
                EMLog.d(TAG,"<---onMuteListRemoved--->"+"roomId: "+ chatRoomId + " mutesList: " + mutes.toString() );
                post((Void)->{
                    Map<String, Object> data = new HashMap<String, Object>();
                    data.put("roomId",chatRoomId);
                    data.put("roomName",mutes);
                    channel.invokeMethod(EMSDKMethod.onMuteListRemoved,data);
                });
            }

            @Override
            public void onAdminAdded(String chatRoomId, String admin) {
                EMLog.d(TAG,"<---onAdminAdded--->"+"roomId: "+ chatRoomId + " admin: " + admin );
                post((Void)->{
                    Map<String, Object> data = new HashMap<String, Object>();
                    data.put("roomId",chatRoomId);
                    data.put("admin",admin);
                    channel.invokeMethod(EMSDKMethod.onAdminAdded,data);
                });
            }

            @Override
            public void onAdminRemoved(String chatRoomId, String admin) {
                EMLog.d(TAG,"<---onAdminRemoved--->"+"roomId: "+ chatRoomId + " admin: " + admin );
                post((Void)->{
                    Map<String, Object> data = new HashMap<String, Object>();
                    data.put("roomId",chatRoomId);
                    data.put("admin",admin);
                    channel.invokeMethod(EMSDKMethod.onAdminRemoved,data);
                });
            }

            @Override
            public void onOwnerChanged(String chatRoomId, String newOwner, String oldOwner) {
                EMLog.d(TAG,"<---onOwnerChanged--->"+"roomId: "+ chatRoomId + " oldOwner: " + oldOwner );
                post((Void)->{
                    Map<String, Object> data = new HashMap<String, Object>();
                    data.put("roomId",chatRoomId);
                    data.put("newOwner",newOwner);
                    data.put("oldOwner",oldOwner);
                    channel.invokeMethod(EMSDKMethod.onOwnerChanged,data);
                });
            }

            @Override
            public void onAnnouncementChanged(String chatRoomId, String announcement) {
                EMLog.d(TAG,"<---onAnnouncementChanged--->"+"roomId: "+ chatRoomId + " announcement: " + announcement );
                post((Void)->{
                    Map<String, Object> data = new HashMap<String, Object>();
                    data.put("roomId",chatRoomId);
                    data.put("announcement",announcement);
                    channel.invokeMethod(EMSDKMethod.onAnnouncementChanged,data);
                });
            }
        });
    }



    @Override
    public void onMethodCall(@NonNull MethodCall methodCall, @NonNull MethodChannel.Result result) {
        if(emChatRoomManager == null) {
            emChatRoomManager = EMClient.getInstance().chatroomManager();
            init();
        }
        if (EMSDKMethod.joinChatRoom.equals(methodCall.method)) {
            joinChatRoom(methodCall.arguments,result);
        }else if(EMSDKMethod.leaveChatRoom.equals(methodCall.method)){
            leaveChatRoom(methodCall.arguments,result);
        }else if(EMSDKMethod.fetchPublicChatRoomsFromServer.equals(methodCall.method)){
            fetchPublicChatRoomsFromServer(methodCall.arguments,result);
        }else if(EMSDKMethod.asyncFetchChatRoomFromServer.equals(methodCall.method)){
            asyncFetchChatRoomFromServer(methodCall.arguments,result);
        }else if(EMSDKMethod.getChatRoom.equals(methodCall.method)){
            getChatRoom(methodCall.arguments,result);
        }else if(EMSDKMethod.getAllChatRooms.equals(methodCall.method)){
            getAllChatRooms(methodCall.arguments,result);
        }else if(EMSDKMethod.asyncCreateChatRoom.equals(methodCall.method)){
            asyncCreateChatRoom(methodCall.arguments,result);
        }else if(EMSDKMethod.asyncDestroyChatRoom.equals(methodCall.method)){
            asyncDestroyChatRoom(methodCall.arguments,result);
        }else if(EMSDKMethod.asyncChangeChatRoomSubject.equals(methodCall.method)){
            asyncChangeChatRoomSubject(methodCall.arguments,result);
        }else if(EMSDKMethod.asyncChangeChatroomDescription.equals(methodCall.method)){
            asyncChangeChatroomDescription(methodCall.arguments,result);
        }else if(EMSDKMethod.asyncFetchChatRoomMembers.equals(methodCall.method)){
            asyncFetchChatRoomMembers(methodCall.arguments,result);
        }else if(EMSDKMethod.asyncMuteChatRoomMembers.equals(methodCall.method)){
            asyncMuteChatRoomMembers(methodCall.arguments,result);
        }else if(EMSDKMethod.asyncUnMuteChatRoomMembers.equals(methodCall.method)){
            asyncUnMuteChatRoomMembers(methodCall.arguments,result);
        }else if(EMSDKMethod.asyncChangeOwner.equals(methodCall.method)){
            asyncChangeOwner(methodCall.arguments,result);
        }else if(EMSDKMethod.asyncAddChatRoomAdmin.equals(methodCall.method)){
            asyncAddChatRoomAdmin(methodCall.arguments,result);
        }else if(EMSDKMethod.asyncRemoveChatRoomAdmin.equals(methodCall.method)){
            asyncRemoveChatRoomAdmin(methodCall.arguments,result);
        }else if(EMSDKMethod.asyncFetchChatRoomMuteList.equals(methodCall.method)){
            asyncFetchChatRoomMuteList(methodCall.arguments,result);
        }else if(EMSDKMethod.asyncRemoveChatRoomMembers.equals(methodCall.method)){
            asyncRemoveChatRoomMembers(methodCall.arguments,result);
        }else if(EMSDKMethod.asyncBlockChatroomMembers.equals(methodCall.method)){
            asyncBlockChatroomMembers(methodCall.arguments,result);
        }else if(EMSDKMethod.asyncUnBlockChatRoomMembers.equals(methodCall.method)){
            asyncUnBlockChatRoomMembers(methodCall.arguments,result);
        }else if(EMSDKMethod.asyncFetchChatRoomBlackList.equals(methodCall.method)){
            asyncFetchChatRoomBlackList(methodCall.arguments,result);
        }else if(EMSDKMethod.asyncUpdateChatRoomAnnouncement.equals(methodCall.method)){
            asyncUpdateChatRoomAnnouncement(methodCall.arguments,result);
        }else if(EMSDKMethod.asyncFetchChatRoomAnnouncement.equals(methodCall.method)){
            asyncFetchChatRoomAnnouncement(methodCall.arguments,result);
        }
    }
    private void joinChatRoom(Object args, MethodChannel.Result result){
        try {
            JSONObject jsonObject = (JSONObject) args;
            String chatRoomID = jsonObject.getString("toChatRoomId");
            EMClient.getInstance().chatroomManager().joinChatRoom(chatRoomID, new EMValueCallBack<EMChatRoom>() {
                @Override
                public void onSuccess(EMChatRoom value) {
                    Map<String, Object> data = new HashMap<String, Object>();
                    data.put("success", Boolean.TRUE);
                    result.success(data);
                }

                @Override
                public void onError(int error, String errorMsg) {
                    Map<String, Object> data = new HashMap<String, Object>();
                    data.put("success", Boolean.FALSE);
                    data.put("code", error);
                    data.put("errorMsg", errorMsg);
                    result.success(data);
                }
            });
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void leaveChatRoom(Object args, MethodChannel.Result result){
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        String chatRoomID = (String) argMap.get("toChatRoomId");
        EMClient.getInstance().chatroomManager().leaveChatRoom(chatRoomID);
    }

    private void fetchPublicChatRoomsFromServer(Object args, MethodChannel.Result result){
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        int pageNum = (int) argMap.get("pageNum");
        int pageSize = (int) argMap.get("pageSize");
        try {
            EMPageResult<EMChatRoom> emCursorResult = EMClient.getInstance().chatroomManager().fetchPublicChatRoomsFromServer(pageNum,pageSize);
            Map<String, Object> data = new HashMap<String, Object>();
            data.put("success", Boolean.TRUE);
            data.put("pageCount",emCursorResult.getPageCount());
            result.success(data);
        } catch (HyphenateException e) {
            e.printStackTrace();
        }
    }

    private void asyncFetchChatRoomFromServer(Object args, MethodChannel.Result result){
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        String roomId = (String) argMap.get("roomid");
        EMClient.getInstance().chatroomManager().asyncFetchChatRoomFromServer(roomId, new EMValueCallBack<EMChatRoom>() {
            @Override
            public void onSuccess(EMChatRoom value) {

            }

            @Override
            public void onError(int error, String errorMsg) {

            }
        });
    }

    private void getChatRoom(Object args, MethodChannel.Result result){
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        String roomId = (String) argMap.get("roomid");
        EMClient.getInstance().chatroomManager().getChatRoom(roomId);
        ///EMChatRoom 对象传递
    }

    private void getAllChatRooms(Object args, MethodChannel.Result result){
        EMClient.getInstance().chatroomManager().getAllChatRooms();
        ///list<EMChatRoom>传递
    }

    private void asyncCreateChatRoom(Object args, MethodChannel.Result result){
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        String subject = (String) argMap.get("subject");
        String description = (String) argMap.get("description");
        String welcomeMessage = (String) argMap.get("welcomeMessage");
        int maxUserCount = (int) argMap.get("maxUserCount");
        ArrayList<String> memberslist = (ArrayList<String>) argMap.get("members");
        EMClient.getInstance().chatroomManager().asyncCreateChatRoom(subject, description, welcomeMessage, maxUserCount, memberslist, new EMValueCallBack<EMChatRoom>() {
            @Override
            public void onSuccess(EMChatRoom value) {

            }

            @Override
            public void onError(int error, String errorMsg) {

            }
        });
    }

    private void asyncDestroyChatRoom(Object args, MethodChannel.Result result){
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        String chatRoomId = (String) argMap.get("chatRoomId");
        EMClient.getInstance().chatroomManager().asyncDestroyChatRoom(chatRoomId, new EMCallBack() {
            @Override
            public void onSuccess() {

            }

            @Override
            public void onError(int code, String error) {

            }

            @Override
            public void onProgress(int progress, String status) {

            }
        });
    }

    private void asyncChangeChatRoomSubject(Object args, MethodChannel.Result result){
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        String chatRoomId = (String) argMap.get("chatRoomId");
        String newSubject = (String) argMap.get("newSubject");
        EMClient.getInstance().chatroomManager().asyncChangeChatRoomSubject(chatRoomId, newSubject, new EMValueCallBack<EMChatRoom>() {
            @Override
            public void onSuccess(EMChatRoom value) {

            }

            @Override
            public void onError(int error, String errorMsg) {

            }
        });
    }

    private void asyncChangeChatroomDescription(Object args, MethodChannel.Result result){
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        String chatRoomId = (String) argMap.get("chatRoomId");
        String newDescription = (String) argMap.get("newDescription");
        EMClient.getInstance().chatroomManager().asyncChangeChatroomDescription(chatRoomId, newDescription, new EMValueCallBack<EMChatRoom>() {
            @Override
            public void onSuccess(EMChatRoom value) {

            }

            @Override
            public void onError(int error, String errorMsg) {

            }
        });
    }

    private void asyncFetchChatRoomMembers(Object args, MethodChannel.Result result){
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        String chatRoomId = (String) argMap.get("chatRoomId");
        String cursor = (String) argMap.get("cursor");
        int pageSize = (int) argMap.get("pageSize");
        EMClient.getInstance().chatroomManager().asyncFetchChatRoomMembers(chatRoomId, cursor, pageSize, new EMValueCallBack<EMCursorResult<String>>() {
            @Override
            public void onSuccess(EMCursorResult<String> value) {

            }

            @Override
            public void onError(int error, String errorMsg) {

            }
        });
    }

    private void asyncMuteChatRoomMembers(Object args, MethodChannel.Result result){
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        String chatRoomId = (String) argMap.get("chatRoomId");
        ArrayList<String> muteMembersList = (ArrayList<String>) argMap.get("muteMembers");
        long duration = (long) argMap.get("duration");
        EMClient.getInstance().chatroomManager().asyncMuteChatRoomMembers(chatRoomId, muteMembersList, duration, new EMValueCallBack<EMChatRoom>() {
            @Override
            public void onSuccess(EMChatRoom value) {

            }

            @Override
            public void onError(int error, String errorMsg) {

            }
        });
    }

    private void asyncUnMuteChatRoomMembers(Object args, MethodChannel.Result result){
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        String chatRoomId = (String) argMap.get("chatRoomId");
        ArrayList<String> unMuteMembersList = (ArrayList<String>) argMap.get("members");
        EMClient.getInstance().chatroomManager().asyncUnMuteChatRoomMembers(chatRoomId, unMuteMembersList, new EMValueCallBack<EMChatRoom>() {
            @Override
            public void onSuccess(EMChatRoom value) {

            }

            @Override
            public void onError(int error, String errorMsg) {

            }
        });
    }

    private void asyncChangeOwner(Object args, MethodChannel.Result result){
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        String chatRoomId = (String) argMap.get("chatRoomId");
        String newOwner = (String) argMap.get("newOwner");
        try {
            EMClient.getInstance().chatroomManager().asyncChangeOwner(chatRoomId, newOwner, new EMValueCallBack<EMChatRoom>() {
                @Override
                public void onSuccess(EMChatRoom value) {

                }

                @Override
                public void onError(int error, String errorMsg) {

                }
            });
        } catch (HyphenateException e) {
            e.printStackTrace();
        }
    }

    private void asyncAddChatRoomAdmin(Object args, MethodChannel.Result result){
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        String chatRoomId = (String) argMap.get("chatRoomId");
        String admin = (String) argMap.get("admin");
        EMClient.getInstance().chatroomManager().asyncAddChatRoomAdmin(chatRoomId, admin, new EMValueCallBack<EMChatRoom>() {
            @Override
            public void onSuccess(EMChatRoom value) {

            }

            @Override
            public void onError(int error, String errorMsg) {

            }
        });
    }

    private void asyncRemoveChatRoomAdmin(Object args, MethodChannel.Result result){
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        String chatRoomId = (String) argMap.get("chatRoomId");
        String admin = (String) argMap.get("admin");
        EMClient.getInstance().chatroomManager().asyncRemoveChatRoomAdmin(chatRoomId, admin, new EMValueCallBack<EMChatRoom>() {
            @Override
            public void onSuccess(EMChatRoom value) {

            }

            @Override
            public void onError(int error, String errorMsg) {

            }
        });
    }

    private void asyncFetchChatRoomMuteList(Object args, MethodChannel.Result result){
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        String chatRoomId = (String) argMap.get("chatRoomId");
        int pageNum = (int) argMap.get("pageNum");
        int pageSize = (int) argMap.get("pageSize");
        EMClient.getInstance().chatroomManager().asyncFetchChatRoomMuteList(chatRoomId, pageNum, pageSize, new EMValueCallBack<Map<String, Long>>() {
            @Override
            public void onSuccess(Map<String, Long> value) {

            }

            @Override
            public void onError(int error, String errorMsg) {

            }
        });
    }
    private void asyncRemoveChatRoomMembers(Object args, MethodChannel.Result result){
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        String chatRoomId = (String) argMap.get("chatRoomId");
        ArrayList<String> membersList = (ArrayList<String>) argMap.get("members");
        EMClient.getInstance().chatroomManager().asyncRemoveChatRoomMembers(chatRoomId, membersList, new EMValueCallBack<EMChatRoom>() {
            @Override
            public void onSuccess(EMChatRoom value) {

            }

            @Override
            public void onError(int error, String errorMsg) {

            }
        });
    }
    private void asyncBlockChatroomMembers(Object args, MethodChannel.Result result){
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        String chatRoomId = (String) argMap.get("chatRoomId");
        ArrayList<String> blockMembersList = (ArrayList<String>) argMap.get("members");
        EMClient.getInstance().chatroomManager().asyncBlockChatroomMembers(chatRoomId, blockMembersList, new EMValueCallBack<EMChatRoom>() {
            @Override
            public void onSuccess(EMChatRoom value) {

            }

            @Override
            public void onError(int error, String errorMsg) {

            }
        });
    }
    private void asyncUnBlockChatRoomMembers(Object args, MethodChannel.Result result){
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        String chatRoomId = (String) argMap.get("chatRoomId");
        ArrayList<String> blockMembersList = (ArrayList<String>) argMap.get("members");
        EMClient.getInstance().chatroomManager().asyncUnBlockChatRoomMembers(chatRoomId, blockMembersList, new EMValueCallBack<EMChatRoom>() {
            @Override
            public void onSuccess(EMChatRoom value) {

            }

            @Override
            public void onError(int error, String errorMsg) {

            }
        });
    }
    private void asyncFetchChatRoomBlackList(Object args, MethodChannel.Result result){
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        String chatRoomId = (String) argMap.get("chatRoomId");
        int pageNum = (int) argMap.get("pageNum");
        int pageSize = (int) argMap.get("pageSize");
        EMClient.getInstance().chatroomManager().asyncFetchChatRoomBlackList(chatRoomId, pageNum, pageSize, new EMValueCallBack<List<String>>() {
            @Override
            public void onSuccess(List<String> value) {

            }

            @Override
            public void onError(int error, String errorMsg) {

            }
        });
    }
    private void asyncUpdateChatRoomAnnouncement(Object args, MethodChannel.Result result){
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        String chatRoomId = (String) argMap.get("chatRoomId");
        String announcement = (String) argMap.get("announcement");
        EMClient.getInstance().chatroomManager().asyncUpdateChatRoomAnnouncement(chatRoomId, announcement, new EMCallBack() {
            @Override
            public void onSuccess() {

            }

            @Override
            public void onError(int code, String error) {

            }

            @Override
            public void onProgress(int progress, String status) {

            }
        });
    }
    private void asyncFetchChatRoomAnnouncement(Object args, MethodChannel.Result result){
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        String chatRoomId = (String) argMap.get("chatRoomId");
        EMClient.getInstance().chatroomManager().asyncFetchChatRoomAnnouncement(chatRoomId, new EMValueCallBack<String>() {
            @Override
            public void onSuccess(String value) {

            }

            @Override
            public void onError(int error, String errorMsg) {

            }
        });
    }


    public void onSuccess(MethodChannel.Result result) {
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.TRUE);
        result.success(data);
    }

    public void onError(MethodChannel.Result result, HyphenateException e) {
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.FALSE);
        data.put("code", e.getErrorCode());
        data.put("desc", e.getDescription());
        result.success(data);
    }
}
