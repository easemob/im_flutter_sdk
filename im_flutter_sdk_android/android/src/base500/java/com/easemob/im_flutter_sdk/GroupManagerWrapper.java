package com.easemob.im_flutter_sdk;

import com.hyphenate.EMGroupChangeListener;
import com.hyphenate.chat.EMClient;

import io.flutter.embedding.engine.plugins.FlutterPlugin;

import io.flutter.plugin.common.MethodChannel.Result;

import com.hyphenate.chat.EMCursorResult;
import com.hyphenate.chat.EMGroup;
import com.hyphenate.chat.EMGroupInfo;
import com.hyphenate.chat.EMGroupManager;
import com.hyphenate.chat.EMGroupMemberInfo;
import com.hyphenate.chat.EMGroupConfigs;
import com.hyphenate.chat.EMMucSharedFile;
import com.hyphenate.exceptions.HyphenateException;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.EnumSet;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;

public class GroupManagerWrapper extends Wrapper implements MethodCallHandler {

    private EMGroupChangeListener groupChangeListener;

    public ClientWrapper clientWrapper;

    GroupManagerWrapper(FlutterPlugin.FlutterPluginBinding flutterPluginBinding, String channelName) {
        super(flutterPluginBinding, channelName);
        registerEaseListener();
    }

    @Override
    protected boolean dispatchMethodCall(
            String method,
            JSONObject params,
            MethodChannel.Result result
    ) throws Exception {
        if (MethodKey.getGroupWithId.equals(method)) {
            getGroupWithId(params, method, result);
            return true;
        }
        else if (MethodKey.getJoinedGroups.equals(method)) {
            getJoinedGroups(params, method, result);
            return true;
        }
        else if (MethodKey.getJoinedGroupsFromServer.equals(method)) {
            getJoinedGroupsFromServer(params, method, result);
            return true;
        }
        else if (MethodKey.getPublicGroupsFromServer.equals(method)) {
            getPublicGroupsFromServer(params, method, result);
            return true;
        }
        else if (MethodKey.createGroup.equals(method)) {
            createGroup(params, method, result);
            return true;
        }
        else if (MethodKey.getGroupSpecificationFromServer.equals(method)) {
            getGroupSpecificationFromServer(params, method, result);
            return true;
        }
        else if (MethodKey.getGroupMemberListFromServer.equals(method)) {
            getGroupMemberListFromServer(params, method, result);
            return true;
        }
        else if (MethodKey.getGroupMuteListFromServer.equals(method)) {
            getGroupMuteListFromServer(params, method, result);
            return true;
        }
        else if (MethodKey.getGroupWhiteListFromServer.equals(method)) {
            getGroupWhiteListFromServer(params, method, result);
            return true;
        }
        else if (MethodKey.isMemberInWhiteListFromServer.equals(method)) {
            isMemberInWhiteListFromServer(params, method, result);
            return true;
        }
        else if (MethodKey.getGroupFileListFromServer.equals(method)) {
            getGroupFileListFromServer(params, method, result);
            return true;
        }
        else if (MethodKey.getGroupAnnouncementFromServer.equals(method)) {
            getGroupAnnouncementFromServer(params, method, result);
            return true;
        }
        else if (MethodKey.getGroupBlockListFromServer.equals(method)) {
            getGroupBlockListFromServer(params, method, result);
            return true;
        }
        else if (MethodKey.addMembers.equals(method)) {
            addMembers(params, method, result);
            return true;
        }
        else if (MethodKey.inviterUser.equals(method)) {
            inviterUser(params, method, result);
            return true;
        }
        else if (MethodKey.removeMembers.equals(method)) {
            removeMembers(params, method, result);
            return true;
        }
        else if (MethodKey.blockMembers.equals(method)) {
            blockMembers(params, method, result);
            return true;
        }
        else if (MethodKey.unblockMembers.equals(method)) {
            unblockMembers(params, method, result);
            return true;
        }
        else if (MethodKey.updateGroupSubject.equals(method)) {
            updateGroupSubject(params, method, result);
            return true;
        }
        else if (MethodKey.updateDescription.equals(method)) {
            updateDescription(params, method, result);
            return true;
        }
        else if (MethodKey.leaveGroup.equals(method)) {
            leaveGroup(params, method, result);
            return true;
        }
        else if (MethodKey.destroyGroup.equals(method)) {
            destroyGroup(params, method, result);
            return true;
        }
        else if (MethodKey.blockGroup.equals(method)) {
            blockGroup(params, method, result);
            return true;
        }
        else if (MethodKey.unblockGroup.equals(method)) {
            unblockGroup(params, method, result);
            return true;
        }
        else if (MethodKey.updateGroupOwner.equals(method)) {
            updateGroupOwner(params, method, result);
            return true;
        }
        else if (MethodKey.addAdmin.equals(method)) {
            addAdmin(params, method, result);
            return true;
        }
        else if (MethodKey.removeAdmin.equals(method)) {
            removeAdmin(params, method, result);
            return true;
        }
        else if (MethodKey.muteMembers.equals(method)) {
            muteMembers(params, method, result);
            return true;
        }
        else if (MethodKey.unMuteMembers.equals(method)) {
            unMuteMembers(params, method, result);
            return true;
        }
        else if (MethodKey.muteAllMembers.equals(method)) {
            muteAllMembers(params, method, result);
            return true;
        }
        else if (MethodKey.unMuteAllMembers.equals(method)) {
            unMuteAllMembers(params, method, result);
            return true;
        }
        else if (MethodKey.addWhiteList.equals(method)) {
            addWhiteList(params, method, result);
            return true;
        }
        else if (MethodKey.removeWhiteList.equals(method)) {
            removeWhiteList(params, method, result);
            return true;
        }
        else if (MethodKey.uploadGroupSharedFile.equals(method)) {
            uploadGroupSharedFile(params, method, result);
            return true;
        }
        else if (MethodKey.downloadGroupSharedFile.equals(method)) {
            downloadGroupSharedFile(params, method, result);
            return true;
        }
        else if (MethodKey.removeGroupSharedFile.equals(method)) {
            removeGroupSharedFile(params, method, result);
            return true;
        }
        else if (MethodKey.updateGroupAnnouncement.equals(method)) {
            updateGroupAnnouncement(params, method, result);
            return true;
        }
        else if (MethodKey.updateGroupExt.equals(method)) {
            updateGroupExt(params, method, result);
            return true;
        }
        else if (MethodKey.joinPublicGroup.equals(method)) {
            joinPublicGroup(params, method, result);
            return true;
        }
        else if (MethodKey.requestToJoinPublicGroup.equals(method)) {
            requestToJoinPublicGroup(params, method, result);
            return true;
        }
        else if (MethodKey.acceptJoinApplication.equals(method)) {
            acceptJoinApplication(params, method, result);
            return true;
        }
        else if (MethodKey.declineJoinApplication.equals(method)) {
            declineJoinApplication(params, method, result);
            return true;
        }
        else if (MethodKey.acceptInvitationFromGroup.equals(method)) {
            acceptInvitationFromGroup(params, method, result);
            return true;
        }
        else if (MethodKey.declineInvitationFromGroup.equals(method)) {
            declineInvitationFromGroup(params, method, result);
            return true;
        }
        else if (MethodKey.setMemberAttributesFromGroup.equals(method)) {
            setMemberAttributes(params, method, result);
            return true;
        }
        else if (MethodKey.removeMemberAttributesFromGroup.equals(method)) {
            removeMemberAttributes(params, method, result);
            return true;
        }
        else if (MethodKey.fetchMemberAttributesFromGroup.equals(method)) {
            fetchMemberAttributes(params, method, result);
            return true;
        }
        else if (MethodKey.fetchMembersAttributesFromGroup.equals(method)) {
            fetchMembersAttributes(params, method, result);
            return true;
        }
        else if (MethodKey.fetchMemberAllAttributes.equals(method)) {
            fetchMemberAllAttributes(params, method, result);
            return true;
        }
        else if (MethodKey.fetchJoinedGroupCount.equals(method)) {
            fetchJoinedGroupCount(params, method, result);
            return true;
        }
        else if (MethodKey.clearAllGroupsFromDB.equals(method)) {
            clearAllGroupsFromDB(params, method, result);
            return true;
        }
        else if (MethodKey.isMemberInGroupMuteList.equals(method)) {
            isMemberInGroupMuteList(params, method, result);
            return true;
        }
        else if (MethodKey.fetchGroupMembersInfo.equals(method)) {
            fetchGroupMembersInfo(params, method, result);
            return true;
        }
        else if (MethodKey.updateGroupAvatar.equals(method)) {
            updateGroupAvatar(params, method, result);
            return true;
        }
        else if (MethodKey.updateGroupConfigs.equals(method)) {
            updateGroupConfigs(params, method, result);
            return true;
        }
        else if (MethodKey.updateGroupExtension.equals(method)) {
            updateGroupExtension(params, method, result);
            return true;
        }
        else if (MethodKey.blockUser.equals(method)) {
            blockUser(params, method, result);
            return true;
        }
        else if (MethodKey.unblockUser.equals(method)) {
            unblockUser(params, method, result);
            return true;
        }
        else if (MethodKey.fetchGroupBlackList.equals(method)) {
            fetchGroupBlackList(params, method, result);
            return true;
        }
        else if (MethodKey.getGroupNamecard.equals(method)) {
            getGroupNamecard(params, method, result);
            return true;
        }
        else if (MethodKey.removeUserFromGroup.equals(method)) {
            removeUserFromGroup(params, method, result);
            return true;
        }
        else if (MethodKey.updateGroupNamecard.equals(method)) {
            updateGroupNamecard(params, method, result);
            return true;
        }
        else if (MethodKey.getUsers.equals(method)) {
            getUsers(params, method, result);
            return true;
        }

        return super.dispatchMethodCall(method, params, result);
    }



