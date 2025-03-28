import {
  ChatClient,
  ChatError, Contact, ContactListener } from "@easemob/chatsdk";
import { FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodResult } from "@ohos/flutter_ohos";
import MethodKey from "./MethodKeys";
import Wrapper from "./Wrapper";
import ContactHelper from "./models/ContactHelper";
import CursorResultHelper from "./models/CursorResultHelper";

export default class ContactManagerWrapper extends Wrapper implements MethodCallHandler {
  private listener: ContactListener | null = null;

  constructor(binding: FlutterPluginBinding, channelName: string) {
    super(binding, channelName);
  }

  registerEaseListener() {
    this.unRegisterEaseListener();
    let weakRef = new WeakRef(this);
    this.listener = {
      onContactAdded(userId) {
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onContactAdded");
        data.set("username", userId);
        retrievedObject?.channel?.invokeMethod(MethodKey.onContactChanged, data);
      },
      onContactDeleted(userId) {
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onContactDeleted");
        data.set("username", userId);
        retrievedObject?.channel?.invokeMethod(MethodKey.onContactChanged, data);
      },
      onContactInvited(userId, reason) {
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onContactInvited");
        data.set("username", userId);
        data.set("reason", reason);
        retrievedObject?.channel?.invokeMethod(MethodKey.onContactChanged, data);
      },
      onFriendRequestAccepted(userId) {
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onFriendRequestAccepted");
        data.set("username", userId);
        retrievedObject?.channel?.invokeMethod(MethodKey.onContactChanged, data);
      },
      onFriendRequestDeclined(userId) {
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onFriendRequestDeclined");
        data.set("username", userId);
        retrievedObject?.channel?.invokeMethod(MethodKey.onContactChanged, data);
      }
    };

    ChatClient.getInstance().contactManager()?.addContactListener(this.listener);
  }

  public unRegisterEaseListener(): void {
    if(this.listener != null) {
      ChatClient.getInstance().contactManager()?.removeContactListener(this.listener);
    }
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (MethodKey.addContact == call.method) {
      this.addContact(call, result);
    } else if (MethodKey.deleteContact == call.method) {
      this.deleteContact(call, result);
    } else if (MethodKey.getAllContactsFromServer == call.method) {
      this.getAllContactsFromServer(call, result);
    } else if (MethodKey.getAllContactsFromDB == call.method) {
      this.getAllContactsFromDB(call, result);
    } else if (MethodKey.addUserToBlockList == call.method) {
      this.addUserToBlockList(call, result);
    } else if (MethodKey.removeUserFromBlockList == call.method) {
      this.removeUserFromBlockList(call, result);
    } else if (MethodKey.getBlockListFromServer == call.method) {
      this.getBlockListFromServer(call, result);
    } else if (MethodKey.getBlockListFromDB == call.method) {
      this.getBlockListFromDB(call, result);
    } else if (MethodKey.acceptInvitation == call.method) {
      this.acceptInvitation(call, result);
    } else if (MethodKey.declineInvitation == call.method) {
      this.declineInvitation(call, result);
    } else if (MethodKey.getSelfIdsOnOtherPlatform == call.method) {
      this.getSelfIdsOnOtherPlatform(call, result);
    }else if (MethodKey.getAllContacts == call.method) {
      this.getAllContacts(call, result);
    }else if (MethodKey.setContactRemark == call.method) {
      this.setContactRemark(call, result);
    }else if (MethodKey.getContact == call.method) {
      this.getContact(call, result);
    }else if (MethodKey.fetchAllContacts == call.method) {
      this.fetchAllContacts(call, result);
    }else if (MethodKey.fetchContacts == call.method) {
      this.fetchContacts(call, result);
    } else {
      super.onMethodCall(call, result);
    }
  }

  private addContact(call: MethodCall, result: MethodResult) {
    let userId = call.argument("username") as string;
    let reason: string | null = null;
    if(call.hasArgument("reason")) {
      reason = call.argument("reason");
    }
    ChatClient.getInstance().contactManager()?.addContact(userId, reason)
      .then(() => this.onSuccess(result, call.method))
      .catch((e: ChatError) => this.onError(result, e));
  }

  private deleteContact(call: MethodCall, result: MethodResult) {
    let userId = call.argument("username") as string;
    let keepConversation = call.argument("keepConversation") as boolean;
    ChatClient.getInstance().contactManager()?.deleteContact(userId, keepConversation)
      .then(() => this.onSuccess(result, call.method))
      .catch((e: ChatError) => this.onError(result, e));
  }

