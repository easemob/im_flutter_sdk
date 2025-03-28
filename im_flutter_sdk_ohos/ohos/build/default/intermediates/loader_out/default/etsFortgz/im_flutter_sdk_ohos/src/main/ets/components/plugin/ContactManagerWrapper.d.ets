import { FlutterPluginBinding, MethodCall, MethodCallHandler, MethodResult } from "@ohos/flutter_ohos";
import Wrapper from "./Wrapper";
export default class ContactManagerWrapper extends Wrapper implements MethodCallHandler {
    private listener;
    constructor(binding: FlutterPluginBinding, channelName: string);
    registerEaseListener(): void;
    unRegisterEaseListener(): void;
    onMethodCall(call: MethodCall, result: MethodResult): void;
    private addContact;
    private deleteContact;
    private getAllContactsFromServer;
    private getAllContactsFromDB;
    private addUserToBlockList;
    private removeUserFromBlockList;
    private getBlockListFromServer;
    private getBlockListFromDB;
    private acceptInvitation;
    private declineInvitation;
    private getSelfIdsOnOtherPlatform;
    private getAllContacts;
    private setContactRemark;
    private getContact;
    private fetchAllContacts;
    private fetchContacts;
}