    private void getGroupWithId(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        asyncRunnable(() -> {
            EMGroup group = EMClient.getInstance().groupManager().getGroup(groupId);
            if (group != null) {
                onSuccess(result, channelName, GroupHelper.toJson(group));
            } else {
                onSuccess(result, channelName, null);
            }
        });
    }

    private void getJoinedGroups(JSONObject param, String channelName, Result result) throws JSONException {
        asyncRunnable(() -> {
            List<EMGroup> groups = EMClient.getInstance().groupManager().getAllGroups();
            List<Map> groupList = new ArrayList<>();
            for (EMGroup group : groups) {
                groupList.add(GroupHelper.toJson(group));
            }
            onSuccess(result, channelName, groupList);
        });
    }

    private void getJoinedGroupsFromServer(JSONObject param, String channelName, Result result) throws JSONException {
        // 5.0 移除拉取接口，改用本地群列表
        asyncRunnable(() -> {
            List<EMGroup> list = EMClient.getInstance().groupManager().getAllGroups();
            List<Map> groupList = new ArrayList<>();
            for (EMGroup group : list) {
                groupList.add(GroupHelper.toJson(group));
            }
            onSuccess(result, channelName, groupList);
        });
    }


    private void getPublicGroupsFromServer(JSONObject param, String channelName, Result result) throws JSONException {
        // 5.0 移除拉取接口，改用本地群列表
        asyncRunnable(() -> {
            List<EMGroup> list = EMClient.getInstance().groupManager().getAllGroups();
            List<Map> groupList = new ArrayList<>();
            for (EMGroup group : list) {
                groupList.add(GroupHelper.toJson(group));
            }
            onSuccess(result, channelName, groupList);
        });
    }


