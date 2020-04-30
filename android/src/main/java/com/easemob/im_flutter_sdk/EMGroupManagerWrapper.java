package com.easemob.im_flutter_sdk;


import com.hyphenate.EMGroupChangeListener;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMCursorResult;
import com.hyphenate.chat.EMGroup;
import com.hyphenate.chat.EMGroupInfo;
import com.hyphenate.chat.EMGroupManager;
import com.hyphenate.chat.EMGroupOptions;
import com.hyphenate.chat.EMMucSharedFile;
import com.hyphenate.exceptions.HyphenateException;
import com.hyphenate.util.EMLog;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;

public class EMGroupManagerWrapper implements MethodCallHandler, EMWrapper {

    // delegates all methods call to this manager
    private EMGroupManager manager;
    // method channel for event broadcast back to flutter
    private MethodChannel channel;

    EMGroupManagerWrapper(MethodChannel channel) {
        this.channel = channel;
    }

    public void init(){

        EMLog.e("_emGroupManagerWrapper", "addGroupChangeListener");
        //setup group listener
        manager.addGroupChangeListener(new EMGroupChangeListener() {

            @Override
            public void onWhiteListAdded(String groupId, List<String> whitelist) {

            }

            @Override
            public void onWhiteListRemoved(String groupId, List<String> whitelist) {

            }

            @Override
            public void onAllMemberMuteStateChanged(String groupId, boolean isMuted) {

            }

            @Override
            public void onInvitationReceived(String groupId, String groupName, String inviter, String reason) {
                EMLog.e("_emGroupManagerWrapper", "onInvitationReceived");
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("type", "onInvitationReceived");
                data.put("groupId", groupId);
                data.put("groupName", groupName);
                data.put("inviter", inviter);
                data.put("reason", reason);
                post(new Runnable() {
                    @Override
                    public void run() {
                        channel.invokeMethod(EMSDKMethod.onGroupChanged,data);
                    }});
            }

            @Override
            public void onRequestToJoinReceived(String groupId, String groupName, String applicant, String reason) {
                EMLog.e("_emGroupManagerWrapper", "onRequestToJoinReceived");
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("type", "onRequestToJoinReceived");
                data.put("groupId", groupId);
                data.put("groupName", groupName);
                data.put("applicant", applicant);
                data.put("reason", reason);
                post(new Runnable() {
                    @Override
                    public void run() {
                    channel.invokeMethod(EMSDKMethod.onGroupChanged,data);
                    }});
            }

            @Override
            public void onRequestToJoinAccepted(String groupId, String groupName, String accepter) {
                EMLog.e("_emGroupManagerWrapper", "onRequestToJoinAccepted");
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("type", "onRequestToJoinAccepted");
                data.put("groupId", groupId);
                data.put("groupName", groupName);
                data.put("accepter", accepter);
                post(new Runnable() {
                    @Override
                    public void run() {
                    channel.invokeMethod(EMSDKMethod.onGroupChanged,data);
                }});
            }

            @Override
            public void onRequestToJoinDeclined(String groupId, String groupName, String decliner, String reason) {
                EMLog.e("_emGroupManagerWrapper", "onRequestToJoinDeclined");
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("type", "onRequestToJoinDeclined");
                data.put("groupId", groupId);
                data.put("groupName", groupName);
                data.put("decliner", decliner);
                data.put("reason", reason);
                post(new Runnable() {
                    @Override
                    public void run() {
                    channel.invokeMethod(EMSDKMethod.onGroupChanged,data);
                    }});
            }

            @Override
            public void onInvitationAccepted(String groupId, String invitee, String reason) {
                EMLog.e("_emGroupManagerWrapper", "onInvitationAccepted");
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("type", "onInvitationAccepted");
                data.put("groupId", groupId);
                data.put("invitee", invitee);
                data.put("reason", reason);
                post(new Runnable() {
                    @Override
                    public void run() {
                    channel.invokeMethod(EMSDKMethod.onGroupChanged,data);
                }});
            }

            @Override
            public void onInvitationDeclined(String groupId, String invitee, String reason) {
                EMLog.e("_emGroupManagerWrapper", "onInvitationDeclined");
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("type", "onInvitationDeclined");
                data.put("groupId", groupId);
                data.put("invitee", invitee);
                data.put("reason", reason);
                post(new Runnable() {
                    @Override
                    public void run() {
                    channel.invokeMethod(EMSDKMethod.onGroupChanged,data);
                    }});
            }

            @Override
            public void onUserRemoved(String groupId, String groupName) {
                EMLog.e("_emGroupManagerWrapper", "onUserRemoved");
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("type", "onUserRemoved");
                data.put("groupId", groupId);
                data.put("groupName", groupName);
                post(new Runnable() {
                    @Override
                    public void run() {
                    channel.invokeMethod(EMSDKMethod.onGroupChanged,data);
                }});
            }

            @Override
            public void onGroupDestroyed(String groupId, String groupName) {
                EMLog.e("_emGroupManagerWrapper", "onGroupDestroyed");
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("type", "onGroupDestroyed");
                data.put("groupId", groupId);
                data.put("groupName", groupName);
                post(new Runnable() {
                    @Override
                    public void run() {
                    channel.invokeMethod(EMSDKMethod.onGroupChanged,data);
                    }});
            }

            @Override
            public void onAutoAcceptInvitationFromGroup(String groupId, String inviter, String inviteMessage) {
                EMLog.e("_emGroupManagerWrapper", "onAutoAcceptInvitationFromGroup");
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("type", "onAutoAcceptInvitationFromGroup");
                data.put("groupId", groupId);
                data.put("inviter", inviter);
                data.put("inviteMessage", inviteMessage);
                post(new Runnable() {
                    @Override
                    public void run() {
                    channel.invokeMethod(EMSDKMethod.onGroupChanged,data);
                }});
            }

            @Override
            public void onMuteListAdded(String groupId, List<String> mutes, long muteExpire) {
                EMLog.e("_emGroupManagerWrapper", "onMuteListAdded");
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("type", "onMuteListAdded");
                data.put("groupId", groupId);
                data.put("mutes", mutes);
                data.put("muteExpire", muteExpire);
                post(new Runnable() {
                    @Override
                    public void run() {
                    channel.invokeMethod(EMSDKMethod.onGroupChanged,data);
                    }});
            }

            @Override
            public void onMuteListRemoved(String groupId, List<String> mutes) {
                EMLog.e("_emGroupManagerWrapper", "onMuteListRemoved");
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("type", "onMuteListRemoved");
                data.put("groupId", groupId);
                data.put("mutes", mutes);
                post(new Runnable() {
                    @Override
                    public void run() {
                    channel.invokeMethod(EMSDKMethod.onGroupChanged,data);
                }});
            }

            @Override
            public void onAdminAdded(String groupId, String administrator) {
                EMLog.e("_emGroupManagerWrapper", "onAdminAdded");
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("type", "onAdminAdded");
                data.put("groupId", groupId);
                data.put("administrator", administrator);
                post(new Runnable() {
                    @Override
                    public void run() {
                    channel.invokeMethod(EMSDKMethod.onGroupChanged,data);
                    }});
            }

            @Override
            public void onAdminRemoved(String groupId, String administrator) {
                EMLog.e("_emGroupManagerWrapper", "onAdminRemoved");
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("type", "onAdminRemoved");
                data.put("groupId", groupId);
                data.put("administrator", administrator);
                post(new Runnable() {
                    @Override
                    public void run() {
                    channel.invokeMethod(EMSDKMethod.onGroupChanged,data);
                }});
            }

            @Override
            public void onOwnerChanged(String groupId, String newOwner, String oldOwner) {
                EMLog.e("_emGroupManagerWrapper", "onOwnerChanged");
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("type", "onOwnerChanged");
                data.put("groupId", groupId);
                data.put("newOwner", newOwner);
                data.put("oldOwner", oldOwner);
                post(new Runnable() {
                    @Override
                    public void run() {
                    channel.invokeMethod(EMSDKMethod.onGroupChanged,data);
                    }});
            }

            @Override
            public void onMemberJoined(String groupId, String member) {
                EMLog.e("_emGroupManagerWrapper", "onMemberJoined");
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("type", "onMemberJoined");
                data.put("groupId", groupId);
                data.put("member", member);
                post(new Runnable() {
                    @Override
                    public void run() {
                    channel.invokeMethod(EMSDKMethod.onGroupChanged,data);
                }});
            }

            @Override
            public void onMemberExited(String groupId, String member) {
                EMLog.e("_emGroupManagerWrapper", "onMemberExited");
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("type", "onMemberExited");
                data.put("groupId", groupId);
                data.put("member", member);
                post(new Runnable() {
                    @Override
                    public void run() {
                    channel.invokeMethod(EMSDKMethod.onGroupChanged,data);
                    }});
            }

            @Override
            public void onAnnouncementChanged(String groupId, String announcement) {
                EMLog.e("_emGroupManagerWrapper", "onAnnouncementChanged");
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("type", "onAnnouncementChanged");
                data.put("groupId", groupId);
                data.put("announcement", announcement);
                post(new Runnable() {
                    @Override
                    public void run() {
                    channel.invokeMethod(EMSDKMethod.onGroupChanged,data);
                }});
            }

            @Override
            public void onSharedFileAdded(String groupId, EMMucSharedFile sharedFile) {
                EMLog.e("_emGroupManagerWrapper", "onSharedFileAdded");
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("type", "onSharedFileAdded");
                data.put("groupId", groupId);
                data.put("sharedFile", EMHelper.convertEMMucSharedFileToStringMap(sharedFile));
                post(new Runnable() {
                    @Override
                    public void run() {
                    channel.invokeMethod(EMSDKMethod.onGroupChanged,data);
                    }});
            }

            @Override
            public void onSharedFileDeleted(String groupId, String fileId) {
                EMLog.e("_emGroupManagerWrapper", "onSharedFileDeleted");
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("type", "onSharedFileDeleted");
                data.put("groupId", groupId);
                data.put("fileId", fileId);
                post(new Runnable() {
                    @Override
                    public void run() {
                    channel.invokeMethod(EMSDKMethod.onGroupChanged,data);
                }});
            }
        });

    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        if(manager == null) {
            manager = EMClient.getInstance().groupManager();
            init();
        }
        EMLog.e("_emGroupManagerWrapper", "onMethodCall:" + call.method);

        if(EMSDKMethod.getGroup.equals(call.method)){
            getGroup(call.arguments, result);
        } else if (EMSDKMethod.getAllGroups.equals(call.method)){
            getAllGroups(call.arguments, result);
        }else if (EMSDKMethod.createGroup.equals(call.method)){
            createGroup(call.arguments, result);
        }else if (EMSDKMethod.loadAllGroups.equals(call.method)){
            loadAllGroups(call.arguments, result);
        }else if (EMSDKMethod.destroyGroup.equals(call.method)){
            destroyGroup(call.arguments, result);
        }else if (EMSDKMethod.addUsersToGroup.equals(call.method)){
            addUsersToGroup(call.arguments, result);
        }else if (EMSDKMethod.removeUserFromGroup.equals(call.method)){
            removeUserFromGroup(call.arguments, result);
        }else if (EMSDKMethod.leaveGroup.equals(call.method)){
            leaveGroup(call.arguments, result);
        }else if (EMSDKMethod.getGroupFromServer.equals(call.method)){
            getGroupFromServer(call.arguments, result);
        }else if (EMSDKMethod.getJoinedGroupsFromServer.equals(call.method)){
            getJoinedGroupsFromServer(call.arguments, result);
        }else if (EMSDKMethod.getPublicGroupsFromServer.equals(call.method)){
            getPublicGroupsFromServer(call.arguments, result);
        }else if (EMSDKMethod.joinGroup.equals(call.method)){
            joinGroup(call.arguments, result);
        }else if (EMSDKMethod.changeGroupName.equals(call.method)){
            changeGroupName(call.arguments, result);
        }else if (EMSDKMethod.changeGroupDescription.equals(call.method)){
            changeGroupDescription(call.arguments, result);
        }else if (EMSDKMethod.acceptGroupInvitation.equals(call.method)){
            acceptInvitation(call.arguments, result);
        }else if (EMSDKMethod.declineGroupInvitation.equals(call.method)){
            declineInvitation(call.arguments, result);
        }else if (EMSDKMethod.acceptApplication.equals(call.method)){
            acceptApplication(call.arguments, result);
        }else if (EMSDKMethod.declineApplication.equals(call.method)){
            declineApplication(call.arguments, result);
        }else if (EMSDKMethod.inviteUser.equals(call.method)){
            inviteUser(call.arguments, result);
        }else if (EMSDKMethod.applyJoinToGroup.equals(call.method)){
            applyJoinToGroup(call.arguments, result);
        }else if (EMSDKMethod.blockGroupMessage.equals(call.method)){
            blockGroupMessage(call.arguments, result);
        }else if (EMSDKMethod.unblockGroupMessage.equals(call.method)){
            unblockGroupMessage(call.arguments, result);
        }else if (EMSDKMethod.blockUser.equals(call.method)){
            blockUser(call.arguments, result);
        }else if (EMSDKMethod.unblockUser.equals(call.method)){
            unblockUser(call.arguments, result);
        }else if (EMSDKMethod.fetchGroupMembers.equals(call.method)){
            fetchGroupMembers(call.arguments, result);
        }else if (EMSDKMethod.changeOwner.equals(call.method)){
            changeOwner(call.arguments, result);
        }else if (EMSDKMethod.addGroupAdmin.equals(call.method)){
            addGroupAdmin(call.arguments, result);
        }else if (EMSDKMethod.removeGroupAdmin.equals(call.method)){
            removeGroupAdmin(call.arguments, result);
        }else if (EMSDKMethod.muteGroupMembers.equals(call.method)){
            muteGroupMembers(call.arguments, result);
        }else if (EMSDKMethod.unMuteGroupMembers.equals(call.method)){
            unMuteGroupMembers(call.arguments, result);
        }else if (EMSDKMethod.fetchGroupMuteList.equals(call.method)){
            fetchGroupMuteList(call.arguments, result);
        }else if (EMSDKMethod.fetchGroupBlackList.equals(call.method)){
            fetchGroupBlackList(call.arguments, result);
        }else if (EMSDKMethod.updateGroupAnnouncement.equals(call.method)){
            updateGroupAnnouncement(call.arguments, result);
        }else if (EMSDKMethod.fetchGroupAnnouncement.equals(call.method)){
            fetchGroupAnnouncement(call.arguments, result);
        }else if (EMSDKMethod.uploadGroupSharedFile.equals(call.method)){
            uploadGroupSharedFile(call.arguments, result);
        }else if (EMSDKMethod.fetchGroupSharedFileList.equals(call.method)){
            fetchGroupSharedFileList(call.arguments, result);
        }else if (EMSDKMethod.deleteGroupSharedFile.equals(call.method)){
            deleteGroupSharedFile(call.arguments, result);
        }else if (EMSDKMethod.downloadGroupSharedFile.equals(call.method)){
            downloadGroupSharedFile(call.arguments, result);
        }else if (EMSDKMethod.updateGroupExtension.equals(call.method)){
            updateGroupExtension(call.arguments, result);
        }
    }

