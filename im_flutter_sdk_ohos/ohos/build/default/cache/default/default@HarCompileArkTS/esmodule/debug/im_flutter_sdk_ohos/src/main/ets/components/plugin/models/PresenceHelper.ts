import type { Presence } from "@normalized:N&&&@easemob/chatsdk/Index&1.5.3";
export class PresenceHelper {
    static toJson(presence: Presence): Map<string, Object> {
        const data = new Map<string, Object>();
        data.set("publisher", presence.getPublisher());
        data.set("statusDescription", presence.getExt());
        data.set("lastTime", presence.getLatestTime());
        data.set("expiryTime", presence.getExpiryTime());
        const statusList = new Map<string, number>(presence.getStatusList());
        data.set("statusDetails", statusList);
        return data;
    }
}