    private void createGroup(JSONObject param, String channelName, Result result) throws JSONException {
        String groupName = null;

        if (param.has("groupName")){
            groupName = param.getString("groupName");
        }

        String avatarUrl = null;
        if(param.has("avatarUrl")) {
            avatarUrl = param.getString("avatarUrl");
        }

        String desc = null;
        if(param.has("desc")){
            desc = param.getString("desc");
        }

        String[] members = null;
        if(param.has("inviteMembers")){
            JSONArray inviteMembers = param.getJSONArray("inviteMembers");
            members = new String[inviteMembers.length()];
            for (int i = 0; i < inviteMembers.length(); i++) {
                members[i] = inviteMembers.getString(i);
            }
        }
        if (members == null) {
            members = new String[0];
        }
        String inviteReason = null;

        if (param.has("inviteReason")){
            inviteReason = param.getString("inviteReason");
        }

        EMGroupConfigs options = GroupOptionsHelper.fromJson(param.getJSONObject("options"));

        EMValueWrapperCallBack<EMGroup> callBack = new EMValueWrapperCallBack<EMGroup>(result, channelName) {
            @Override
            public void onSuccess(EMGroup object) {
                updateObject(GroupHelper.toJson(object));
            }
        };
        EMClient.getInstance().groupManager().asyncCreateGroup(groupName, avatarUrl, desc, members, inviteReason, options, callBack);
    }