    private void getGroup(Object args, MethodChannel.Result result){
        try {
            JSONObject argJson = (JSONObject) args;
            String groupId = argJson.getString("groupId");
            EMGroup group = manager.getGroup(groupId);
            Map<String, Object> data = new HashMap<String, Object>();
            data.put("success", Boolean.TRUE);
            data.put("value", EMHelper.convertEMGroupToStringMap(group));
            post(new Runnable() {
                @Override
                public void run() {
                    result.success(data);
                }});
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    private void getAllGroups(Object args, MethodChannel.Result result){
        List<EMGroup> groups = manager.getAllGroups();
        Map<String, Object> data = new HashMap<String, Object>();
        List<Map<String, Object>> list = new LinkedList<>();
        for(EMGroup group : groups){
            list.add(EMHelper.convertEMGroupToStringMap(group));
        }
        data.put("success", Boolean.TRUE);
        data.put("value", list);
        post(new Runnable() {
            @Override
            public void run() {
                result.success(data);
            }});
    }

    private void createGroup(Object args, MethodChannel.Result result){
        try {
            JSONObject argJson = (JSONObject) args;
            String groupName = argJson.getString("groupName");
            String desc = argJson.getString("desc");
            JSONArray json_members = argJson.getJSONArray("members");
            String[] members = new String[json_members.length()];
            for(int i = 0; i < json_members.length(); i ++){
                members[i] = json_members.getString(i);
            }
            String reason = argJson.getString("reason");
            EMGroupOptions option = new EMGroupOptions();
            option.maxUsers = argJson.getInt("maxUsers");
            int style = argJson.getInt("groupStyle");
            switch (style){
                case 0:
                    option.style = EMGroupManager.EMGroupStyle.EMGroupStylePrivateOnlyOwnerInvite;
                    break;
                case 1:
                    option.style = EMGroupManager.EMGroupStyle.EMGroupStylePrivateMemberCanInvite;
                    break;
                case 2:
                    option.style = EMGroupManager.EMGroupStyle.EMGroupStylePublicJoinNeedApproval;
                    break;
                case 3:
                    option.style = EMGroupManager.EMGroupStyle.EMGroupStylePublicOpenJoin;
                    break;
            }
            manager.asyncCreateGroup(groupName, desc, members, reason, option, new EMValueWrapperCallBack<EMGroup>(result));
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    private void loadAllGroups(Object args, MethodChannel.Result result){
        manager.loadAllGroups();
    }


    private void destroyGroup(Object args, MethodChannel.Result result){
        try {
            JSONObject argJson = (JSONObject) args;
            String groupId = argJson.getString("groupId");
            manager.asyncDestroyGroup(groupId, new EMWrapperCallBack(result));
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    private void addUsersToGroup(Object args, MethodChannel.Result result){
        try {
            JSONObject argJson = (JSONObject) args;
            String groupId = argJson.getString("groupId");
            JSONArray json_members = argJson.getJSONArray("members");
            String[] members = new String[json_members.length()];;
            for(int i = 0; i < json_members.length(); i ++){
                members[i] = json_members.getString(i);
            }
            manager.asyncAddUsersToGroup(groupId, members, new EMWrapperCallBack(result));
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    private void removeUserFromGroup(Object args, MethodChannel.Result result){
        try {
            JSONObject argJson = (JSONObject) args;
            String groupId = argJson.getString("groupId");
            String userName = argJson.getString("userName");
            manager.asyncRemoveUserFromGroup(groupId, userName, new EMWrapperCallBack(result));
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    private void leaveGroup(Object args, MethodChannel.Result result){
        try {
            JSONObject argJson = (JSONObject) args;
            String groupId = argJson.getString("groupId");
            manager.asyncLeaveGroup(groupId, new EMWrapperCallBack(result));
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    private void getGroupFromServer(Object args, MethodChannel.Result result){
        try {
            JSONObject argJson = (JSONObject) args;
            String groupId = argJson.getString("groupId");
            manager.asyncGetGroupFromServer(groupId, new EMValueWrapperCallBack<EMGroup>(result));
            if(EMClient.getInstance().pushManager().getPushConfigs() == null) {
                    new Thread(new Runnable() {
                        @Override
                        public void run() {
                            try {
                                EMClient.getInstance().pushManager().getPushConfigsFromServer();
                            }catch (HyphenateException e){
                                e.printStackTrace();
                            }
                        }
                    }).start();
            }
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    private void getJoinedGroupsFromServer(Object args, MethodChannel.Result result){
        manager.asyncGetJoinedGroupsFromServer(new EMValueWrapperCallBack<List<EMGroup>>(result));
    }

    private void getPublicGroupsFromServer(Object args, MethodChannel.Result result){
        try {
            JSONObject argJson = (JSONObject) args;
            int pageSize = argJson.getInt("pageSize");
            String cursor = argJson.getString("cursor");
            manager.asyncGetPublicGroupsFromServer(pageSize,cursor, new EMValueWrapperCallBack<EMCursorResult<EMGroupInfo>>(result));
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    private void joinGroup(Object args, MethodChannel.Result result){
        try {
            JSONObject argJson = (JSONObject) args;
            String groupId = argJson.getString("groupId");
            manager.asyncJoinGroup(groupId, new EMWrapperCallBack(result));
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    private void changeGroupName(Object args, MethodChannel.Result result){
        try {
            JSONObject argJson = (JSONObject) args;
            String groupId = argJson.getString("groupId");
            String groupName = argJson.getString("groupName");
            manager.asyncChangeGroupName(groupId, groupName, new EMWrapperCallBack(result));
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    private void changeGroupDescription(Object args, MethodChannel.Result result){
        try {
            JSONObject argJson = (JSONObject) args;
            String groupId = argJson.getString("groupId");
            String desc = argJson.getString("desc");
            manager.asyncChangeGroupDescription(groupId, desc, new EMWrapperCallBack(result));
        }catch (Exception e){
            e.printStackTrace();
        }
    }
    private void acceptInvitation(Object args, MethodChannel.Result result){
        try {
            JSONObject argJson = (JSONObject) args;
            String groupId = argJson.getString("groupId");
            String inviter = argJson.getString("inviter");
            manager.asyncAcceptInvitation(groupId, inviter, new EMValueWrapperCallBack<EMGroup>(result));
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    private void declineInvitation(Object args, MethodChannel.Result result){
        try {
            JSONObject argJson = (JSONObject) args;
            String groupId = argJson.getString("groupId");
            String inviter = argJson.getString("inviter");
            String reason = argJson.getString("reason");
            manager.asyncDeclineInvitation(groupId, inviter, reason, new EMWrapperCallBack(result));
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    private void acceptApplication(Object args, MethodChannel.Result result){
        try {
            JSONObject argJson = (JSONObject) args;
            String username = argJson.getString("userName");
            String groupId = argJson.getString("groupId");
            manager.asyncAcceptApplication(username, groupId, new EMWrapperCallBack(result));
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    private void declineApplication(Object args, MethodChannel.Result result){
        try {
            JSONObject argJson = (JSONObject) args;
            String username = argJson.getString("userName");
            String groupId = argJson.getString("groupId");
            String reason = argJson.getString("reason");
            manager.asyncDeclineApplication(username, groupId, reason, new EMWrapperCallBack(result));
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    private void inviteUser(Object args, MethodChannel.Result result){
        try {
            JSONObject argJson = (JSONObject) args;
            String groupId = argJson.getString("groupId");
            JSONArray json_members = argJson.getJSONArray("members");
            String[] members = new String[json_members.length()];
            for(int i = 0; i < json_members.length(); i ++){
                members[i] = json_members.getString(i);
            }
            String reason = argJson.getString("reason");
            manager.asyncInviteUser(groupId, members, reason, new EMWrapperCallBack(result));
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    private void applyJoinToGroup(Object args, MethodChannel.Result result){
        try {
            JSONObject argJson = (JSONObject) args;
            String groupId = argJson.getString("groupId");
            String reason = argJson.getString("reason");
            manager.asyncApplyJoinToGroup(groupId, reason, new EMWrapperCallBack(result));
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    private void blockGroupMessage(Object args, MethodChannel.Result result){
        try {
            JSONObject argJson = (JSONObject) args;
            String groupId = argJson.getString("groupId");
            manager.asyncBlockGroupMessage(groupId, new EMWrapperCallBack(result));
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    private void unblockGroupMessage(Object args, MethodChannel.Result result){
        try {
            JSONObject argJson = (JSONObject) args;
            String groupId = argJson.getString("groupId");
            manager.asyncUnblockGroupMessage(groupId, new EMWrapperCallBack(result));
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    private void blockUser(Object args, MethodChannel.Result result){
        try {
            JSONObject argJson = (JSONObject) args;
            String groupId = argJson.getString("groupId");
            String username = argJson.getString("userName");
            manager.asyncBlockUser(groupId, username, new EMWrapperCallBack(result));
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    private void unblockUser(Object args, MethodChannel.Result result){
        try {
            JSONObject argJson = (JSONObject) args;
            String groupId = argJson.getString("groupId");
            String username = argJson.getString("userName");
            manager.asyncUnblockUser(groupId, username, new EMWrapperCallBack(result));
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    private void fetchGroupMembers(Object args, MethodChannel.Result result){
        try {
            JSONObject argJson = (JSONObject) args;
            String groupId = argJson.getString("groupId");
            String cursor = argJson.getString("cursor");
            int pageSize = argJson.getInt("pageSize");
            manager.asyncFetchGroupMembers(groupId, cursor, pageSize, new EMValueWrapperCallBack<EMCursorResult<String>>(result));
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    private void changeOwner(Object args, MethodChannel.Result result){
        try {
            JSONObject argJson = (JSONObject) args;
            String groupId = argJson.getString("groupId");
            String newOwner = argJson.getString("newOwner");
            manager.asyncChangeOwner(groupId, newOwner, new EMValueWrapperCallBack<EMGroup>(result));
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    private void addGroupAdmin(Object args, MethodChannel.Result result){
        try {
            JSONObject argJson = (JSONObject) args;
            String groupId = argJson.getString("groupId");
            String admin = argJson.getString("admin");
            manager.asyncAddGroupAdmin(groupId, admin, new EMValueWrapperCallBack<EMGroup>(result));
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    private void removeGroupAdmin(Object args, MethodChannel.Result result){
        try {
            JSONObject argJson = (JSONObject) args;
            String groupId = argJson.getString("groupId");
            String admin = argJson.getString("admin");
            manager.asyncRemoveGroupAdmin(groupId, admin, new EMValueWrapperCallBack<EMGroup>(result));
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    private void muteGroupMembers(Object args, MethodChannel.Result result){
        try {
            JSONObject argJson = (JSONObject) args;
            String groupId = argJson.getString("groupId");
            JSONArray json_members = argJson.getJSONArray("members");
            List<String> members = new ArrayList<>();
            for(int i = 0; i < json_members.length(); i ++){
                members.add(json_members.getString(i));
            }
            String duration = argJson.getString("duration");
            manager.aysncMuteGroupMembers(groupId, members, Long.parseLong(duration), new EMValueWrapperCallBack<EMGroup>(result));
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    private void unMuteGroupMembers(Object args, MethodChannel.Result result){
        try {
            JSONObject argJson = (JSONObject) args;
            String groupId = argJson.getString("groupId");
            JSONArray json_members = argJson.getJSONArray("members");
            List<String> members = new ArrayList<>();
            for(int i = 0; i < json_members.length(); i ++){
                members.add(json_members.getString(i));
            }
            manager.asyncUnMuteGroupMembers(groupId, members, new EMValueWrapperCallBack<EMGroup>(result));
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    private void fetchGroupMuteList(Object args, MethodChannel.Result result){
        try {
            JSONObject argJson = (JSONObject) args;
            String groupId = argJson.getString("groupId");
            int pageNum = argJson.getInt("pageNum");
            int pageSize = argJson.getInt("pageSize");
            manager.asyncFetchGroupMuteList(groupId, pageNum, pageSize, new EMValueWrapperCallBack<Map<String, Long>>(result));
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    private void fetchGroupBlackList(Object args, MethodChannel.Result result){
        try {
            JSONObject argJson = (JSONObject) args;
            String groupId = argJson.getString("groupId");
            int pageNum = argJson.getInt("pageNum");
            int pageSize = argJson.getInt("pageSize");
            manager.asyncFetchGroupBlackList(groupId, pageNum, pageSize, new EMValueWrapperCallBack<List<String>>(result));
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    private void updateGroupAnnouncement(Object args, MethodChannel.Result result){
        try {
            JSONObject argJson = (JSONObject) args;
            String groupId = argJson.getString("groupId");
            String announcement = argJson.getString("announcement");
            manager.asyncUpdateGroupAnnouncement(groupId, announcement, new EMWrapperCallBack(result));
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    private void fetchGroupAnnouncement(Object args, MethodChannel.Result result){
        try {
            JSONObject argJson = (JSONObject) args;
            String groupId = argJson.getString("groupId");
            manager.asyncFetchGroupAnnouncement(groupId, new EMValueWrapperCallBack<String>(result));
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    private void uploadGroupSharedFile(Object args, MethodChannel.Result result){
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    JSONObject argJson = (JSONObject) args;
                    String groupId = argJson.getString("groupId");
                    String filePath = argJson.getString("filePath");
                    manager.uploadGroupSharedFile(groupId, filePath, new EMWrapperCallBack(result));
                }catch (Exception e){
                    e.printStackTrace();
                }
            }
        }).start();

    }

    private void fetchGroupSharedFileList(Object args, MethodChannel.Result result){
        try {
            JSONObject argJson = (JSONObject) args;
            String groupId = argJson.getString("groupId");
            int pageNum = argJson.getInt("pageNum");
            int pageSize = argJson.getInt("pageSize");
            manager.asyncFetchGroupSharedFileList(groupId, pageNum, pageSize, new EMValueWrapperCallBack<List<EMMucSharedFile>>(result));
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    private void deleteGroupSharedFile(Object args, MethodChannel.Result result){
        try {
            JSONObject argJson = (JSONObject) args;
            String groupId = argJson.getString("groupId");
            String fileId = argJson.getString("fileId");
            manager.asyncDeleteGroupSharedFile(groupId, fileId, new EMWrapperCallBack(result));
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    private void downloadGroupSharedFile(Object args, MethodChannel.Result result){
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    JSONObject argJson = (JSONObject) args;
                    String groupId = argJson.getString("groupId");
                    String fileId = argJson.getString("fileId");
                    String savePath = argJson.getString("savePath");
                    manager.downloadGroupSharedFile(groupId, fileId, savePath, new EMWrapperCallBack(result));
                }catch (Exception e){
                    e.printStackTrace();
                }
            }
        }).start();
    }

    private void updateGroupExtension(Object args, MethodChannel.Result result){
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    JSONObject argJson = (JSONObject) args;
                    String groupId = argJson.getString("groupId");
                    String extension = argJson.getString("extension");
                    EMGroup group = manager.updateGroupExtension(groupId, extension);
                    Map<String, Object> data = new HashMap<String, Object>();
                    data.put("success", Boolean.TRUE);
                    data.put("value", EMHelper.convertEMGroupToStringMap(group));
                    post(new Runnable() {
                        @Override
                        public void run() {
                            result.success(data);
                        }});
                }catch (Exception e){
                    e.printStackTrace();
                }
            }
        }).start();

    }


}


