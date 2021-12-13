package com.easemob.im_flutter_sdk;

import com.hyphenate.EMGroupChangeListener;
import com.hyphenate.chat.EMClient;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.JSONMethodCodec;
import io.flutter.plugin.common.MethodChannel.Result;

import com.hyphenate.chat.EMCursorResult;
import com.hyphenate.chat.EMGroup;
import com.hyphenate.chat.EMGroupInfo;
import com.hyphenate.chat.EMGroupOptions;
import com.hyphenate.chat.EMMucSharedFile;
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
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.PluginRegistry;

public class EMGroupManagerWrapper extends EMWrapper implements MethodCallHandler {

    EMGroupManagerWrapper(FlutterPlugin.FlutterPluginBinding flutterPluginBinding, String channelName) {
        super(flutterPluginBinding, channelName);
        registerEaseListener();
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {

        JSONObject param = (JSONObject) call.arguments;
        try {
            if (EMSDKMethod.getGroupWithId.equals(call.method)) {
                getGroupWithId(param, EMSDKMethod.getGroupWithId, result);
            } else if (EMSDKMethod.getJoinedGroups.equals(call.method)) {
                getJoinedGroups(param, EMSDKMethod.getJoinedGroups, result);
            } else if (EMSDKMethod.getGroupsWithoutPushNotification.equals(call.method)) {
                getGroupsWithoutPushNotification(param, EMSDKMethod.getGroupsWithoutPushNotification, result);
            } else if (EMSDKMethod.getJoinedGroupsFromServer.equals(call.method)) {
                getJoinedGroupsFromServer(param, EMSDKMethod.getJoinedGroupsFromServer, result);
            } else if (EMSDKMethod.getPublicGroupsFromServer.equals(call.method)) {
                getPublicGroupsFromServer(param, EMSDKMethod.getPublicGroupsFromServer, result);
            } else if (EMSDKMethod.createGroup.equals(call.method)) {
                createGroup(param, EMSDKMethod.createGroup, result);
            } else if (EMSDKMethod.getGroupSpecificationFromServer.equals(call.method)) {
                getGroupSpecificationFromServer(param, EMSDKMethod.getGroupSpecificationFromServer, result);
            } else if (EMSDKMethod.getGroupMemberListFromServer.equals(call.method)) {
                getGroupMemberListFromServer(param, EMSDKMethod.getGroupMemberListFromServer, result);
            } else if (EMSDKMethod.getGroupMuteListFromServer.equals(call.method)) {
                getGroupMuteListFromServer(param, EMSDKMethod.getGroupMuteListFromServer, result);
            } else if (EMSDKMethod.getGroupBlockListFromServer.equals(call.method)) {
                getGroupBlockListFromServer(param, EMSDKMethod.getGroupBlockListFromServer, result);
            } else if (EMSDKMethod.getGroupWhiteListFromServer.equals(call.method)) {
                getGroupWhiteListFromServer(param, EMSDKMethod.getGroupWhiteListFromServer, result);
            } else if (EMSDKMethod.isMemberInWhiteListFromServer.equals(call.method)) {
                isMemberInWhiteListFromServer(param, EMSDKMethod.isMemberInWhiteListFromServer, result);
            } else if (EMSDKMethod.getGroupFileListFromServer.equals(call.method)) {
                getGroupFileListFromServer(param, EMSDKMethod.getGroupFileListFromServer, result);
            } else if (EMSDKMethod.getGroupAnnouncementFromServer.equals(call.method)) {
                getGroupAnnouncementFromServer(param, EMSDKMethod.getGroupAnnouncementFromServer, result);
            } else if (EMSDKMethod.getGroupBlockListFromServer.equals(call.method)) {
                getGroupBlockListFromServer(param, EMSDKMethod.getGroupBlockListFromServer, result);
            } else if (EMSDKMethod.addMembers.equals(call.method)) {
                addMembers(param, EMSDKMethod.addMembers, result);
            } else if (EMSDKMethod.inviterUser.equals(call.method)){
                inviterUser(param, EMSDKMethod.inviterUser, result);
            } else if (EMSDKMethod.removeMembers.equals(call.method)) {
                removeMembers(param, EMSDKMethod.removeMembers, result);
            } else if (EMSDKMethod.blockMembers.equals(call.method)) {
                blockMembers(param, EMSDKMethod.blockMembers, result);
            } else if (EMSDKMethod.unblockMembers.equals(call.method)) {
                unblockMembers(param, EMSDKMethod.unblockMembers, result);
            } else if (EMSDKMethod.updateGroupSubject.equals(call.method)) {
                updateGroupSubject(param, EMSDKMethod.updateGroupSubject, result);
            } else if (EMSDKMethod.updateDescription.equals(call.method)) {
                updateDescription(param, EMSDKMethod.updateDescription, result);
            } else if (EMSDKMethod.leaveGroup.equals(call.method)) {
                leaveGroup(param, EMSDKMethod.leaveGroup, result);
            } else if (EMSDKMethod.destroyGroup.equals(call.method)) {
                destroyGroup(param, EMSDKMethod.destroyGroup, result);
            } else if (EMSDKMethod.blockGroup.equals(call.method)) {
                blockGroup(param, EMSDKMethod.blockGroup, result);
            } else if (EMSDKMethod.unblockGroup.equals(call.method)) {
                unblockGroup(param, EMSDKMethod.unblockGroup, result);
            } else if (EMSDKMethod.updateGroupOwner.equals(call.method)) {
                updateGroupOwner(param, EMSDKMethod.updateGroupOwner, result);
            } else if (EMSDKMethod.addAdmin.equals(call.method)) {
                addAdmin(param, EMSDKMethod.addAdmin, result);
            } else if (EMSDKMethod.removeAdmin.equals(call.method)) {
                removeAdmin(param, EMSDKMethod.removeAdmin, result);
            } else if (EMSDKMethod.muteMembers.equals(call.method)) {
                muteMembers(param, EMSDKMethod.muteMembers, result);
            } else if (EMSDKMethod.unMuteMembers.equals(call.method)) {
                unMuteMembers(param, EMSDKMethod.unMuteMembers, result);
            } else if (EMSDKMethod.muteAllMembers.equals(call.method)) {
                muteAllMembers(param, EMSDKMethod.muteAllMembers, result);
            } else if (EMSDKMethod.unMuteAllMembers.equals(call.method)) {
                unMuteAllMembers(param, EMSDKMethod.unMuteAllMembers, result);
            } else if (EMSDKMethod.addWhiteList.equals(call.method)) {
                addWhiteList(param, EMSDKMethod.addWhiteList, result);
            } else if (EMSDKMethod.removeWhiteList.equals(call.method)) {
                removeWhiteList(param, EMSDKMethod.removeWhiteList, result);
            } else if (EMSDKMethod.uploadGroupSharedFile.equals(call.method)) {
                uploadGroupSharedFile(param, EMSDKMethod.uploadGroupSharedFile, result);
            } else if (EMSDKMethod.downloadGroupSharedFile.equals(call.method)) {
                downloadGroupSharedFile(param, EMSDKMethod.downloadGroupSharedFile, result);
            } else if (EMSDKMethod.removeGroupSharedFile.equals(call.method)) {
                removeGroupSharedFile(param, EMSDKMethod.removeGroupSharedFile, result);
            } else if (EMSDKMethod.updateGroupAnnouncement.equals(call.method)) {
                updateGroupAnnouncement(param, EMSDKMethod.updateGroupExt, result);
            } else if (EMSDKMethod.updateGroupExt.equals(call.method)) {
                updateGroupExt(param, EMSDKMethod.updateGroupExt, result);
            } else if (EMSDKMethod.joinPublicGroup.equals(call.method)) {
                joinPublicGroup(param, EMSDKMethod.joinPublicGroup, result);
            } else if (EMSDKMethod.requestToJoinPublicGroup.equals(call.method)) {
                requestToJoinPublicGroup(param, EMSDKMethod.requestToJoinPublicGroup, result);
            } else if (EMSDKMethod.acceptJoinApplication.equals(call.method)) {
                acceptJoinApplication(param, EMSDKMethod.acceptJoinApplication, result);
            } else if (EMSDKMethod.declineJoinApplication.equals(call.method)) {
                declineJoinApplication(param, EMSDKMethod.declineJoinApplication, result);
            } else if (EMSDKMethod.acceptInvitationFromGroup.equals(call.method)) {
                acceptInvitationFromGroup(param, EMSDKMethod.acceptInvitationFromGroup, result);
            } else if (EMSDKMethod.declineInvitationFromGroup.equals(call.method)) {
                declineInvitationFromGroup(param, EMSDKMethod.declineInvitationFromGroup, result);
            } else if (EMSDKMethod.ignoreGroupPush.equals(call.method)) {
                ignoreGroupPush(param, EMSDKMethod.ignoreGroupPush, result);
            } else {
                super.onMethodCall(call, result);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void getGroupWithId(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        EMGroup group = EMClient.getInstance().groupManager().getGroup(groupId);
        if (group != null) {
            onSuccess(result, channelName, EMGroupHelper.toJson(group));
        } else {
            onSuccess(result, channelName, null);
        }
    }

    private void getJoinedGroups(JSONObject param, String channelName, Result result) throws JSONException {

        EMValueWrapperCallBack<List<EMGroup>> callBack = new EMValueWrapperCallBack<List<EMGroup>>(result,
                channelName) {
            @Override
            public void onSuccess(List<EMGroup> object) {
                List<Map> groupList = new ArrayList<>();
                for (EMGroup group : object) {
                    groupList.add(EMGroupHelper.toJson(group));
                }
                updateObject(groupList);
            }
        };
        List<EMGroup> groups = EMClient.getInstance().groupManager().getAllGroups();
        onSuccess(result, channelName, groups);
    }

    private void getGroupsWithoutPushNotification(JSONObject param, String channelName, Result result)
            throws JSONException {
        asyncRunnable(() -> {
            List<String> groups = EMClient.getInstance().pushManager().getNoPushGroups();
            onSuccess(result, channelName, groups);
        });
    }

    private void getJoinedGroupsFromServer(JSONObject param, String channelName, Result result) throws JSONException {

        int pageSize = param.getInt("pageSize");
        int pageNum = param.getInt("pageNum");

        EMValueWrapperCallBack<List<EMGroup>> callBack = new EMValueWrapperCallBack<List<EMGroup>>(result,
                channelName) {
            @Override
            public void onSuccess(List<EMGroup> object) {
                List<Map> groupList = new ArrayList<>();
                for (EMGroup group : object) {
                    groupList.add(EMGroupHelper.toJson(group));
                }
                updateObject(groupList);
            }
        };

        EMClient.getInstance().groupManager().asyncGetJoinedGroupsFromServer(pageNum, pageSize, callBack);
    }

    private void getPublicGroupsFromServer(JSONObject param, String channelName, Result result) throws JSONException {
        int pageSize = param.getInt("pageSize");
        String cursor = param.getString("cursor");

        EMValueWrapperCallBack<EMCursorResult<EMGroupInfo>> callBack = new EMValueWrapperCallBack<EMCursorResult<EMGroupInfo>>(
                result, channelName) {
            @Override
            public void onSuccess(EMCursorResult<EMGroupInfo> object) {
                updateObject(EMCursorResultHelper.toJson(object));
            }
        };

        EMClient.getInstance().groupManager().asyncGetPublicGroupsFromServer(pageSize, cursor, callBack);
    }

    private void createGroup(JSONObject param, String channelName, Result result) throws JSONException {
        String groupName = param.getString("groupName");
        String desc = param.getString("desc");
        JSONArray inviteMembers = param.getJSONArray("inviteMembers");
        String[] members = new String[inviteMembers.length()];
        for (int i = 0; i < inviteMembers.length(); i++) {
            members[i] = inviteMembers.getString(i);
        }
        String inviteReason = param.getString("inviteReason");
        EMGroupOptions options = EMGroupOptionsHelper.fromJson(param.getJSONObject("options"));

        EMValueWrapperCallBack<EMGroup> callBack = new EMValueWrapperCallBack<EMGroup>(result, channelName) {
            @Override
            public void onSuccess(EMGroup object) {
                updateObject(EMGroupHelper.toJson(object));
            }
        };

        EMClient.getInstance().groupManager().asyncCreateGroup(groupName, desc, members, inviteReason, options,
                callBack);
    }

    private void getGroupSpecificationFromServer(JSONObject param, String channelName, Result result)
            throws JSONException {
        String groupId = param.getString("groupId");

        EMValueWrapperCallBack<EMGroup> callBack = new EMValueWrapperCallBack<EMGroup>(result, channelName) {
            @Override
            public void onSuccess(EMGroup object) {
                updateObject(EMGroupHelper.toJson(object));
            }
        };

        EMClient.getInstance().groupManager().asyncGetGroupFromServer(groupId, callBack);
    }

    private void getGroupMemberListFromServer(JSONObject param, String channelName, Result result)
            throws JSONException {
        String groupId = param.getString("groupId");
        String cursor = param.getString("cursor");
        int pageSize = param.getInt("pageSize");

        EMValueWrapperCallBack<EMCursorResult<String>> callBack = new EMValueWrapperCallBack<EMCursorResult<String>>(
                result, channelName) {
            @Override
            public void onSuccess(EMCursorResult<String> object) {
                updateObject(EMCursorResultHelper.toJson(object));
            }
        };

        EMClient.getInstance().groupManager().asyncFetchGroupMembers(groupId, cursor, pageSize, callBack);

    }

    private void getGroupBlockListFromServer(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        int pageNum = param.getInt("pageNum");
        int pageSize = param.getInt("pageSize");

        EMClient.getInstance().groupManager().asyncGetBlockedUsers(groupId, pageNum, pageSize,
                new EMValueWrapperCallBack<List<String>>(result, channelName));
    }

    private void getGroupMuteListFromServer(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        int pageNum = param.getInt("pageNum");
        int pageSize = param.getInt("pageSize");

        EMValueWrapperCallBack<Map<String, Long>> callBack = new EMValueWrapperCallBack<Map<String, Long>>(result,
                channelName) {
            @Override
            public void onSuccess(Map<String, Long> object) {
                updateObject(object.keySet().toArray());
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
        int pageNum = param.getInt("pageNum");
        int pageSize = param.getInt("pageSize");

        EMValueWrapperCallBack<List<EMMucSharedFile>> callBack = new EMValueWrapperCallBack<List<EMMucSharedFile>>(
                result, channelName) {
            @Override
            public void onSuccess(List<EMMucSharedFile> object) {
                List<Map> fileList = new ArrayList<>();
                for (EMMucSharedFile file : object) {
                    fileList.add(EMMucSharedFileHelper.toJson(file));
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
        JSONArray array = param.getJSONArray("members");
        String[] members = new String[array.length()];
        for (int i = 0; i < array.length(); i++) {
            members[i] = array.getString(i);
        }

        EMClient.getInstance().groupManager().asyncInviteUser(groupId, members, reason,
                new EMWrapperCallBack(result, channelName, true));
    }

    private void addMembers(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        JSONArray array = param.getJSONArray("members");

        String[] members = new String[array.length()];
        for (int i = 0; i < array.length(); i++) {
            members[i] = array.getString(i);
        }


        EMClient.getInstance().groupManager().asyncAddUsersToGroup(groupId, members,
                new EMWrapperCallBack(result, channelName, true));
    }

    private void removeMembers(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        JSONArray array = param.getJSONArray("members");

        List<String> members = new ArrayList<>();
        for (int i = 0; i < array.length(); i++) {
            members.add(array.getString(i));
        }

        EMClient.getInstance().groupManager().asyncRemoveUsersFromGroup(groupId, members,
                new EMWrapperCallBack(result, channelName, true));
    }

    private void blockMembers(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        JSONArray array = param.getJSONArray("members");
        List<String> members = new ArrayList<>();
        for (int i = 0; i < array.length(); i++) {
            members.add(array.getString(i));
        }

        EMClient.getInstance().groupManager().asyncBlockUsers(groupId, members,
                new EMWrapperCallBack(result, channelName, true));
    }

    private void unblockMembers(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        JSONArray array = param.getJSONArray("members");
        List<String> members = new ArrayList<>();
        for (int i = 0; i < array.length(); i++) {
            members.add(array.getString(i));
        }

        EMClient.getInstance().groupManager().asyncUnblockUsers(groupId, members,
                new EMWrapperCallBack(result, channelName, true));
    }

    private void updateGroupSubject(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        String name = param.getString("name");

        EMWrapperCallBack callBack = new EMWrapperCallBack(result, channelName, null) {
            @Override
            public void onSuccess() {
                EMGroup group = EMClient.getInstance().groupManager().getGroup(groupId);
                super.object = EMGroupHelper.toJson(group);
                super.onSuccess();
            }
        };

        EMClient.getInstance().groupManager().asyncChangeGroupName(groupId, name, callBack);

    }

    private void updateDescription(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        String desc = param.getString("desc");

        EMWrapperCallBack callBack = new EMWrapperCallBack(result, channelName, null) {
            @Override
            public void onSuccess() {
                EMGroup group = EMClient.getInstance().groupManager().getGroup(groupId);
                super.object = EMGroupHelper.toJson(group);
                super.onSuccess();
            }
        };

        EMClient.getInstance().groupManager().asyncChangeGroupDescription(groupId, desc, callBack);
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

        EMWrapperCallBack callBack = new EMWrapperCallBack(result, channelName, null) {
            @Override
            public void onSuccess() {
                EMGroup group = EMClient.getInstance().groupManager().getGroup(groupId);
                super.object = EMGroupHelper.toJson(group);
                super.onSuccess();
            }
        };

        EMClient.getInstance().groupManager().asyncBlockGroupMessage(groupId, callBack);
    }

    private void unblockGroup(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");

        EMWrapperCallBack callBack = new EMWrapperCallBack(result, channelName, null) {
            @Override
            public void onSuccess() {
                EMGroup group = EMClient.getInstance().groupManager().getGroup(groupId);
                super.object = EMGroupHelper.toJson(group);
                super.onSuccess();
            }
        };

        EMClient.getInstance().groupManager().asyncUnblockGroupMessage(groupId, callBack);
    }

    private void updateGroupOwner(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        String newOwner = param.getString("owner");

        EMValueWrapperCallBack<EMGroup> callBack = new EMValueWrapperCallBack<EMGroup>(result, channelName) {
            @Override
            public void onSuccess(EMGroup object) {
                super.updateObject(EMGroupHelper.toJson(object));
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
                super.updateObject(EMGroupHelper.toJson(object));
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
                super.updateObject(EMGroupHelper.toJson(object));
            }
        };

        EMClient.getInstance().groupManager().asyncRemoveGroupAdmin(groupId, admin, callBack);
    }

    private void muteMembers(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        int duration = param.getInt("duration");
        JSONArray array = param.getJSONArray("members");
        List<String> members = new ArrayList<>();
        for (int i = 0; i < array.length(); i++) {
            members.add(array.getString(i));
        }

        EMValueWrapperCallBack<EMGroup> callBack = new EMValueWrapperCallBack<EMGroup>(result, channelName) {
            @Override
            public void onSuccess(EMGroup object) {
                super.updateObject(EMGroupHelper.toJson(object));
            }
        };

        EMClient.getInstance().groupManager().aysncMuteGroupMembers(groupId, members, duration, callBack);
    }

    private void unMuteMembers(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        JSONArray array = param.getJSONArray("members");
        List<String> members = new ArrayList<>();
        for (int i = 0; i < array.length(); i++) {
            members.add(array.getString(i));
        }

        EMValueWrapperCallBack<EMGroup> callBack = new EMValueWrapperCallBack<EMGroup>(result, channelName) {
            @Override
            public void onSuccess(EMGroup object) {
                super.updateObject(EMGroupHelper.toJson(object));
            }
        };

        EMClient.getInstance().groupManager().asyncUnMuteGroupMembers(groupId, members, callBack);
    }

    private void muteAllMembers(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");

        EMValueWrapperCallBack<EMGroup> callBack = new EMValueWrapperCallBack<EMGroup>(result, channelName) {
            @Override
            public void onSuccess(EMGroup object) {
                super.updateObject(EMGroupHelper.toJson(object));
            }
        };

        EMClient.getInstance().groupManager().muteAllMembers(groupId, callBack);
    }

    private void unMuteAllMembers(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");

        EMValueWrapperCallBack<EMGroup> callBack = new EMValueWrapperCallBack<EMGroup>(result, channelName) {
            @Override
            public void onSuccess(EMGroup object) {
                super.updateObject(EMGroupHelper.toJson(object));
            }
        };

        EMClient.getInstance().groupManager().unmuteAllMembers(groupId, callBack);
    }

    private void addWhiteList(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        JSONArray array = param.getJSONArray("members");
        List<String> members = new ArrayList<>();
        for (int i = 0; i < array.length(); i++) {
            members.add(array.getString(i));
        }

        EMClient.getInstance().groupManager().addToGroupWhiteList(groupId, members,
                new EMWrapperCallBack(result, channelName, true));
    }

    private void removeWhiteList(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        JSONArray array = param.getJSONArray("members");
        List<String> members = new ArrayList<>();
        for (int i = 0; i < array.length(); i++) {
            members.add(array.getString(i));
        }

        EMClient.getInstance().groupManager().removeFromGroupWhiteList(groupId, members,
                new EMWrapperCallBack(result, channelName, true));
    }

    private void uploadGroupSharedFile(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        String filePath = param.getString("filePath");

        EMClient.getInstance().groupManager().asyncUploadGroupSharedFile(groupId, filePath,
                new EMWrapperCallBack(result, channelName, true));
    }

    private void downloadGroupSharedFile(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        String fileId = param.getString("fileId");
        String savePath = param.getString("savePath");

        EMClient.getInstance().groupManager().asyncDownloadGroupSharedFile(groupId, fileId, savePath,
                new EMWrapperCallBack(result, channelName, true));
    }

    private void removeGroupSharedFile(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        String fileId = param.getString("fileId");
        EMClient.getInstance().groupManager().asyncDeleteGroupSharedFile(groupId, fileId,
                new EMWrapperCallBack(result, channelName, true));
    }

    private void updateGroupAnnouncement(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        String announcement = param.getString("announcement");

        EMWrapperCallBack callBack = new EMWrapperCallBack(result, channelName, null) {
            @Override
            public void onSuccess() {
                EMGroup group = EMClient.getInstance().groupManager().getGroup(groupId);
                super.object = EMGroupHelper.toJson(group);
                super.onSuccess();
            }
        };

        EMClient.getInstance().groupManager().asyncUpdateGroupAnnouncement(groupId, announcement, callBack);
    }

    private void updateGroupExt(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        String ext = param.getString("ext");

        asyncRunnable(() -> {
            try {
                EMGroup group = EMClient.getInstance().groupManager().updateGroupExtension(groupId, ext);
                onSuccess(result, channelName, EMGroupHelper.toJson(group));
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void joinPublicGroup(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");

        EMWrapperCallBack callBack = new EMWrapperCallBack(result, channelName, null) {
            @Override
            public void onSuccess() {
                EMGroup group = EMClient.getInstance().groupManager().getGroup(groupId);
                super.object = EMGroupHelper.toJson(group);
                super.onSuccess();
            }
        };

        EMClient.getInstance().groupManager().asyncJoinGroup(groupId, callBack);
    }

    private void requestToJoinPublicGroup(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");

        EMWrapperCallBack callBack = new EMWrapperCallBack(result, channelName, null) {
            @Override
            public void onSuccess() {
                EMGroup group = EMClient.getInstance().groupManager().getGroup(groupId);
                super.object = EMGroupHelper.toJson(group);
                super.onSuccess();
            }
        };

        EMClient.getInstance().groupManager().asyncJoinGroup(groupId, callBack);
    }

    private void acceptJoinApplication(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        String username = param.getString("username");

        EMWrapperCallBack callBack = new EMWrapperCallBack(result, channelName, null) {
            @Override
            public void onSuccess() {
                EMGroup group = EMClient.getInstance().groupManager().getGroup(groupId);
                super.object = EMGroupHelper.toJson(group);
                super.onSuccess();
            }
        };

        EMClient.getInstance().groupManager().asyncAcceptApplication(username, groupId, callBack);
    }

    private void declineJoinApplication(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        String username = param.getString("username");
        String reason = param.getString("reason");

        EMWrapperCallBack callBack = new EMWrapperCallBack(result, channelName, null) {
            @Override
            public void onSuccess() {
                EMGroup group = EMClient.getInstance().groupManager().getGroup(groupId);
                super.object = EMGroupHelper.toJson(group);
                super.onSuccess();
            }
        };

        EMClient.getInstance().groupManager().asyncDeclineApplication(username, groupId, reason, callBack);
    }

    private void acceptInvitationFromGroup(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        String inviter = param.getString("inviter");

        EMValueWrapperCallBack<EMGroup> callBack = new EMValueWrapperCallBack<EMGroup>(result, channelName) {
            @Override
            public void onSuccess(EMGroup object) {
                super.updateObject(EMGroupHelper.toJson(object));
            }
        };

        EMClient.getInstance().groupManager().asyncAcceptInvitation(groupId, inviter, callBack);
    }

    private void declineInvitationFromGroup(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        String username = param.getString("username");
        String reason = param.getString("reason");

        EMWrapperCallBack callBack = new EMWrapperCallBack(result, channelName, null) {
            @Override
            public void onSuccess() {
                EMGroup group = EMClient.getInstance().groupManager().getGroup(groupId);
                super.object = EMGroupHelper.toJson(group);
                super.onSuccess();
            }
        };

        EMClient.getInstance().groupManager().asyncDeclineInvitation(groupId, username, reason, callBack);
    }

    private void ignoreGroupPush(JSONObject param, String channelName, Result result) throws JSONException {
        String groupId = param.getString("groupId");
        boolean ignore = param.getBoolean("ignore");
        List<String> list = new ArrayList<>();
        list.add(groupId);

        asyncRunnable(() -> {
            try {
                EMClient.getInstance().pushManager().updatePushServiceForGroup(list, !ignore);
                EMGroup group = EMClient.getInstance().groupManager().getGroup(groupId);
                onSuccess(result, channelName, EMGroupHelper.toJson(group));
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void registerEaseListener() {
        EMClient.getInstance().groupManager().addGroupChangeListener(new EMGroupChangeListener() {

            @Override
            public void onWhiteListAdded(String groupId, List<String> whitelist) {
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onWhiteListAdded");
                data.put("groupId", groupId);
                data.put("whitelist", whitelist);
                post(() -> channel.invokeMethod(EMSDKMethod.onGroupChanged, data));
            }

            @Override
            public void onWhiteListRemoved(String groupId, List<String> whitelist) {
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onWhiteListRemoved");
                data.put("groupId", groupId);
                data.put("whitelist", whitelist);
                post(() -> channel.invokeMethod(EMSDKMethod.onGroupChanged, data));
            }

            @Override
            public void onAllMemberMuteStateChanged(String groupId, boolean isMuted) {
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onAllMemberMuteStateChanged");
                data.put("groupId", groupId);
                data.put("isMuted", isMuted);
                post(() -> channel.invokeMethod(EMSDKMethod.onGroupChanged, data));
            }

            @Override
            public void onInvitationReceived(String groupId, String groupName, String inviter, String reason) {
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onInvitationReceived");
                data.put("groupId", groupId);
                data.put("groupName", groupName);
                data.put("inviter", inviter);
                data.put("reason", reason);
                post(() -> channel.invokeMethod(EMSDKMethod.onGroupChanged, data));
            }

            @Override
            public void onRequestToJoinReceived(String groupId, String groupName, String applicant, String reason) {
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onRequestToJoinReceived");
                data.put("groupId", groupId);
                data.put("groupName", groupName);
                data.put("applicant", applicant);
                data.put("reason", reason);
                post(() -> channel.invokeMethod(EMSDKMethod.onGroupChanged, data));
            }

            @Override
            public void onRequestToJoinAccepted(String groupId, String groupName, String accepter) {
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onRequestToJoinAccepted");
                data.put("groupId", groupId);
                data.put("groupName", groupName);
                data.put("accepter", accepter);
                post(() -> channel.invokeMethod(EMSDKMethod.onGroupChanged, data));
            }

            @Override
            public void onRequestToJoinDeclined(String groupId, String groupName, String decliner, String reason) {
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onRequestToJoinDeclined");
                data.put("groupId", groupId);
                data.put("groupName", groupName);
                data.put("decliner", decliner);
                data.put("reason", reason);
                post(() -> channel.invokeMethod(EMSDKMethod.onGroupChanged, data));
            }

            @Override
            public void onInvitationAccepted(String groupId, String invitee, String reason) {
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onInvitationAccepted");
                data.put("groupId", groupId);
                data.put("invitee", invitee);
                data.put("reason", reason);
                post(() -> channel.invokeMethod(EMSDKMethod.onGroupChanged, data));
            }

            @Override
            public void onInvitationDeclined(String groupId, String invitee, String reason) {
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onInvitationDeclined");
                data.put("groupId", groupId);
                data.put("invitee", invitee);
                data.put("reason", reason);
                post(() -> channel.invokeMethod(EMSDKMethod.onGroupChanged, data));
            }

            @Override
            public void onUserRemoved(String groupId, String groupName) {
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onUserRemoved");
                data.put("groupId", groupId);
                data.put("groupName", groupName);
                post(() -> channel.invokeMethod(EMSDKMethod.onGroupChanged, data));
            }

            @Override
            public void onGroupDestroyed(String groupId, String groupName) {
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onGroupDestroyed");
                data.put("groupId", groupId);
                data.put("groupName", groupName);
                post(() -> channel.invokeMethod(EMSDKMethod.onGroupChanged, data));
            }

            @Override
            public void onAutoAcceptInvitationFromGroup(String groupId, String inviter, String inviteMessage) {
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onAutoAcceptInvitationFromGroup");
                data.put("groupId", groupId);
                data.put("inviter", inviter);
                data.put("inviteMessage", inviteMessage);
                post(() -> channel.invokeMethod(EMSDKMethod.onGroupChanged, data));
            }

            @Override
            public void onMuteListAdded(String groupId, List<String> mutes, long muteExpire) {
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onMuteListAdded");
                data.put("groupId", groupId);
                data.put("mutes", mutes);
                data.put("muteExpire", muteExpire);
                post(() -> channel.invokeMethod(EMSDKMethod.onGroupChanged, data));
            }

            @Override
            public void onMuteListRemoved(String groupId, List<String> mutes) {
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onMuteListRemoved");
                data.put("groupId", groupId);
                data.put("mutes", mutes);
                post(() -> channel.invokeMethod(EMSDKMethod.onGroupChanged, data));
            }

            @Override
            public void onAdminAdded(String groupId, String administrator) {
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onAdminAdded");
                data.put("groupId", groupId);
                data.put("administrator", administrator);
                post(() -> channel.invokeMethod(EMSDKMethod.onGroupChanged, data));
            }

            @Override
            public void onAdminRemoved(String groupId, String administrator) {
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onAdminRemoved");
                data.put("groupId", groupId);
                data.put("administrator", administrator);
                post(() -> channel.invokeMethod(EMSDKMethod.onGroupChanged, data));
            }

            @Override
            public void onOwnerChanged(String groupId, String newOwner, String oldOwner) {
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onOwnerChanged");
                data.put("groupId", groupId);
                data.put("newOwner", newOwner);
                data.put("oldOwner", oldOwner);
                post(() -> channel.invokeMethod(EMSDKMethod.onGroupChanged, data));
            }

            @Override
            public void onMemberJoined(String groupId, String member) {
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onMemberJoined");
                data.put("groupId", groupId);
                data.put("member", member);
                post(() -> channel.invokeMethod(EMSDKMethod.onGroupChanged, data));
            }

            @Override
            public void onMemberExited(String groupId, String member) {
                EMLog.e("_emGroupManagerWrapper", "onMemberExited");
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onMemberExited");
                data.put("groupId", groupId);
                data.put("member", member);
                post(() -> channel.invokeMethod(EMSDKMethod.onGroupChanged, data));
            }

            @Override
            public void onAnnouncementChanged(String groupId, String announcement) {
                EMLog.e("_emGroupManagerWrapper", "onAnnouncementChanged");
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onAnnouncementChanged");
                data.put("groupId", groupId);
                data.put("announcement", announcement);
                post(() -> channel.invokeMethod(EMSDKMethod.onGroupChanged, data));
            }

            @Override
            public void onSharedFileAdded(String groupId, EMMucSharedFile sharedFile) {
                EMLog.e("_emGroupManagerWrapper", "onSharedFileAdded");
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onSharedFileAdded");
                data.put("groupId", groupId);
                data.put("sharedFile", EMMucSharedFileHelper.toJson(sharedFile));
                post(() -> channel.invokeMethod(EMSDKMethod.onGroupChanged, data));
            }

            @Override
            public void onSharedFileDeleted(String groupId, String fileId) {
                EMLog.e("_emGroupManagerWrapper", "onSharedFileDeleted");
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onSharedFileDeleted");
                data.put("groupId", groupId);
                data.put("fileId", fileId);
                post(() -> channel.invokeMethod(EMSDKMethod.onGroupChanged, data));
            }
        });
    }
}