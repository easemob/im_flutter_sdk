import type { Contact } from "@normalized:N&&&@easemob/chatsdk/Index&1.5.3";
import { SafetyValue } from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/SafetyMapTool&1.0.0";
export default class ContactHelper {
    static toJson(contact: Contact): Map<string, Object> {
        let ret = new Map<string, Object>();
        SafetyValue(contact.userId(), (value) => ret.set("userId", value));
        SafetyValue(contact.remark(), (value) => ret.set("remark", value));
        return ret;
    }
    static listToJson(contacts: Contact[]): Map<string, Object>[] {
        let list = new Array<Map<string, Object>>();
        for (let index = 0; index < contacts.length; index++) {
            const contact = contacts[index];
            list.push(ContactHelper.toJson(contact));
        }
        return list;
    }
}
