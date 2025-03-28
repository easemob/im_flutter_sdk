import { ChatClient, ChatError } from "@normalized:N&&&@easemob/chatsdk/Index&1.5.3";
import type { UserInfo } from "@normalized:N&&&@easemob/chatsdk/Index&1.5.3";
import type { FlutterPluginBinding, MethodCallHandler, MethodCall, MethodResult } from "@normalized:N&&&@ohos/flutter_ohos/index&1.0.0-0e6b4521d4";
import Wrapper from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/Wrapper&1.0.0";
import MethodKey from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/MethodKeys&1.0.0";
import { UserInfoHelper } from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/models/UserInfoHelper&1.0.0";
export default class UserInfoManagerWrapper extends Wrapper implements MethodCallHandler {
    constructor(binding: FlutterPluginBinding, channelName: string) {
        super(binding, channelName);
    }
    onMethodCall(call: MethodCall, result: MethodResult): void {
        if (MethodKey.updateOwnUserInfo === call.method) {
            this.updateOwnUserInfo(call, result);
        }
        else if (MethodKey.fetchUserInfoById === call.method) {
            this.fetchUserInfoByUserId(call, result);
        }
        else {
            super.onMethodCall(call, result);
        }
    }
    private updateOwnUserInfo(call: MethodCall, result: MethodResult) {
        const userInfo = UserInfoHelper.fromJson(call.args);
        const username = ChatClient.getInstance().getCurrentUser();
        if (!username) {
            this.onError(result, new ChatError(ChatError.USER_NOT_LOGIN, "User not login"));
            return;
        }
        userInfo.userId = username;
        ChatClient.getInstance().userInfoManager()?.updateUserInfo(userInfo)
            .then((userInfo) => this.onSuccess(result, call.method, UserInfoHelper.toJson(userInfo)))
            .catch((e: ChatError) => this.onError(result, e));
    }
    private fetchUserInfoByUserId(call: MethodCall, result: MethodResult) {
        const userIds = call.argument('userIds') as string[];
        ChatClient.getInstance().userInfoManager()?.fetchUserInfoById(userIds)
            .then((object: Map<string, UserInfo>) => {
            const rMap = this.generateMapFromMap(object);
            this.onSuccess(result, call.method, rMap);
        })
            .catch((e: ChatError) => this.onError(result, e));
    }
    private generateMapFromMap(aMap: Map<string, UserInfo>): Map<string, Map<string, Object>> {
        const resultMap = new Map<string, Map<string, Object>>();
        aMap.forEach((value, key) => {
            resultMap.set(key, UserInfoHelper.toJson(value));
        });
        return resultMap;
    }
}
