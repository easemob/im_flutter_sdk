import { UserInfo } from "@normalized:N&&&@easemob/chatsdk/Index&1.5.3";
export class UserInfoHelper {
    static toJson(userInfo: UserInfo): Map<string, Object> {
        const data = new Map<string, Object>();
        data.set("userId", userInfo.userId ?? '');
        if (userInfo.nickname) {
            data.set("nickName", userInfo.nickname);
        }
        if (userInfo.avatarUrl) {
            data.set("avatarUrl", userInfo.avatarUrl);
        }
        if (userInfo.email) {
            data.set("mail", userInfo.email);
        }
        if (userInfo.phone) {
            data.set("phone", userInfo.phone);
        }
        if (userInfo.gender) {
            data.set("gender", userInfo.gender);
        }
        if (userInfo.signature) {
            data.set("sign", userInfo.signature);
        }
        if (userInfo.birth) {
            data.set("birth", userInfo.birth);
        }
        if (userInfo.ext) {
            data.set("ext", userInfo.ext);
        }
        return data;
    }
    static fromJson(json: Map<string, Object>): UserInfo {
        const userInfo = new UserInfo();
        userInfo.userId = json.get("userId") as string;
        userInfo.nickname = json.get("nickName") as string;
        userInfo.avatarUrl = json.get("avatarUrl") as string;
        userInfo.email = json.get("mail") as string;
        userInfo.phone = json.get("phone") as string;
        userInfo.gender = json.get("gender") as number;
        userInfo.signature = json.get("sign") as string;
        userInfo.birth = json.get("birth") as string;
        userInfo.ext = json.get("ext") as string;
        return userInfo;
    }
}
