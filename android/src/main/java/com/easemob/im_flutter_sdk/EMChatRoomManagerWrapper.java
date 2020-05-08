package com.easemob.im_flutter_sdk;

import com.hyphenate.EMChatRoomChangeListener;
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


    /**
     * 注册聊天室监听
     */
    private void registerChatRoomChangeListener(){
        emChatRoomManager.addChatRoomChangeListener(new EMChatRoomChangeListener() {

            @Override
            public void onWhiteListAdded(String chatRoomId, List<String> whitelist) {

            }

            @Override
            public void onWhiteListRemoved(String chatRoomId, List<String> whitelist) {

            }

            @Override
            public void onAllMemberMuteStateChanged(String chatRoomId, boolean isMuted) {

            }

            @Override
            public void onChatRoomDestroyed(String roomId, String roomName) {
                EMLog.d(TAG,"<---onChatRoomDestroyed--->"+"roomId: "+ roomId + " roomName: " + roomName );
                post(new Runnable() {
                    @Override
                    public void run() {
                   Map<String, Object> data = new HashMap<String, Object>();
                   data.put("roomId",roomId);
                   data.put("roomName",roomName);
                   data.put("chatRoomChange","onChatRoomDestroyed");
                   channel.invokeMethod(EMSDKMethod.chatRoomChange,data);
                    }});
            }

            @Override
            public void onMemberJoined(String roomId, String participant) {
                EMLog.d(TAG,"<---onMemberJoined--->"+"roomId: "+ roomId + " participant: " + participant );
                post(new Runnable() {
                    @Override
                    public void run() {
                    Map<String, Object> data = new HashMap<String, Object>();
                    data.put("roomId",roomId);
                    data.put("participant",participant);
                    data.put("chatRoomChange","onMemberJoined");
                    channel.invokeMethod(EMSDKMethod.chatRoomChange,data);
                    }});
            }

            @Override
            public void onMemberExited(String roomId, String roomName, String participant) {
                EMLog.d(TAG,"<---onMemberExited--->"+"roomId: "+ roomId + " roomName: " + roomName +" participant: "+ participant);
                post(new Runnable() {
                    @Override
                    public void run() {
                    Map<String, Object> data = new HashMap<String, Object>();
                    data.put("roomId",roomId);
                    data.put("roomName",roomName);
                    data.put("participant",participant);
                    data.put("chatRoomChange","onMemberExited");
                    channel.invokeMethod(EMSDKMethod.chatRoomChange,data);
                    }});
            }

            @Override
            public void onRemovedFromChatRoom(int reason, String roomId, String roomName, String participant) {
                EMLog.d(TAG,"<---onRemovedFromChatRoom--->"+"roomId: "+ roomId + " roomName: " + roomName +" participant: "+ participant);
                post(new Runnable() {
                    @Override
                    public void run() {
                    Map<String, Object> data = new HashMap<String, Object>();
                    data.put("roomId",roomId);
                    data.put("roomName",roomName);
                    data.put("participant",participant);
                    data.put("reason",reason);
                    data.put("chatRoomChange","onRemovedFromChatRoom");
                    channel.invokeMethod(EMSDKMethod.chatRoomChange,data);
                }});
            }

            @Override
            public void onMuteListAdded(String chatRoomId, List<String> mutes, long expireTime) {
                EMLog.d(TAG,"<---onMuteListAdded--->"+"roomId: "+ chatRoomId + " mutesList: " + mutes.toString() + " expireTime: " + expireTime);
                post(new Runnable() {
                    @Override
                    public void run() {
                    Map<String, Object> data = new HashMap<String, Object>();
                    data.put("roomId",chatRoomId);
                    data.put("mutes",mutes);
                    data.put("expireTime",String.valueOf(expireTime));
                    data.put("chatRoomChange","onMuteListAdded");
                    channel.invokeMethod(EMSDKMethod.chatRoomChange,data);
                    }});
            }

            @Override
            public void onMuteListRemoved(String chatRoomId, List<String> mutes) {
                EMLog.d(TAG,"<---onMuteListRemoved--->"+"roomId: "+ chatRoomId + " mutesList: " + mutes.toString() );
                post(new Runnable() {
                    @Override
                    public void run() {
                    Map<String, Object> data = new HashMap<String, Object>();
                    data.put("roomId",chatRoomId);
                    data.put("mutes",mutes);
                    data.put("chatRoomChange","onMuteListRemoved");
                    channel.invokeMethod(EMSDKMethod.chatRoomChange,data);
                }});
            }

            @Override
            public void onAdminAdded(String chatRoomId, String admin) {
                EMLog.d(TAG,"<---onAdminAdded--->"+"roomId: "+ chatRoomId + " admin: " + admin );
                post(new Runnable() {
                    @Override
                    public void run() {
                    Map<String, Object> data = new HashMap<String, Object>();
                    data.put("roomId",chatRoomId);
                    data.put("admin",admin);
                    data.put("chatRoomChange","onAdminAdded");
                    channel.invokeMethod(EMSDKMethod.chatRoomChange,data);
                    }});
            }

            @Override
            public void onAdminRemoved(String chatRoomId, String admin) {
                EMLog.d(TAG,"<---onAdminRemoved--->"+"roomId: "+ chatRoomId + " admin: " + admin );
                post(new Runnable() {
                    @Override
                    public void run() {
                    Map<String, Object> data = new HashMap<String, Object>();
                    data.put("roomId",chatRoomId);
                    data.put("admin",admin);
                    data.put("chatRoomChange","onAdminRemoved");
                    channel.invokeMethod(EMSDKMethod.chatRoomChange,data);
                }});
            }

            @Override
            public void onOwnerChanged(String chatRoomId, String newOwner, String oldOwner) {
                EMLog.d(TAG,"<---onOwnerChanged--->"+"roomId: "+ chatRoomId + " oldOwner: " + oldOwner );
                post(new Runnable() {
                    @Override
                    public void run() {
                    Map<String, Object> data = new HashMap<String, Object>();
                    data.put("roomId",chatRoomId);
                    data.put("newOwner",newOwner);
                    data.put("oldOwner",oldOwner);
                    data.put("chatRoomChange","onOwnerChanged");
                    channel.invokeMethod(EMSDKMethod.chatRoomChange,data);
                    }});
            }

            @Override
            public void onAnnouncementChanged(String chatRoomId, String announcement) {
                EMLog.d(TAG,"<---onAnnouncementChanged--->"+"roomId: "+ chatRoomId + " announcement: " + announcement );
                post(new Runnable() {
                    @Override
                    public void run() {
                    Map<String, Object> data = new HashMap<String, Object>();
                    data.put("roomId",chatRoomId);
                    data.put("announcement",announcement);
                    data.put("chatRoomChange","onAnnouncementChanged");
                    channel.invokeMethod(EMSDKMethod.chatRoomChange,data);
                }});
            }
        });
    }

    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        if(emChatRoomManager == null) {
            emChatRoomManager = EMClient.getInstance().chatroomManager();
            EMLog.d("ChatRoomChange","注册ChatRoomChange监听");
            registerChatRoomChangeListener();
        }
        if (EMSDKMethod.joinChatRoom.equals(methodCall.method)) {
            joinChatRoom(methodCall.arguments,result);
        }else if(EMSDKMethod.leaveChatRoom.equals(methodCall.method)){
            leaveChatRoom(methodCall.arguments,result);
        }else if(EMSDKMethod.fetchPublicChatRoomsFromServer.equals(methodCall.method)){
            fetchPublicChatRoomsFromServer(methodCall.arguments,result);
        }else if(EMSDKMethod.fetchChatRoomFromServer.equals(methodCall.method)){
            fetchChatRoomFromServer(methodCall.arguments,result);
        }else if(EMSDKMethod.getChatRoom.equals(methodCall.method)){
            getChatRoom(methodCall.arguments,result);
        }else if(EMSDKMethod.getAllChatRooms.equals(methodCall.method)){
            getAllChatRooms(methodCall.arguments,result);
        }else if(EMSDKMethod.createChatRoom.equals(methodCall.method)){
            createChatRoom(methodCall.arguments,result);
        }else if(EMSDKMethod.destroyChatRoom.equals(methodCall.method)){
            destroyChatRoom(methodCall.arguments,result);
        }else if(EMSDKMethod.changeChatRoomSubject.equals(methodCall.method)){
            changeChatRoomSubject(methodCall.arguments,result);
        }else if(EMSDKMethod.changeChatRoomDescription.equals(methodCall.method)){
            changeChatRoomDescription(methodCall.arguments,result);
        }else if(EMSDKMethod.fetchChatRoomMembers.equals(methodCall.method)){
            fetchChatRoomMembers(methodCall.arguments,result);
        }else if(EMSDKMethod.muteChatRoomMembers.equals(methodCall.method)){
            muteChatRoomMembers(methodCall.arguments,result);
        }else if(EMSDKMethod.unMuteChatRoomMembers.equals(methodCall.method)){
            unMuteChatRoomMembers(methodCall.arguments,result);
        }else if(EMSDKMethod.changeChatRoomOwner.equals(methodCall.method)){
            changeOwner(methodCall.arguments,result);
        }else if(EMSDKMethod.addChatRoomAdmin.equals(methodCall.method)){
            addChatRoomAdmin(methodCall.arguments,result);
        }else if(EMSDKMethod.removeChatRoomAdmin.equals(methodCall.method)){
            removeChatRoomAdmin(methodCall.arguments,result);
        }else if(EMSDKMethod.fetchChatRoomMuteList.equals(methodCall.method)){
            fetchChatRoomMuteList(methodCall.arguments,result);
        }else if(EMSDKMethod.removeChatRoomMembers.equals(methodCall.method)){
            removeChatRoomMembers(methodCall.arguments,result);
        }else if(EMSDKMethod.blockChatRoomMembers.equals(methodCall.method)){
            blockChatRoomMembers(methodCall.arguments,result);
        }else if(EMSDKMethod.unBlockChatRoomMembers.equals(methodCall.method)){
            unBlockChatRoomMembers(methodCall.arguments,result);
        }else if(EMSDKMethod.fetchChatRoomBlackList.equals(methodCall.method)){
            fetchChatRoomBlackList(methodCall.arguments,result);
        }else if(EMSDKMethod.updateChatRoomAnnouncement.equals(methodCall.method)){
            updateChatRoomAnnouncement(methodCall.arguments,result);
        }else if(EMSDKMethod.fetchChatRoomAnnouncement.equals(methodCall.method)){
            fetchChatRoomAnnouncement(methodCall.arguments,result);
        }
    }
    private void joinChatRoom(Object args, MethodChannel.Result result){
        try {
            JSONObject jsonObject = (JSONObject) args;
            String chatRoomId = jsonObject.getString("roomId");
            emChatRoomManager.joinChatRoom(chatRoomId,new EMValueWrapperCallBack<EMChatRoom>(result));
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
            post(new Runnable() {
                @Override
                public void run() {
                    result.success(data);
                }});
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void fetchPublicChatRoomsFromServer(Object args, MethodChannel.Result result){
        try {
            JSONObject jsonObject = (JSONObject) args;
            int pageNum = jsonObject.getInt("pageNum");
            int pageSize = jsonObject.getInt("pageSize");
            emChatRoomManager.asyncFetchPublicChatRoomsFromServer(pageNum,pageSize,new EMValueWrapperCallBack<EMPageResult<EMChatRoom>>(result));
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void fetchChatRoomFromServer(Object args, MethodChannel.Result result){
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
            data.put("value", EMHelper.convertEMChatRoomToStringMap(chatRoom));
            post(new Runnable() {
                @Override
                public void run() {
                    result.success(data);
                }});
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void getAllChatRooms(Object args, MethodChannel.Result result){
        List<EMChatRoom> list = emChatRoomManager.getAllChatRooms();
        List<Map<String ,Object>> roomlist = new ArrayList<>();
        for (EMChatRoom emChatRoom : list) {
            roomlist.add(EMHelper.convertEMChatRoomToStringMap(emChatRoom));
        }
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.TRUE);
        data.put("value", roomlist);
        post(new Runnable() {
            @Override
            public void run() {
                result.success(data);
            }});
    }

    private void createChatRoom(Object args, MethodChannel.Result result){
        try {
            JSONObject jsonObject = (JSONObject) args;
            String subject = jsonObject.getString("subject");
            String description = jsonObject.getString("description");
            String welcomeMessage = jsonObject.getString("welcomeMessage");
            int maxUserCount = jsonObject.getInt("maxUserCount");
            JSONArray members = jsonObject.getJSONArray("members");
            List<String> membersList = new ArrayList<>();
            for (int i = 0; i < members.length(); i++) {
                membersList.add((String) members.get(i));
            }
            emChatRoomManager.asyncCreateChatRoom(subject,description,welcomeMessage,maxUserCount,membersList,new EMValueWrapperCallBack<EMChatRoom>(result));
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void destroyChatRoom(Object args, MethodChannel.Result result){
        try {
            JSONObject jsonObject = (JSONObject) args;
            String chatRoomId = jsonObject.getString("roomId");
            emChatRoomManager.asyncDestroyChatRoom(chatRoomId,new EMWrapperCallBack(result));
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void changeChatRoomSubject(Object args, MethodChannel.Result result){
        try {
            JSONObject jsonObject = (JSONObject) args;
            String chatRoomId = jsonObject.getString("roomId");
            String newSubject = jsonObject.getString("newSubject");
            emChatRoomManager.asyncChangeChatRoomSubject(chatRoomId,newSubject,new EMValueWrapperCallBack<EMChatRoom>(result));
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void changeChatRoomDescription(Object args, MethodChannel.Result result){
        try {
            JSONObject jsonObject = (JSONObject) args;
            String chatRoomId = jsonObject.getString("roomId");
            String newDescription = jsonObject.getString("newDescription");
            emChatRoomManager.asyncChangeChatroomDescription(chatRoomId,newDescription,new EMValueWrapperCallBack<EMChatRoom>(result));
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void fetchChatRoomMembers(Object args, MethodChannel.Result result){
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

    private void muteChatRoomMembers(Object args, MethodChannel.Result result){
        try {
            JSONObject jsonObject = (JSONObject) args;
            String chatRoomId = jsonObject.getString("roomId");
            long duration = Long.parseLong(jsonObject.getString("duration"));
            JSONArray muteMembers = jsonObject.getJSONArray("muteMembers");
            List<String> muteMembersList = new ArrayList<>();
            for (int i = 0; i < muteMembers.length(); i++) {
                muteMembersList.add((String) muteMembers.get(i));
            }
            emChatRoomManager.asyncMuteChatRoomMembers(chatRoomId,muteMembersList,duration,new EMValueWrapperCallBack<EMChatRoom>(result));
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void unMuteChatRoomMembers(Object args, MethodChannel.Result result){
        try {
            JSONObject jsonObject = (JSONObject) args;
            String chatRoomId = jsonObject.getString("roomId");
            JSONArray muteMembers = jsonObject.getJSONArray("muteMembers");
            List<String> unMuteMembersList = new ArrayList<>();
            for (int i = 0; i < muteMembers.length(); i++) {
                unMuteMembersList.add((String) muteMembers.get(i));
            }
            emChatRoomManager.asyncUnMuteChatRoomMembers(chatRoomId,unMuteMembersList,new EMValueWrapperCallBack<EMChatRoom>(result));
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void changeOwner(Object args, MethodChannel.Result result){
        try {
            JSONObject jsonObject = (JSONObject) args;
            String chatRoomId = jsonObject.getString("roomId");
            String newOwner = jsonObject.getString("newOwner");
            emChatRoomManager.asyncChangeOwner(chatRoomId,newOwner,new EMValueWrapperCallBack<EMChatRoom>(result));
        } catch (JSONException | HyphenateException e) {
            e.printStackTrace();
        }
    }

    private void addChatRoomAdmin(Object args, MethodChannel.Result result){
        try {
            JSONObject jsonObject = (JSONObject) args;
            String chatRoomID = jsonObject.getString("roomId");
            String admin = jsonObject.getString("admin");
            emChatRoomManager.asyncAddChatRoomAdmin(chatRoomID,admin,new EMValueWrapperCallBack<EMChatRoom>(result));
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void removeChatRoomAdmin(Object args, MethodChannel.Result result){
        try {
            JSONObject jsonObject = (JSONObject) args;
            String chatRoomId = jsonObject.getString("roomId");
            String admin = jsonObject.getString("admin");
            emChatRoomManager.asyncRemoveChatRoomAdmin(chatRoomId,admin,new EMValueWrapperCallBack<EMChatRoom>(result));
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void fetchChatRoomMuteList(Object args, MethodChannel.Result result){
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
    private void removeChatRoomMembers(Object args, MethodChannel.Result result){
        try {
            JSONObject jsonObject = (JSONObject) args;
            String chatRoomId = jsonObject.getString("roomId");
            JSONArray members = jsonObject.getJSONArray("members");
            List<String> membersList = new ArrayList<>();
            for (int i = 0; i < members.length(); i++) {
                membersList.add((String) members.get(i));
            }
            emChatRoomManager.asyncRemoveChatRoomMembers(chatRoomId,membersList,new EMValueWrapperCallBack<EMChatRoom>(result));
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }
    private void blockChatRoomMembers(Object args, MethodChannel.Result result){
        try {
            JSONObject jsonObject = (JSONObject) args;
            String chatRoomId = jsonObject.getString("roomId");
            JSONArray blockMembers = jsonObject.getJSONArray("members");
            List<String> blockMembersList = new ArrayList<>();
            for (int i = 0; i < blockMembers.length(); i++) {
                blockMembersList.add((String) blockMembers.get(i));
            }
            emChatRoomManager.asyncBlockChatroomMembers(chatRoomId,blockMembersList,new EMValueWrapperCallBack<EMChatRoom>(result));
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }
    private void unBlockChatRoomMembers(Object args, MethodChannel.Result result){
        try {
            JSONObject jsonObject = (JSONObject) args;
            String chatRoomId = jsonObject.getString("roomId");
            JSONArray unBlockMembers = jsonObject.getJSONArray("members");
            List<String> unBlockMembersList = new ArrayList<>();
            for (int i = 0; i < unBlockMembers.length(); i++) {
                unBlockMembersList.add((String) unBlockMembers.get(i));
            }
            emChatRoomManager.asyncUnBlockChatRoomMembers(chatRoomId,unBlockMembersList,new EMValueWrapperCallBack<EMChatRoom>(result));
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }
    private void fetchChatRoomBlackList(Object args, MethodChannel.Result result){
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
    private void updateChatRoomAnnouncement(Object args, MethodChannel.Result result){
        try {
            JSONObject jsonObject = (JSONObject) args;
            String chatRoomId = jsonObject.getString("roomId");
            String announcement = jsonObject.getString("announcement");
            emChatRoomManager.asyncUpdateChatRoomAnnouncement(chatRoomId,announcement,new EMWrapperCallBack(result));
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }
    private void fetchChatRoomAnnouncement(Object args, MethodChannel.Result result){
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
        post(new Runnable() {
            @Override
            public void run() {
                result.success(data);
            }});
    }

    public void onError(MethodChannel.Result result, HyphenateException e) {
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.FALSE);
        data.put("code", e.getErrorCode());
        data.put("desc", e.getDescription());
        post(new Runnable() {
            @Override
            public void run() {
                result.success(data);
            }});
    }
}
