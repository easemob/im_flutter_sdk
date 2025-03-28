import { Contact } from "@easemob/chatsdk";
export default class ContactHelper {
    static toJson(contact: Contact): Map<string, Object>;
    static listToJson(contacts: Contact[]): Map<string, Object>[];
}