    private void getGroupSpecificationFromServer(JSONObject param, String channelName, Result result)
            throws JSONException {
        String groupId = param.getString("groupId");
        final boolean fetchMembers = param.optBoolean("fetchMembers", false);
        asyncRunnable(() -> {
            try {
                // 5.0 getGroupFromServer 只保留单参数（移除 fetchMembers）
                EMGroup group = EMClient.getInstance().groupManager().getGroupFromServer(groupId);
                onSuccess(result, channelName, GroupHelper.toJson(group));
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void getGroupMemberListFromServer(JSONObject param, String channelName, Result result)
            throws JSONException {
        String groupId = param.getString("groupId");
        String cursor = null;
        if(param.has("cursor")){
            cursor = param.getString("cursor");
        }
        int pageSize = param.getInt("pageSize");

        EMValueWrapperCallBack<EMCursorResult<String>> callBack = new EMValueWrapperCallBack<EMCursorResult<String>>(
                result, channelName) {
            @Override
            public void onSuccess(EMCursorResult<String> object) {
                updateObject(CursorResultHelper.toJson(object));
            }
        };

        EMClient.getInstance().groupManager().asyncFetchGroupMembers(groupId, cursor, pageSize, callBack);

    }

    private void getGroupBlockListFromServer(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        int pageSize = 0;
        if (param.has("pageSize")){
            pageSize = param.getInt("pageSize");
        }
        int pageNum = 0;
        if (param.has("pageNum")){
            pageNum = param.getInt("pageNum");
        }

        EMClient.getInstance().groupManager().asyncGetBlockedUsers(groupId, pageNum, pageSize,
                new EMValueWrapperCallBack<List<String>>(result, channelName));
    }

    private void getGroupMuteListFromServer(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        int pageSize = 0;
        if (param.has("pageSize")){
            pageSize = param.getInt("pageSize");
        }
        int pageNum = 0;
        if (param.has("pageNum")){
            pageNum = param.getInt("pageNum");
        }


        EMValueWrapperCallBack<Map<String, Long>> callBack = new EMValueWrapperCallBack<Map<String, Long>>(result,
                channelName) {
            @Override
            public void onSuccess(Map<String, Long> object) {
                updateObject(object);
            }
        };

        EMClient.getInstance().groupManager().asyncFetchGroupMuteList(groupId, pageNum, pageSize, callBack);
    }

    private void getGroupWhiteListFromServer(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        EMClient.getInstance().groupManager().fetchGroupWhiteList(groupId,
                new EMValueWrapperCallBack<List<String>>(result, channelName));
    }

    private void isMemberInWhiteListFromServer(JSONObject param, String channelName, Result result)
            throws JSONException {
        String groupId = param.getString("groupId");
        EMClient.getInstance().groupManager().checkIfInGroupWhiteList(groupId,
                new EMValueWrapperCallBack<Boolean>(result, channelName));
    }

    private void getGroupFileListFromServer(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        int pageNum = 0;
        if (param.has("pageNum")){
            pageNum = param.getInt("pageNum");
        }
        int pageSize = 0;
        if (param.has("pageSize")) {
            pageSize = param.getInt("pageSize");
        }

        EMValueWrapperCallBack<List<EMMucSharedFile>> callBack = new EMValueWrapperCallBack<List<EMMucSharedFile>>(
                result, channelName) {
            @Override
            public void onSuccess(List<EMMucSharedFile> object) {
                List<Map> fileList = new ArrayList<>();
                for (EMMucSharedFile file : object) {
                    fileList.add(MucSharedFileHelper.toJson(file));
                }
                updateObject(fileList);
            }
        };

        EMClient.getInstance().groupManager().asyncFetchGroupSharedFileList(groupId, pageNum, pageSize, callBack);
    }

    private void getGroupAnnouncementFromServer(JSONObject param, String channelName, Result result)
            throws JSONException {
        String groupId = param.getString("groupId");
        EMClient.getInstance().groupManager().asyncFetchGroupAnnouncement(groupId,
                new EMValueWrapperCallBack<String>(result, channelName));
    }

    private void inviterUser(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        String reason = null;
        if (param.has("reason")) {
            reason = param.getString("reason");
        }
        String[] members = null;
        if (param.has("members")){
            JSONArray array = param.getJSONArray("members");
            members = new String[array.length()];
            for (int i = 0; i < array.length(); i++) {
                members[i] = array.getString(i);
            }
        }
        if (members == null) {
            members = new String[0];
        }
        EMClient.getInstance().groupManager().asyncInviteUser(groupId, members, reason,
                new EMWrapperCallBack(result, channelName, true));
    }

    private void addMembers(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");

        String[] members = null;
        if (param.has("members")){
            JSONArray array = param.getJSONArray("members");
            members = new String[array.length()];
            for (int i = 0; i < array.length(); i++) {
                members[i] = array.getString(i);
            }
        }
        if (members == null) {
            members = new String[0];
        }

        String welcome = null;
        if (param.has("welcome")){
            welcome = param.getString("welcome");
        }
        String finalWelcome = welcome;
        String[] finalMembers = members;
        asyncRunnable(() -> {
            try {
                EMClient.getInstance().groupManager().addUsersToGroup(groupId, finalMembers, finalWelcome);
                onSuccess(result, channelName, true);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void removeMembers(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        List<String> members = new ArrayList<>();
        if (param.has("members")){
            JSONArray array = param.getJSONArray("members");
            for (int i = 0; i < array.length(); i++) {
                members.add(array.getString(i));
            }
        }

        EMClient.getInstance().groupManager().asyncRemoveUsersFromGroup(groupId, members,
                new EMWrapperCallBack(result, channelName, true));
    }

    private void blockMembers(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        List<String> members = new ArrayList<>();
        if (param.has("members")){
            JSONArray array = param.getJSONArray("members");
            for (int i = 0; i < array.length(); i++) {
                members.add(array.getString(i));
            }
        }

        EMClient.getInstance().groupManager().asyncBlockUsers(groupId, members,
                new EMWrapperCallBack(result, channelName, true));
    }

    private void unblockMembers(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        List<String> members = new ArrayList<>();
        if (param.has("members")){
            JSONArray array = param.getJSONArray("members");
            for (int i = 0; i < array.length(); i++) {
                members.add(array.getString(i));
            }
        }

        EMClient.getInstance().groupManager().asyncUnblockUsers(groupId, members,
                new EMWrapperCallBack(result, channelName, true));
    }

    private void updateGroupSubject(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");

        String name = "";
        if (param.has("name")){
            name = param.getString("name");
        }

        EMClient.getInstance().groupManager().asyncChangeGroupName(groupId, name, new EMWrapperCallBack(result, channelName, null));

    }

    private void updateDescription(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        String desc = "";
        if (param.has("desc")){
            desc = param.getString("desc");
        }

        EMClient.getInstance().groupManager().asyncChangeGroupDescription(groupId, desc, new EMWrapperCallBack(result, channelName, null) );
    }

    private void leaveGroup(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        EMClient.getInstance().groupManager().asyncLeaveGroup(groupId,
                new EMWrapperCallBack(result, channelName, true));
    }

    private void destroyGroup(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        EMClient.getInstance().groupManager().asyncDestroyGroup(groupId,
                new EMWrapperCallBack(result, channelName, true));
    }

    private void blockGroup(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        EMClient.getInstance().groupManager().asyncBlockGroupMessage(groupId, new EMWrapperCallBack(result, channelName, null) );
    }

    private void unblockGroup(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");

        EMClient.getInstance().groupManager().asyncUnblockGroupMessage(groupId,  new EMWrapperCallBack(result, channelName, null));
    }

    private void updateGroupOwner(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        String newOwner = param.getString("owner");

        EMValueWrapperCallBack<EMGroup> callBack = new EMValueWrapperCallBack<EMGroup>(result, channelName) {
            @Override
            public void onSuccess(EMGroup object) {
                super.updateObject(GroupHelper.toJson(object));
            }
        };

        EMClient.getInstance().groupManager().asyncChangeOwner(groupId, newOwner, callBack);
    }

    private void addAdmin(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        String admin = param.getString("admin");

        EMValueWrapperCallBack<EMGroup> callBack = new EMValueWrapperCallBack<EMGroup>(result, channelName) {
            @Override
            public void onSuccess(EMGroup object) {
                super.updateObject(GroupHelper.toJson(object));
            }
        };

        EMClient.getInstance().groupManager().asyncAddGroupAdmin(groupId, admin, callBack);
    }

    private void removeAdmin(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        String admin = param.getString("admin");

        EMValueWrapperCallBack<EMGroup> callBack = new EMValueWrapperCallBack<EMGroup>(result, channelName) {
            @Override
            public void onSuccess(EMGroup object) {
                super.updateObject(GroupHelper.toJson(object));
            }
        };

        EMClient.getInstance().groupManager().asyncRemoveGroupAdmin(groupId, admin, callBack);
    }

    private void muteMembers(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");

        int duration = 0;
        if (param.has("duration")){
            duration = param.getInt("duration");
        }
        List<String> members = new ArrayList<>();
        if (param.has("members")){
            JSONArray array = param.getJSONArray("members");
            for (int i = 0; i < array.length(); i++) {
                members.add(array.getString(i));
            }
        }
        EMValueWrapperCallBack<EMGroup> callBack = new EMValueWrapperCallBack<EMGroup>(result, channelName) {
            @Override
            public void onSuccess(EMGroup object) {
                super.updateObject(GroupHelper.toJson(object));
            }
        };

        EMClient.getInstance().groupManager().asyncMuteGroupMembers(groupId, members, duration, callBack);
    }

    private void unMuteMembers(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        List<String> members = new ArrayList<>();
        if (param.has("members")){
            JSONArray array = param.getJSONArray("members");
            for (int i = 0; i < array.length(); i++) {
                members.add(array.getString(i));
            }
        }
        EMValueWrapperCallBack<EMGroup> callBack = new EMValueWrapperCallBack<EMGroup>(result, channelName) {
            @Override
            public void onSuccess(EMGroup object) {
                super.updateObject(GroupHelper.toJson(object));
            }
        };

        EMClient.getInstance().groupManager().asyncUnMuteGroupMembers(groupId, members, callBack);
    }

    private void muteAllMembers(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");

        EMValueWrapperCallBack<EMGroup> callBack = new EMValueWrapperCallBack<EMGroup>(result, channelName) {
            @Override
            public void onSuccess(EMGroup object) {
                super.updateObject(GroupHelper.toJson(object));
            }
        };

        EMClient.getInstance().groupManager().muteAllMembers(groupId, callBack);
    }

    private void unMuteAllMembers(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");

        EMValueWrapperCallBack<EMGroup> callBack = new EMValueWrapperCallBack<EMGroup>(result, channelName) {
            @Override
            public void onSuccess(EMGroup object) {
                super.updateObject(GroupHelper.toJson(object));
            }
        };

        EMClient.getInstance().groupManager().unmuteAllMembers(groupId, callBack);
    }

    private void addWhiteList(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        List<String> members = new ArrayList<>();
        if (param.has("members")){
            JSONArray array = param.getJSONArray("members");
            for (int i = 0; i < array.length(); i++) {
                members.add(array.getString(i));
            }
        }
        EMClient.getInstance().groupManager().addToGroupWhiteList(groupId, members,
                new EMWrapperCallBack(result, channelName, true));
    }

    private void removeWhiteList(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        List<String> members = new ArrayList<>();
        if (param.has("members")){
            JSONArray array = param.getJSONArray("members");
            for (int i = 0; i < array.length(); i++) {
                members.add(array.getString(i));
            }
        }
        EMClient.getInstance().groupManager().removeFromGroupWhiteList(groupId, members,
                new EMWrapperCallBack(result, channelName, true));
    }

    private void uploadGroupSharedFile(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        String filePath = null;
        if (param.has("filePath")){
            filePath = param.getString("filePath");
        }

        // 5.0 asyncUploadGroupSharedFile 回调改为 EMValueCallBack<EMMucSharedFile>
        EMClient.getInstance().groupManager().asyncUploadGroupSharedFile(groupId, filePath,
                new EMValueWrapperCallBack<EMMucSharedFile>(result, channelName) {
                    @Override
                    public void onSuccess(EMMucSharedFile file) {
                        Map<String, Object> data = new HashMap<>();
                        data.put("fileId", file.getFileId());
                        data.put("fileName", file.getFileName());
                        GroupManagerWrapper.this.onSuccess(result, channelName, data);
                    }
                });
    }

    private void downloadGroupSharedFile(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        String fileId = null;
        if (param.has("fileId")) {
            fileId = param.getString("fileId");
        }
        String savePath = null;
        if (param.has("savePath")) {
            savePath = param.getString("savePath");
        }

        // 5.0 asyncDownloadGroupSharedFile 回调改为 EMCallBack
        EMClient.getInstance().groupManager().asyncDownloadGroupSharedFile(groupId, fileId, savePath,
                new EMWrapperCallBack(result, channelName, null));

        post(()->{
            onSuccess(result, channelName, true);
        });
    }

    private void removeGroupSharedFile(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        String fileId = null;
        if (param.has("fileId")) {
            fileId = param.getString("fileId");
        }
        EMClient.getInstance().groupManager().asyncDeleteGroupSharedFile(groupId, fileId,
                new EMWrapperCallBack(result, channelName, true));
    }

    private void updateGroupAnnouncement(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        String announcement = null;
        if (param.has("announcement")) {
            announcement = param.getString("announcement");
        }

        EMClient.getInstance().groupManager().asyncUpdateGroupAnnouncement(groupId, announcement, new EMWrapperCallBack(result, channelName, null) );
    }

    private void updateGroupExt(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        String ext = null;
        if (param.has("ext")) {
            ext = param.getString("ext");
        }

        String finalExt = ext;
        asyncRunnable(() -> {
            try {
                EMGroup group = EMClient.getInstance().groupManager().updateGroupExtension(groupId, finalExt);
                onSuccess(result, channelName, GroupHelper.toJson(group));
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void joinPublicGroup(JSONObject param, String channelName, Result result) throws JSONException {

        String groupId = param.getString("groupId");
        asyncRunnable(()->{
            try{
                // 5.0 移除 isMemberOnly 权限判断
                EMClient.getInstance().groupManager().joinGroup(groupId);

                onSuccess(result, channelName, null);
            }catch (HyphenateException e){
                onError(result, e);
            }
        });
    }

    private void requestToJoinPublicGroup(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        String reason = null;
        if (param.has("reason")){
            reason = param.getString("reason");
        }

        EMClient.getInstance().groupManager().asyncApplyJoinToGroup(groupId, reason, new EMWrapperCallBack(result, channelName, null));
    }

    private void acceptJoinApplication(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");

        String username = null;
        if (param.has("userId")){
            username = param.getString("userId");
        }

        EMClient.getInstance().groupManager().asyncAcceptApplication(username, groupId, new EMWrapperCallBack(result, channelName, null));
    }

    private void declineJoinApplication(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        String username = null;
        if (param.has("userId")){
            username = param.getString("userId");
        }
        String reason = null;
        if (param.has("reason")){
            reason = param.getString("reason");
        }

        EMClient.getInstance().groupManager().asyncDeclineApplication(username, groupId, reason, new EMWrapperCallBack(result, channelName, null));
    }

    private void acceptInvitationFromGroup(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");

        String inviter = null;
        if (param.has("inviter")){
            inviter = param.getString("inviter");
        }
        EMValueWrapperCallBack<EMGroup> callBack = new EMValueWrapperCallBack<EMGroup>(result, channelName) {
            @Override
            public void onSuccess(EMGroup object) {
                super.updateObject(GroupHelper.toJson(object));
            }
        };

        EMClient.getInstance().groupManager().asyncAcceptInvitation(groupId, inviter, callBack);
    }

    private void declineInvitationFromGroup(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        String username = null;
        if (param.has("userId")){
            username = param.getString("userId");
        }
        String reason = null;
        if (param.has("reason")){
            reason = param.getString("reason");
        }

        EMClient.getInstance().groupManager().asyncDeclineInvitation(groupId, username, reason, new EMWrapperCallBack(result, channelName, null));
    }

    private void setMemberAttributes(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        String userId = param.optString("userId");
        if (userId.length() == 0) {
            userId = EMClient.getInstance().getCurrentUser();
        }
        Map<String, String> attributes = new HashMap<>();

        JSONObject jsonObject = param.getJSONObject("attributes");
        Iterator iterator = jsonObject.keys();
        while (iterator.hasNext()) {
            String key = iterator.next().toString();
            attributes.put(key, jsonObject.getString(key));
        }

        EMClient.getInstance().groupManager().asyncSetGroupMemberAttributes(groupId, userId, attributes, new EMWrapperCallBack(result, channelName, null));
    }

    private void removeMemberAttributes(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        String userId = param.optString("userId");
        if (userId.length() == 0) {
            userId = EMClient.getInstance().getCurrentUser();
        }
        Map<String, String> attributes = new HashMap<>();

        JSONArray ja = param.getJSONArray("keys");
        for (int i = 0; i < ja.length(); i++) {
            attributes.put(ja.optString(i),"" );
        }

        EMClient.getInstance().groupManager().asyncSetGroupMemberAttributes(groupId, userId, attributes, new EMWrapperCallBack(result, channelName, null));
    }

    private void fetchMemberAttributes(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        String userId = param.optString("userId");
        if (userId.length() == 0) {
            userId = EMClient.getInstance().getCurrentUser();
        }
        String finalUserId = userId;
        EMClient.getInstance().groupManager().asyncFetchGroupMemberAllAttributes(groupId, userId, new EMValueWrapperCallBack<Map<String,Map<String,String>>>(result, channelName){

            @Override
            public void onSuccess(Map<String, Map<String, String>> object) {
                updateObject(object.get(finalUserId));
            }
        });
    }

    private void fetchMembersAttributes(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        JSONArray jUsers = param.getJSONArray("userIds");
        List<String> userIds = new ArrayList<>();
        for (int i = 0; i < jUsers.length(); i++) {
            userIds.add(jUsers.getString(i));
        }
        List<String> keys = new ArrayList<>();
        if (param.has("keys")) {
            JSONArray jsonArray = param.getJSONArray("keys");
            for (int i = 0; i < jsonArray.length(); i++) {
                keys.add(jsonArray.getString(i));
            }
        }
        EMValueWrapperCallBack callback = new EMValueWrapperCallBack<Map<String, Map<String, String>>>(result, channelName) {
            @Override
            public void onSuccess(Map<String, Map<String, String>> object) {
                updateObject(object);
            }
        };

        EMClient.getInstance().groupManager().asyncFetchGroupMembersAttributes(groupId, userIds, keys, callback);
    }

    private void fetchMemberAllAttributes(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        String userId = param.getString("userId");
        // 【透传原生】5.0 asyncFetchGroupMemberAllAttributes(groupId, userId) 拉取单成员全部自定义属性
        EMValueWrapperCallBack callback = new EMValueWrapperCallBack<Map<String, Map<String, String>>>(result, channelName) {
            @Override
            public void onSuccess(Map<String, Map<String, String>> object) {
                updateObject(object);
            }
        };
        EMClient.getInstance().groupManager().asyncFetchGroupMemberAllAttributes(groupId, userId, callback);
    }


    private void fetchJoinedGroupCount(JSONObject param, String channelName, Result result) throws JSONException {
        EMClient.getInstance().groupManager().asyncGetJoinedGroupsCountFromServer(new EMValueWrapperCallBack<Integer>( result, channelName) {
            @Override
            public void onSuccess(Integer object) {
                super.onSuccess(object);
            }
        });
    }



    private void registerEaseListener() {

        if (groupChangeListener != null) {
            EMClient.getInstance().groupManager().removeGroupChangeListener(groupChangeListener);
        }
        groupChangeListener = new EMGroupChangeListener() {

            @Override
            public void onWhiteListAdded(String groupId, List<String> whitelist) {
                ListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("type", "onGroupWhiteListAdded");
                            data.put("groupId", groupId);
                            data.put("whitelist", whitelist);
                            post(() -> channel.invokeMethod(MethodKey.onGroupChanged, data));
                        }
                );
            }

            @Override
            public void onWhiteListRemoved(String groupId, List<String> whitelist) {
                ListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("type", "onGroupWhiteListRemoved");
                            data.put("groupId", groupId);
                            data.put("whitelist", whitelist);
                            post(() -> channel.invokeMethod(MethodKey.onGroupChanged, data));
                        }
                );
            }

            @Override
            public void onAllMemberMuteStateChanged(String groupId, boolean isMuted) {
                ListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("type", "onGroupAllMemberMuteStateChanged");
                            data.put("groupId", groupId);
                            data.put("isMuted", isMuted);
                            post(() -> channel.invokeMethod(MethodKey.onGroupChanged, data));
                        }
                );
            }

            @Override
            public void onInvitationReceived(String groupId, String groupName, String inviter, String reason) {
                ListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("type", "onGroupInvitationReceived");
                            data.put("groupId", groupId);
                            data.put("groupName", groupName);
                            data.put("inviter", inviter);
                            data.put("reason", reason);
                            post(() -> channel.invokeMethod(MethodKey.onGroupChanged, data));
                        }
                );
            }

            @Override
            public void onRequestToJoinReceived(String groupId, String groupName, String applicant, String reason) {
                ListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("type", "onGroupRequestToJoinReceived");
                            data.put("groupId", groupId);
                            data.put("groupName", groupName);
                            data.put("applicant", applicant);
                            data.put("reason", reason);
                            post(() -> channel.invokeMethod(MethodKey.onGroupChanged, data));
                        }
                );

            }

            @Override
            public void onRequestToJoinAccepted(String groupId, String groupName, String accepter) {
                ListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("type", "onGroupRequestToJoinAccepted");
                            data.put("groupId", groupId);
                            data.put("groupName", groupName);
                            data.put("accepter", accepter);
                            post(() -> channel.invokeMethod(MethodKey.onGroupChanged, data));
                        }
                );

            }

            @Override
            public void onRequestToJoinDeclined(String groupId, String groupName, String decliner, String reason, String applicant) {
                ListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("type", "onGroupRequestToJoinDeclined");
                            data.put("groupId", groupId);
                            data.put("groupName", groupName);
                            data.put("applicant", applicant);
                            data.put("decliner", decliner);
                            data.put("reason", reason);
                            post(() -> channel.invokeMethod(MethodKey.onGroupChanged, data));
                        }
                );

            }