  private getAllContactsFromServer(call: MethodCall, result: MethodResult) {
    ChatClient.getInstance().contactManager()?.fetchAllContactsIDFromServer()
      .then(value=>this.onSuccess(result, call.method, value))
      .catch((e: ChatError) => this.onError(result, e));

  }

  private getAllContactsFromDB(call: MethodCall, result: MethodResult) {
    ChatClient.getInstance().contactManager()?.allContacts()
      .then(value=>this.onSuccess(result, call.method, value))
      .catch((e: ChatError) => this.onError(result, e));
  }

  private addUserToBlockList(call: MethodCall, result: MethodResult) {
    let userId = call.argument("username") as string;
    ChatClient.getInstance().contactManager()?.addUsersToBlocklist([userId])
      .then(() => this.onSuccess(result, call.method))
      .catch((e: ChatError) => this.onError(result, e));
  }

  private removeUserFromBlockList(call: MethodCall, result: MethodResult) {
    let userId = call.argument("username") as string;
    ChatClient.getInstance().contactManager()?.removeUserFromBlockList(userId)
      .then(() => this.onSuccess(result, call.method))
      .catch((e: ChatError) => this.onError(result, e));
  }

  private getBlockListFromServer(call: MethodCall, result: MethodResult) {
    ChatClient.getInstance().contactManager()?.getBlockListFromServer()
      .then(value=>this.onSuccess(result, call.method, value))
      .catch((e: ChatError) => this.onError(result, e));
  }

  private getBlockListFromDB(call: MethodCall, result: MethodResult) {
    ChatClient.getInstance().contactManager()?.blockList()
      .then(value=>this.onSuccess(result, call.method, value))
      .catch((e: ChatError) => this.onError(result, e));
  }

  private acceptInvitation(call: MethodCall, result: MethodResult) {
    let userId = call.argument("username") as string;
    ChatClient.getInstance().contactManager()?.acceptInvitation(userId)
      .then(()=>this.onSuccess(result, call.method))
      .catch((e: ChatError) => this.onError(result, e));
  }

  private declineInvitation(call: MethodCall, result: MethodResult) {
    let userId = call.argument("username") as string;
    ChatClient.getInstance().contactManager()?.declineInvitation(userId)
      .then(()=>this.onSuccess(result, call.method))
      .catch((e: ChatError) => this.onError(result, e));
  }

  private getSelfIdsOnOtherPlatform(call: MethodCall, result: MethodResult) {
    ChatClient.getInstance().contactManager()?.getSelfIdsOnOtherPlatform()
      .then((value)=>this.onSuccess(result, call.method, value))
      .catch((e: ChatError) => this.onError(result, e));
  }

  private getAllContacts(call: MethodCall, result: MethodResult) {
    ChatClient.getInstance().contactManager()?.getContactsFromLocal()
      .then((value)=>this.onSuccess(result, call.method, ContactHelper.listToJson(value)))
      .catch((e: ChatError) => this.onError(result, e));
  }

  private setContactRemark(call: MethodCall, result: MethodResult) {
    let userId = call.argument("userId") as string;
    let remark = call.argument("remark") as string;
    ChatClient.getInstance().contactManager()?.setContactRemark(userId, remark)
      .then(()=>this.onSuccess(result, call.method))
      .catch((e: ChatError) => this.onError(result, e));
  }

  private getContact(call: MethodCall, result: MethodResult) {
    let userId = call.argument("userId") as string;
    ChatClient.getInstance().contactManager()?.getContact(userId)
      .then((value)=> {
        if(value != undefined) {
          this.onSuccess(result, call.method, ContactHelper.toJson(value));
        }else {
          this.onSuccess(result, call.method);
        }
      })
      .catch((e: ChatError) => this.onError(result, e));
  }

  private fetchAllContacts(call: MethodCall, result: MethodResult) {
    ChatClient.getInstance().contactManager()?.fetchAllContactsFromServer()
      .then((value)=>this.onSuccess(result, call.method, ContactHelper.listToJson(value)))
      .catch((e: ChatError) => this.onError(result, e));
  }

  private fetchContacts(call: MethodCall, result: MethodResult) {
    let pageSize = call.argument("pageSize") as number;
    let cursor: string | null = null;
    if(call.hasArgument("cursor")) {
        cursor = call.argument("cursor");
    }
    ChatClient.getInstance().contactManager()?.fetchAllContactsFromServerByPage(pageSize, cursor)
      .then((value)=>this.onSuccess(result, call.method, CursorResultHelper.toJson(value)))
      .catch((e: ChatError) => this.onError(result, e));
  }

}