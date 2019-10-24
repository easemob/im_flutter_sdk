package com.easemob.im_flutter_sdk;


import android.support.annotation.NonNull;

import com.hyphenate.chat.EMBase;
import com.hyphenate.chat.adapter.EMAChatRoom;
import com.hyphenate.exceptions.HyphenateException;

import java.util.List;
import java.util.Map;
import java.util.function.Consumer;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class EMChatRoomWrapper extends EMBase<EMAChatRoom> implements MethodChannel.MethodCallHandler {


    @Override
    public void onMethodCall(@NonNull MethodCall methodCall, @NonNull MethodChannel.Result result) {
        if (EMSDKMethod.getId.equals(methodCall.method)) {
            getId();
        }else if(EMSDKMethod.getName.equals(methodCall.method)){
            getName();
        }else if(EMSDKMethod.getChatRoomDescription.equals(methodCall.method)){
            getDescription();
        }else if(EMSDKMethod.getChatRoomOwner.equals(methodCall.method)){
            getOwner();
        }else if(EMSDKMethod.getChatRoomAdminList.equals(methodCall.method)){
            getAdminList();
        }else if(EMSDKMethod.getChatRoomMemberCount.equals(methodCall.method)){
            getMemberCount();
        }else if(EMSDKMethod.getMaxUsers.equals(methodCall.method)){
            getMaxUsers();
        }else if(EMSDKMethod.getMemberList.equals(methodCall.method)){
            getMemberList();
        }else if(EMSDKMethod.getChatRoomBlackList.equals(methodCall.method)){
            getBlackList();
        }else if(EMSDKMethod.getChatRoomMuteList.equals(methodCall.method)){
            getMuteList();
        }else if(EMSDKMethod.getChatRoomAnnouncement.equals(methodCall.method)){
            getAnnouncement();
        }
    }


    public EMChatRoomWrapper(){
        emaObject = new EMAChatRoom();
    }

    public EMChatRoomWrapper(EMAChatRoom room) {
        emaObject = new EMAChatRoom(room);
    }

    public EMChatRoomWrapper(String roomId){
        emaObject = new EMAChatRoom(roomId);
    }

    public EMChatRoomWrapper(String roomId, String roomName){
        emaObject = new EMAChatRoom(roomId);
    }

    public String getId() {
        return emaObject.getId();
    }

    public String getName() {
        return emaObject.getName();
    }

    public String getDescription() {
        return emaObject.getDescription();
    }

    public String getOwner() {
        return emaObject.getOwner();
    }

    public List<String> getAdminList() { return emaObject.getAdministratorList();}

    public int getMemberCount()
    {
        return emaObject.getAffiliationsCount();
    }

    public int getMaxUsers() {
        return emaObject.getMaxUserCount();
    }

    public List<String> getMemberList(){
        return emaObject.getMemberList();
    }

    public List<String> getBlackList() { return emaObject.getBlockList(); }

    public Map<String, Long> getMuteList() { return emaObject.getMuteList(); }

    public String getAnnouncement() {
        return emaObject.getAnnouncement();
    }


}
