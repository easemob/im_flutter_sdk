package com.easemob.im_flutter_test;

import com.hyphenate.EMValueCallBack;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMCursorResult;
import com.hyphenate.chat.EMGroupMemberInfo;

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

final class SdkVersionAdapterImpl implements SdkVersionAdapter {
    private static final String FETCH_GROUP_MEMBERS_INFO = "fetchGroupMembersInfo";

    @Override
    public Set<String> capabilities() {
        return Collections.singleton("GroupManager." + FETCH_GROUP_MEMBERS_INFO);
    }

    @Override
    public boolean invokeGroup(
            String method,
            JSONObject arguments,
            NativeSdkBridge.NativeCallback callback
    ) {
        if (!FETCH_GROUP_MEMBERS_INFO.equals(method)) return false;
        final String groupId = arguments.optString("groupId");
        final String cursor = arguments.optString("cursor");
        final int limit = arguments.optInt("limit", 20);
        EMClient.getInstance().groupManager().asyncFetchGroupMembersInfo(
                groupId,
                cursor,
                limit,
                new EMValueCallBack<EMCursorResult<EMGroupMemberInfo>>() {
                    @Override
                    public void onSuccess(EMCursorResult<EMGroupMemberInfo> value) {
                        Map<String, Object> result = new HashMap<>();
                        result.put("cursor", value.getCursor());
                        List<Map<String, Object>> members = new ArrayList<>();
                        if (value.getData() != null) {
                            for (Object item : (List<?>) value.getData()) {
                                EMGroupMemberInfo info = (EMGroupMemberInfo) item;
                                Map<String, Object> member = new HashMap<>();
                                member.put("memberId", info.getMemberId());
                                member.put("joinTime", info.getJoinTime());
                                member.put(
                                        "role",
                                        info.getRole() == null ? null : info.getRole().ordinal()
                                );
                                member.put("string", info.toString());
                                members.add(member);
                            }
                        }
                        result.put("list", members);
                        callback.success(result);
                    }

                    @Override
                    public void onError(int code, String error) {
                        callback.error(code, error);
                    }
                }
        );
        return true;
    }
}