            @Override
            public void onInvitationAccepted(String groupId, String invitee, String reason) {
                ListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("type", "onGroupInvitationAccepted");
                            data.put("groupId", groupId);
                            data.put("invitee", invitee);
                            data.put("reason", reason);
                            post(() -> channel.invokeMethod(MethodKey.onGroupChanged, data));
                        }
                );

            }

            @Override
            public void onInvitationDeclined(String groupId, String invitee, String reason) {
                ListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("type", "onGroupInvitationDeclined");
                            data.put("groupId", groupId);
                            data.put("invitee", invitee);
                            data.put("reason", reason);
                            post(() -> channel.invokeMethod(MethodKey.onGroupChanged, data));
                        }
                );

            }

            @Override
            public void onUserRemoved(String groupId, String groupName) {
                ListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("type", "onGroupUserRemoved");
                            data.put("groupId", groupId);
                            data.put("groupName", groupName);
                            post(() -> channel.invokeMethod(MethodKey.onGroupChanged, data));
                        }
                );

            }

            @Override
            public void onGroupDestroyed(String groupId, String groupName) {
                ListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("type", "onGroupDestroyed");
                            data.put("groupId", groupId);
                            data.put("groupName", groupName);
                            post(() -> channel.invokeMethod(MethodKey.onGroupChanged, data));
                        }
                );

            }

            @Override
            public void onAutoAcceptInvitationFromGroup(String groupId, String inviter, String inviteMessage) {
                ListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("type", "onGroupAutoAcceptInvitation");
                            data.put("groupId", groupId);
                            data.put("inviter", inviter);
                            data.put("inviteMessage", inviteMessage);
                            post(() -> channel.invokeMethod(MethodKey.onGroupChanged, data));
                        }
                );

            }

            @Override
            public void onMuteListAdded(String groupId, List<String> mutes, long muteExpire) {
                ListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("type", "onGroupMuteListAdded");
                            data.put("groupId", groupId);
                            data.put("mutes", mutes);
                            data.put("muteExpire", muteExpire);
                            post(() -> channel.invokeMethod(MethodKey.onGroupChanged, data));
                        }
                );

            }

            @Override
            public void onMuteListRemoved(String groupId, List<String> mutes) {
                ListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("type", "onGroupMuteListRemoved");
                            data.put("groupId", groupId);
                            data.put("mutes", mutes);
                            post(() -> channel.invokeMethod(MethodKey.onGroupChanged, data));
                        }
                );
            }

            @Override
            public void onAdminAdded(String groupId, String administrator) {
                ListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("type", "onGroupAdminAdded");
                            data.put("groupId", groupId);
                            data.put("administrator", administrator);
                            post(() -> channel.invokeMethod(MethodKey.onGroupChanged, data));
                        }
                );
            }

            @Override
            public void onAdminRemoved(String groupId, String administrator) {
                ListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("type", "onGroupAdminRemoved");
                            data.put("groupId", groupId);
                            data.put("administrator", administrator);
                            post(() -> channel.invokeMethod(MethodKey.onGroupChanged, data));
                        }
                );
            }

            @Override
            public void onOwnerChanged(String groupId, String newOwner, String oldOwner) {
                ListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("type", "onGroupOwnerChanged");
                            data.put("groupId", groupId);
                            data.put("newOwner", newOwner);
                            data.put("oldOwner", oldOwner);
                            post(() -> channel.invokeMethod(MethodKey.onGroupChanged, data));
                        }
                );
            }

            @Override
            public void onAnnouncementChanged(String groupId, String announcement) {
                ListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("type", "onGroupAnnouncementChanged");
                            data.put("groupId", groupId);
                            if(announcement == null) {
                                data.put("announcement", "");
                            }else {
                                data.put("announcement", announcement);
                            }
                            post(() -> channel.invokeMethod(MethodKey.onGroupChanged, data));
                        }
                );
            }

            @Override
            public void onSharedFileAdded(String groupId, EMMucSharedFile sharedFile) {
                ListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("type", "onGroupSharedFileAdded");
                            data.put("groupId", groupId);
                            data.put("sharedFile", MucSharedFileHelper.toJson(sharedFile));
                            post(() -> channel.invokeMethod(MethodKey.onGroupChanged, data));
                        }
                );
            }

            @Override
            public void onSharedFileDeleted(String groupId, String fileId) {
                ListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("type", "onGroupSharedFileDeleted");
                            data.put("groupId", groupId);
                            data.put("fileId", fileId);
                            post(() -> channel.invokeMethod(MethodKey.onGroupChanged, data));
                        }
                );
            }

            @Override
            public void onSpecificationChanged(EMGroup group) {
                ListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("type", "onGroupSpecificationDidUpdate");
                            data.put("group", GroupHelper.toJson(group));
                            post(() -> channel.invokeMethod(MethodKey.onGroupChanged, data));
                        }
                );
            }

            @Override
            public void onStateChanged(EMGroup group, boolean isDisabled) {
                ListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("type", "onGroupStateChanged");
                            data.put("groupId", group.getGroupId());
                            data.put("isDisabled", isDisabled);
                            post(() -> channel.invokeMethod(MethodKey.onGroupChanged, data));
                        }
                );
            }

            @Override
            public void onGroupMemberAttributeChanged(String groupId, String userId, Map<String, String> attribute, String from) {
                ListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("type", "onGroupAttributesChangedOfMember");
                            data.put("groupId", groupId);
                            data.put("userId", userId);
                            if (from != null) {
                                data.put("operatorId", from);
                            }
                            if (attribute != null) {
                                data.put("attributes", attribute);
                            }
                            post(() -> channel.invokeMethod(MethodKey.onGroupChanged, data));
                        }
                );
            }

            @Override
            public void onUserGroupNamecardUpdated(String groupId, String userId, String namecard) {
                ListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("type", "onUserGroupNamecardUpdated");
                            data.put("groupId", groupId);
                            data.put("userId", userId);
                            if (namecard != null) {
                                data.put("namecard", namecard);
                            }
                            post(() -> channel.invokeMethod(MethodKey.onGroupChanged, data));
                        }
                );
            }

            @Override
            public void onMembersJoined(String groupId, List<String> members) {
                ListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("type", "onGroupMembersJoined");
                            data.put("groupId", groupId);
                            data.put("userIds", members);
                            post(() -> channel.invokeMethod(MethodKey.onGroupChanged, data));
                        }
                );
            }

            @Override
            public void onMembersExited(String groupId, List<String> members) {
                ListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("type", "onGroupMembersExited");
                            data.put("groupId", groupId);
                            data.put("userIds", members);
                            post(() -> channel.invokeMethod(MethodKey.onGroupChanged, data));
                        }
                );
            }
        };
        EMClient.getInstance().groupManager().addGroupChangeListener(groupChangeListener);
    }

    @Override
    public void unRegisterEaseListener() {
        EMClient.getInstance().groupManager().removeGroupChangeListener(groupChangeListener);
    }

    // 481
    private void clearAllGroupsFromDB(JSONObject param, String channelName, Result result){
        EMClient.getInstance().groupManager().cleanAllGroupsFromLocal();
        asyncRunnable(() -> {
            onSuccess(result, channelName,null);
        });
    }
    // 4.10
    private void isMemberInGroupMuteList(JSONObject param, String channelName, Result result) throws JSONException{
        String groupId = param.getString("groupId");
        EMClient.getInstance().groupManager().asyncCheckIfInMuteList(groupId, new EMValueWrapperCallBack<Boolean>(result, channelName) {
            @Override
            public void onSuccess(Boolean object) {
                updateObject(object);
            }
        });
    }

    private void fetchGroupMembersInfo(JSONObject param, String channelName, Result result) throws JSONException{
        String groupId = param.getString("groupId");
        int limit = param.getInt("limit");
        String cursor = param.optString("cursor");
        EMClient.getInstance().groupManager().asyncFetchGroupMembersInfo(groupId, cursor, limit, new EMValueWrapperCallBack<EMCursorResult<EMGroupMemberInfo>>(result, channelName){
            @Override
            public void onSuccess(EMCursorResult<EMGroupMemberInfo> object) {
                updateObject(CursorResultHelper.toJson(object));
            }
        });
    }

    private void updateGroupAvatar(JSONObject param, String channelName, Result result) throws JSONException{
        String groupId = param.getString("groupId");
        String avatarUrl = param.optString("avatarUrl");
        EMClient.getInstance().groupManager().asyncChangeGroupAvatar(groupId, avatarUrl, new EMWrapperCallBack(result, channelName,  null) {
            @Override
            public void onSuccess() {
                EMGroup group = EMClient.getInstance().groupManager().getGroup(groupId);
                super.updateObject(GroupHelper.toJson(group));
            }
        });
    }
    private void updateGroupConfigs(JSONObject params, String channelName, Result result) throws JSONException {
        String groupId = params.getString("groupId");
        EMGroupConfigs configs = GroupOptionsHelper.fromJson(params.getJSONObject("options"));
        EnumSet<EMGroupManager.EMGroupConfigsType> types = EnumSet.allOf(EMGroupManager.EMGroupConfigsType.class);
        EMClient.getInstance().groupManager().asyncUpdateGroupConfigs(groupId, types, configs,
                new EMValueWrapperCallBack<EMGroup>(result, channelName) {
                    @Override
                    public void onSuccess(EMGroup group) {
                        updateObject(GroupHelper.toJson(group));
                    }
                });
    }

    private void updateGroupExtension(JSONObject params, String channelName, Result result) throws JSONException {
        String groupId = params.getString("groupId");
        String extension = params.getString("ext");
        EMClient.getInstance().groupManager().asyncUpdateGroupExtension(groupId, extension,
                new EMValueWrapperCallBack<EMGroup>(result, channelName) {
                    @Override
                    public void onSuccess(EMGroup group) {
                        updateObject(GroupHelper.toJson(group));
                    }
                });
    }

    private void blockUser(JSONObject params, String channelName, Result result) throws JSONException {
        String groupId = params.getString("groupId");
        String username = params.getString("username");
        EMClient.getInstance().groupManager().asyncBlockUser(groupId, username,
                new EMWrapperCallBack(result, channelName, null));
    }

    private void unblockUser(JSONObject params, String channelName, Result result) throws JSONException {
        String groupId = params.getString("groupId");
        String username = params.getString("username");
        EMClient.getInstance().groupManager().asyncUnblockUser(groupId, username,
                new EMWrapperCallBack(result, channelName, null));
    }

    private void fetchGroupBlackList(JSONObject params, String channelName, Result result) throws JSONException {
        String groupId = params.getString("groupId");
        int pageNum = params.optInt("pageNum", 1);
        int pageSize = params.optInt("pageSize", 20);
        EMClient.getInstance().groupManager().asyncFetchGroupBlackList(groupId, pageNum, pageSize,
                new EMValueWrapperCallBack<List<String>>(result, channelName) {
                    @Override
                    public void onSuccess(List<String> list) {
                        updateObject(list);
                    }
                });
    }

    private void getGroupNamecard(JSONObject params, String channelName, Result result) throws JSONException {
        String groupId = params.getString("groupId");
        String member = params.getString("member");
        asyncRunnable(() -> {
            String namecard = EMClient.getInstance().groupManager().getGroupNamecard(groupId, member);
            onSuccess(result, channelName, namecard);
        });
    }

    private void removeUserFromGroup(JSONObject params, String channelName, Result result) throws JSONException {
        String groupId = params.getString("groupId");
        String username = params.getString("username");
        EMClient.getInstance().groupManager().asyncRemoveUserFromGroup(groupId, username,
                new EMWrapperCallBack(result, channelName, null));
    }

    private void updateGroupNamecard(JSONObject params, String channelName, Result result) throws JSONException {
        String groupId = params.getString("groupId");
        String namecard = params.getString("namecard");
        EMClient.getInstance().groupManager().asyncUpdateGroupNamecard(groupId, namecard,
                new EMWrapperCallBack(result, channelName, null));
    }

    private void getUsers(JSONObject params, String channelName, Result result) throws JSONException {
        String groupId = params.getString("groupId");
        asyncRunnable(() -> {
            try {
                EMGroup group = EMClient.getInstance().groupManager().getGroupFromServer(groupId);
                onSuccess(result, channelName, group.getUsers());
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

}
