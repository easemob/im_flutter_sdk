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

public class EMChatRoomWrapper extends EMBase<EMAChatRoom> implements MethodChannel.MethodCallHandler, EMWrapper {


    @Override
    public void onMethodCall(@NonNull MethodCall methodCall, @NonNull MethodChannel.Result result) {
        if (EMSDKMethod.getId.equals(methodCall.method)) {
            getId();
        }else if(EMSDKMethod.getName.equals(methodCall.method)){
            getName();
        }else if(EMSDKMethod.getDescription.equals(methodCall.method)){
            getDescription();
        }else if(EMSDKMethod.getOwner.equals(methodCall.method)){
            getOwner();
        }else if(EMSDKMethod.getAdminList.equals(methodCall.method)){
            getAdminList();
        }else if(EMSDKMethod.getMemberCount.equals(methodCall.method)){
            getMemberCount();
        }else if(EMSDKMethod.getMaxUsers.equals(methodCall.method)){
            getMaxUsers();
        }else if(EMSDKMethod.getMemberList.equals(methodCall.method)){
            getMemberList();
        }else if(EMSDKMethod.getBlackList.equals(methodCall.method)){
            getBlackList();
        }else if(EMSDKMethod.getMuteList.equals(methodCall.method)){
            getMuteList();
        }else if(EMSDKMethod.getAnnouncement.equals(methodCall.method)){
            getAnnouncement();
        }
    }

    @Override
    public void post(Consumer<Void> func) {

    }

    @Override
    public void onSuccess(MethodChannel.Result result) {

    }

    @Override
    public void onError(MethodChannel.Result result, HyphenateException e) {

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


    enum EMChatRoomStyle{
        /**
         *\~chinese
         * 私有群组，创建完成后，只允许Owner邀请用户加入
         *
         * \~english
         * Private groups, after created, only allowing owner invite users to join
         */
        EMChatRoomStylePrivateOnlyOwnerInvite,

        /**
         * \~chinese
         * 私有群组，创建完成后，只允许Owner和群成员邀请用户加入
         *
         * \~english
         * Private groups, after created, only allowing owner and members invite users to join
         */
        EMChatRoomStylePrivateMemberCanInvite,

        /**
         * \~chinese
         * 公开群组，创建完成后，只允许Owner邀请用户加入; 非群成员用户需发送入群申请，Owner同意后才能入组
         *
         * *\~english
         * Public groups, after created, only allowing owner invite users to join; Non-group members into the group must send an application to the owner after the Owner agree
         */
        EMChatRoomStylePublicJoinNeedApproval,

        /**
         * \~chinese
         * 公开群组，创建完成后，允许非群组成员加入，不需要Owner同意
         *
         * \~english Public groups, after created, to allow non-members to join the group, does not require owner agrees
         */
        EMChatRoomStylePublicOpenJoin
    }
}
