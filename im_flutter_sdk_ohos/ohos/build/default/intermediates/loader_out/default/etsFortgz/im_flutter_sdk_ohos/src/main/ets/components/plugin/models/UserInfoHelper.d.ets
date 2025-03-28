import { UserInfo } from "@easemob/chatsdk";
export declare class UserInfoHelper {
    static toJson(userInfo: UserInfo): Map<string, Object>;
    static fromJson(json: Map<string, Object>): UserInfo;
}
