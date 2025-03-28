import { GroupReadAck } from "@easemob/chatsdk";
export default class GroupReadAckHelper {
    static toJson(ack: GroupReadAck): Map<string, Object>;
    static listToJson(acks: GroupReadAck[]): Map<string, Object>[];
}
