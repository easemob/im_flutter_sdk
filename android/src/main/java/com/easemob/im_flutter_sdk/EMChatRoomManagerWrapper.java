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

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
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
                   data.put("ChatRoomChange","onChatRoomDestroyed");
                   channel.invokeMethod(EMSDKMethod.ChatRoomChange,data);
                });
            }

            @Override
            public void onMemberJoined(String roomId, String participant) {
                EMLog.d(TAG,"<---onMemberJoined--->"+"roomId: "+ roomId + " participant: " + participant );
                post((Void)->{
                    Map<String, Object> data = new HashMap<String, Object>();
                    data.put("roomId",roomId);
                    data.put("participant",participant);
                    data.put("ChatRoomChange","onMemberJoined");
                    channel.invokeMethod(EMSDKMethod.ChatRoomChange,data);
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
                    data.put("ChatRoomChange","onMemberExited");
                    channel.invokeMethod(EMSDKMethod.ChatRoomChange,data);
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
                    data.put("ChatRoomChange","onRemovedFromChatRoom");
                    channel.invokeMethod(EMSDKMethod.ChatRoomChange,data);
                });
            }

            @Override
            public void onMuteListAdded(String chatRoomId, List<String> mutes, long expireTime) {
                EMLog.d(TAG,"<---onMuteListAdded--->"+"roomId: "+ chatRoomId + " mutesList: " + mutes.toString() + " expireTime: " + expireTime);
                post((Void)->{
                    Map<String, Object> data = new HashMap<String, Object>();
                    data.put("roomId",chatRoomId);
                    data.put("roomName",mutes);
                    data.put("expireTime",String.valueOf(expireTime));
                    data.put("ChatRoomChange","onMuteListAdded");
                    channel.invokeMethod(EMSDKMethod.ChatRoomChange,data);
                });
            }

            @Override
            public void onMuteListRemoved(String chatRoomId, List<String> mutes) {
                EMLog.d(TAG,"<---onMuteListRemoved--->"+"roomId: "+ chatRoomId + " mutesList: " + mutes.toString() );
                post((Void)->{
                    Map<String, Object> data = new HashMap<String, Object>();
                    data.put("roomId",chatRoomId);
                    data.put("mutes",mutes);
                    data.put("ChatRoomChange","onMuteListRemoved");
                    channel.invokeMethod(EMSDKMethod.ChatRoomChange,data);
                });
            }

            @Override
            public void onAdminAdded(String chatRoomId, String admin) {
                EMLog.d(TAG,"<---onAdminAdded--->"+"roomId: "+ chatRoomId + " admin: " + admin );
                post((Void)->{
                    Map<String, Object> data = new HashMap<String, Object>();
                    data.put("roomId",chatRoomId);
                    data.put("admin",admin);
                    data.put("ChatRoomChange","onAdminAdded");
                    channel.invokeMethod(EMSDKMethod.ChatRoomChange,data);
                });
            }

            @Override
            public void onAdminRemoved(String chatRoomId, String admin) {
                EMLog.d(TAG,"<---onAdminRemoved--->"+"roomId: "+ chatRoomId + " admin: " + admin );
                post((Void)->{
                    Map<String, Object> data = new HashMap<String, Object>();
                    data.put("roomId",chatRoomId);
                    data.put("admin",admin);
                    data.put("ChatRoomChange","onAdminRemoved");
                    channel.invokeMethod(EMSDKMethod.ChatRoomChange,data);
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
                    data.put("ChatRoomChange","onOwnerChanged");
                    channel.invokeMethod(EMSDKMethod.ChatRoomChange,data);
                });
            }

            @Override
            public void onAnnouncementChanged(String chatRoomId, String announcement) {
                EMLog.d(TAG,"<---onAnnouncementChanged--->"+"roomId: "+ chatRoomId + " announcement: " + announcement );
                post((Void)->{
                    Map<String, Object> data = new HashMap<String, Object>();
                    data.put("roomId",chatRoomId);
                    data.put("announcement",announcement);
                    data.put("ChatRoomChange","onAnnouncementChanged");
                    channel.invokeMethod(EMSDKMethod.ChatRoomChange,data);
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
            String chatRoomId = jsonObject.getString("roomId");
            emChatRoomManager.joinChatRoom(chatRoomId,new EMValueWrapperCallBack<>(result));
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void leaveChatRoom(Object args, MethodChannel.Result result){
        try {
            JSONObject jsonObject = (JSONObject) args;
            String chatRoomId = jsonObject.getString("roomId");
            emChatRoomManager.leaveChatRoom(chatRoomId);
            Map<String, Object> data = new HashMap<String, Object>();
            data.put("success", Boolean.TRUE);
            result.success(data);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void fetchPublicChatRoomsFromServer(Object args, MethodChannel.Result result){
        try {
            JSONObject jsonObject = (JSONObject) args;
            int pageNum = jsonObject.getInt("pageNum");
            int pageSize = jsonObject.getInt("pageSize");
            EMPageResult<EMChatRoom> emCursorResult = emChatRoomManager.fetchPublicChatRoomsFromServer(pageNum,pageSize);
            Map<String, Object> data = new HashMap<String, Object>();
            data.put("success", Boolean.TRUE);
            data.put("pageCount",emCursorResult.getPageCount());
            result.success(data);
        } catch (JSONException | HyphenateException e) {
            e.printStackTrace();
        }
    }

    private void asyncFetchChatRoomFromServer(Object args, MethodChannel.Result result){
        try {
            JSONObject jsonObject = (JSONObject) args;
            String chatRoomId = jsonObject.getString("roomId");
            emChatRoomManager.asyncFetchChatRoomFromServer(chatRoomId,new EMValueWrapperCallBack<EMChatRoom>(result));
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void getChatRoom(Object args, MethodChannel.Result result){
        try {
            JSONObject jsonObject = (JSONObject) args;
            String chatRoomId = jsonObject.getString("roomId");
            EMChatRoom chatRoom = emChatRoomManager.getChatRoom(chatRoomId);
            Map<String, Object> data = new HashMap<String, Object>();
            data.put("success", Boolean.TRUE);
            data.put("chatRoomInfo", EMHelper.chatRoomToStringMap(chatRoom));
            result.success(data);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void getAllChatRooms(Object args, MethodChannel.Result result){
        List<EMChatRoom> list = emChatRoomManager.getAllChatRooms();
        List<Map<String ,Object>> roomlist = new LinkedList<>();
        for (EMChatRoom emChatRoom : list) {
            roomlist.add(EMHelper.chatRoomToStringMap(emChatRoom));
        }
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.TRUE);
        data.put("allChatRoom", roomlist);
        result.success(data);
    }

    private void asyncCreateChatRoom(Object args, MethodChannel.Result result){
        try {
            JSONObject jsonObject = (JSONObject) args;
            String subject = jsonObject.getString("subject");
            String description = jsonObject.getString("description");
            String welcomeMessage = jsonObject.getString("welcomeMessage");
            int maxUserCount = jsonObject.getInt("maxUserCount");
            JSONArray members = jsonObject.getJSONArray("members");
            List<String> membersList = new LinkedList<>();
            for (int i = 0; i < members.length(); i++) {
                membersList.add((String) members.get(i));
            }
            emChatRoomManager.asyncCreateChatRoom(subject,description,welcomeMessage,maxUserCount,membersList,new EMValueWrapperCallBack<EMChatRoom>(result));
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void asyncDestroyChatRoom(Object args, MethodChannel.Result result){
        try {
            JSONObject jsonObject = (JSONObject) args;
            String chatRoomId = jsonObject.getString("roomId");
            emChatRoomManager.asyncDestroyChatRoom(chatRoomId,new EMWrapperCallBack(result));
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void asyncChangeChatRoomSubject(Object args, MethodChannel.Result result){
        try {
            JSONObject jsonObject = (JSONObject) args;
            String chatRoomId = jsonObject.getString("roomId");
            String newSubject = jsonObject.getString("newSubject");
            emChatRoomManager.asyncChangeChatRoomSubject(chatRoomId,newSubject,new EMValueWrapperCallBack<EMChatRoom>(result));
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void asyncChangeChatroomDescription(Object args, MethodChannel.Result result){
        try {
            JSONObject jsonObject = (JSONObject) args;
            String chatRoomId = jsonObject.getString("roomId");
            String newDescription = jsonObject.getString("newDescription");
            emChatRoomManager.asyncChangeChatroomDescription(chatRoomId,newDescription,new EMValueWrapperCallBack<EMChatRoom>(result));
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void asyncFetchChatRoomMembers(Object args, MethodChannel.Result result){
        try {
            JSONObject jsonObject = (JSONObject) args;
            String chatRoomId = jsonObject.getString("roomId");
            String cursor = jsonObject.getString("cursor");
            int pageSize = jsonObject.getInt("pageSize");
            emChatRoomManager.asyncFetchChatRoomMembers(chatRoomId,cursor,pageSize,new EMValueWrapperCallBack<EMCursorResult<String>>(result));
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void asyncMuteChatRoomMembers(Object args, MethodChannel.Result result){
        try {
            JSONObject jsonObject = (JSONObject) args;
            String chatRoomId = jsonObject.getString("roomId");
            long duration = jsonObject.getLong("duration");
            JSONArray muteMembers = jsonObject.getJSONArray("muteMembers");
            List<String> muteMembersList = new LinkedList<>();
            for (int i = 0; i < muteMembers.length(); i++) {
                muteMembersList.add((String) muteMembers.get(i));
            }
            emChatRoomManager.asyncMuteChatRoomMembers(chatRoomId,muteMembersList,duration,new EMValueWrapperCallBack<EMChatRoom>(result));
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void asyncUnMuteChatRoomMembers(Object args, MethodChannel.Result result){
        try {
            JSONObject jsonObject = (JSONObject) args;
            String chatRoomId = jsonObject.getString("roomId");
            JSONArray muteMembers = jsonObject.getJSONArray("muteMembers");
            List<String> unMuteMembersList = new LinkedList<>();
            for (int i = 0; i < muteMembers.length(); i++) {
                unMuteMembersList.add((String) muteMembers.get(i));
            }
            emChatRoomManager.asyncUnMuteChatRoomMembers(chatRoomId,unMuteMembersList,new EMValueWrapperCallBack<EMChatRoom>(result));
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void asyncChangeOwner(Object args, MethodChannel.Result result){
        try {
            JSONObject jsonObject = (JSONObject) args;
            String chatRoomId = jsonObject.getString("roomId");
            String newOwner = jsonObject.getString("newOwner");
            emChatRoomManager.asyncChangeOwner(chatRoomId,newOwner,new EMValueWrapperCallBack<EMChatRoom>(result));
        } catch (JSONException | HyphenateException e) {
            e.printStackTrace();
        }
    }

    private void asyncAddChatRoomAdmin(Object args, MethodChannel.Result result){
        try {
            JSONObject jsonObject = (JSONObject) args;
            String chatRoomID = jsonObject.getString("roomId");
            String admin = jsonObject.getString("admin");
            emChatRoomManager.asyncAddChatRoomAdmin(chatRoomID,admin,new EMValueWrapperCallBack<EMChatRoom>(result));
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void asyncRemoveChatRoomAdmin(Object args, MethodChannel.Result result){
        try {
            JSONObject jsonObject = (JSONObject) args;
            String chatRoomId = jsonObject.getString("roomId");
            String admin = jsonObject.getString("admin");
            emChatRoomManager.asyncRemoveChatRoomAdmin(chatRoomId,admin,new EMValueWrapperCallBack<EMChatRoom>(result));
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void asyncFetchChatRoomMuteList(Object args, MethodChannel.Result result){
        try {
            JSONObject jsonObject = (JSONObject) args;
            String chatRoomId = jsonObject.getString("roomId");
            int pageNum = jsonObject.getInt("pageNum");
            int pageSize = jsonObject.getInt("pageSize");
            emChatRoomManager.asyncFetchChatRoomMuteList(chatRoomId,pageNum,pageSize,new EMValueWrapperCallBack<Map<String, Long>>(result));
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }
    private void asyncRemoveChatRoomMembers(Object args, MethodChannel.Result result){
        try {
            JSONObject jsonObject = (JSONObject) args;
            String chatRoomId = jsonObject.getString("roomId");
            JSONArray members = jsonObject.getJSONArray("members");
            List<String> membersList = new LinkedList<>();
            for (int i = 0; i < members.length(); i++) {
                membersList.add((String) members.get(i));
            }
            emChatRoomManager.asyncRemoveChatRoomMembers(chatRoomId,membersList,new EMValueWrapperCallBack<EMChatRoom>(result));
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }
    private void asyncBlockChatroomMembers(Object args, MethodChannel.Result result){
        try {
            JSONObject jsonObject = (JSONObject) args;
            String chatRoomId = jsonObject.getString("roomId");
            JSONArray blockMembers = jsonObject.getJSONArray("members");
            List<String> blockMembersList = new LinkedList<>();
            for (int i = 0; i < blockMembers.length(); i++) {
                blockMembersList.add((String) blockMembers.get(i));
            }
            emChatRoomManager.asyncBlockChatroomMembers(chatRoomId,blockMembersList,new EMValueWrapperCallBack<EMChatRoom>(result));
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }
    private void asyncUnBlockChatRoomMembers(Object args, MethodChannel.Result result){
        try {
            JSONObject jsonObject = (JSONObject) args;
            String chatRoomId = jsonObject.getString("roomId");
            JSONArray unBlockMembers = jsonObject.getJSONArray("members");
            List<String> unBlockMembersList = new LinkedList<>();
            for (int i = 0; i < unBlockMembers.length(); i++) {
                unBlockMembersList.add((String) unBlockMembers.get(i));
            }
            emChatRoomManager.asyncUnBlockChatRoomMembers(chatRoomId,unBlockMembersList,new EMValueWrapperCallBack<EMChatRoom>(result));
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }
    private void asyncFetchChatRoomBlackList(Object args, MethodChannel.Result result){
        try {
            JSONObject jsonObject = (JSONObject) args;
            String chatRoomId = jsonObject.getString("roomId");
            int pageNum = jsonObject.getInt("pageNum");
            int pageSize = jsonObject.getInt("pageSize");
            emChatRoomManager.asyncFetchChatRoomBlackList(chatRoomId,pageNum,pageSize,new EMValueWrapperCallBack<List<String>>(result));
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }
    private void asyncUpdateChatRoomAnnouncement(Object args, MethodChannel.Result result){
        try {
            JSONObject jsonObject = (JSONObject) args;
            String chatRoomId = jsonObject.getString("roomId");
            String announcement = jsonObject.getString("announcement");
            emChatRoomManager.asyncUpdateChatRoomAnnouncement(chatRoomId,announcement,new EMWrapperCallBack(result));
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }
    private void asyncFetchChatRoomAnnouncement(Object args, MethodChannel.Result result){
        try {
            JSONObject jsonObject = (JSONObject) args;
            String chatRoomId = jsonObject.getString("roomId");
            emChatRoomManager.asyncFetchChatRoomAnnouncement(chatRoomId,new EMValueWrapperCallBack<String>(result));
        } catch (JSONException e) {
            e.printStackTrace();
        }
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
