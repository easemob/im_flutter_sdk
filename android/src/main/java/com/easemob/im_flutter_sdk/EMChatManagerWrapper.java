package com.easemob.im_flutter_sdk;

import com.hyphenate.EMMessageListener;
import com.hyphenate.chat.EMChatManager;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMConversation;
import com.hyphenate.chat.EMCursorResult;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.exceptions.HyphenateException;

import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;

@SuppressWarnings("unchecked")

public class EMChatManagerWrapper implements MethodCallHandler, EMWrapper{
    // delegates all methods call to this manager
    private EMChatManager manager;
    // method channel for event broadcast back to flutter
    private MethodChannel channel;
    // cursor result map for call back getCursor()
    private Map<String, EMCursorResult<EMMessage>> cursorResultList = new HashMap<String, EMCursorResult<EMMessage>>();

    EMChatManagerWrapper(MethodChannel channel) {
        this.channel = channel;
    }

    private void init() {
        //setup message listener
        manager.addMessageListener(new EMMessageListener() {
            @Override
            public void onMessageReceived(List<EMMessage> messages) {
                Map<String, Object> data = new HashMap<String, Object>();
                List<Map<String, Object>> msgs = new LinkedList<Map<String, Object>>();
                for(EMMessage message : messages) {
                    msgs.add(EMHelper.convertEMMessageToStringMap(message));
                }
                data.put("messages", msgs);
                post((Void)->{
                    channel.invokeMethod(EMSDKMethod.onMessageReceived, data);
                });
            }

            @Override
            public void onCmdMessageReceived(List<EMMessage> messages) {
                Map<String, Object> data = new HashMap<String, Object>();
                List<Map<String, Object>> msgs = new LinkedList<Map<String, Object>>();
                for(EMMessage message : messages) {
                    msgs.add(EMHelper.convertEMMessageToStringMap(message));
                }
                data.put("messages", msgs);
                post((Void)->{
                    channel.invokeMethod(EMSDKMethod.onCmdMessageReceived, data);
                });
            }

            @Override
            public void onMessageRead(List<EMMessage> messages) {
                Map<String, Object> data = new HashMap<String, Object>();
                List<Map<String, Object>> msgs = new LinkedList<Map<String, Object>>();
                for(EMMessage message : messages) {
                    msgs.add(EMHelper.convertEMMessageToStringMap(message));
                }
                data.put("messages", msgs);
                post((Void)->{
                    channel.invokeMethod(EMSDKMethod.onMessageRead, data);
                });
            }

            @Override
            public void onMessageDelivered(List<EMMessage> messages) {
                Map<String, Object> data = new HashMap<String, Object>();
                List<Map<String, Object>> msgs = new LinkedList<Map<String, Object>>();
                for(EMMessage message : messages) {
                    msgs.add(EMHelper.convertEMMessageToStringMap(message));
                }
                data.put("messages", msgs);
                post((Void)->{
                    channel.invokeMethod(EMSDKMethod.onMessageDelivered, data);
                });
            }

            @Override
            public void onMessageRecalled(List<EMMessage> messages) {
                Map<String, Object> data = new HashMap<String, Object>();
                List<Map<String, Object>> msgs = new LinkedList<Map<String, Object>>();
                for(EMMessage message : messages) {
                    msgs.add(EMHelper.convertEMMessageToStringMap(message));
                }
                data.put("messages", msgs);
                post((Void)->{
                    channel.invokeMethod(EMSDKMethod.onMessageRecalled, data);
                });
            }

            @Override
            public void onMessageChanged(EMMessage message, Object change) {
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("message", EMHelper.convertEMMessageToStringMap(message));
                data.put("change", change);
                post((Void)->{
                    channel.invokeMethod(EMSDKMethod.onMessageChanged, data);
                });

            }
        });
        //setup conversation listener
        manager.addConversationListener(() -> {
            Map<String, Object> data = new HashMap<String, Object>();
            post((Void)->{
                channel.invokeMethod(EMSDKMethod.onConversationUpdate,data);
            });
        });
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if(manager == null) {
            manager = EMClient.getInstance().chatManager();
            init();
        }
        if (EMSDKMethod.sendMessage.equals(call.method)) {
            sendMessage(call.arguments, result);
        } else if (EMSDKMethod.ackMessageRead.equals(call.method)) {
            ackMessageRead(call.arguments, result);
        } else if (EMSDKMethod.recallMessage.equals(call.method)) {
            recallMessage(call.arguments, result);
        } else if (EMSDKMethod.getMessage.equals(call.method)) {
            getMessage(call.arguments, result);
        }else if(EMSDKMethod.getConversation.equals(call.method)) {
            getConversation(call.arguments, result);
        }else if(EMSDKMethod.markAllChatMsgAsRead.equals(call.method)) {
            markAllMessagesAsRead(call.arguments, result);
        }else if(EMSDKMethod.getUnreadMessageCount.equals(call.method)) {
            getUnreadMessageCount(call.arguments,result);
        }else if(EMSDKMethod.saveMessage.equals(call.method)) {
            saveMessage(call.arguments, result);
        }else if(EMSDKMethod.updateChatMessage.equals(call.method)) {
            updateMessage(call.arguments, result);
        }else if(EMSDKMethod.downloadAttachment.equals(call.method)) {
            downloadAttachment(call.arguments, result);
        }else if(EMSDKMethod.downloadThumbnail.equals(call.method)) {
            downloadThumbnail(call.arguments, result);
        }else if(EMSDKMethod.importMessages.equals(call.method)) {
            importMessages(call.arguments, result);
        }else if(EMSDKMethod.getConversationsByType.equals(call.method)) {
            getConversationsByType(call.arguments, result);
        }else if(EMSDKMethod.downloadFile.equals(call.method)) {
            downloadFile(call.arguments, result);
        }else if(EMSDKMethod.getAllConversations.equals(call.method)) {
            getAllConversations(call.arguments, result);
        }else if(EMSDKMethod.loadAllConversations.equals(call.method)) {
            loadAllConversations(call.arguments, result);
        }else if(EMSDKMethod.deleteConversation.equals(call.method)) {
            deleteConversation(call.arguments, result);
        }else if(EMSDKMethod.setMessageListened.equals(call.method)) {
            setMessageListened(call.arguments, result);
        }else if(EMSDKMethod.setVoiceMessageListened.equals(call.method)) {
            setVoiceMessageListened(call.arguments, result);
        }else if(EMSDKMethod.updateParticipant.equals(call.method)) {
            updateParticipant(call.arguments, result);
        }else if(EMSDKMethod.fetchHistoryMessages.equals(call.method)) {
            fetchHistoryMessages(call.arguments, result);
        }else if(EMSDKMethod.searchChatMsgFromDB.equals(call.method)) {
            searchMsgFromDB(call.arguments, result);
        }else if(EMSDKMethod.getCursor.equals(call.method)) {
            getCursor(call.arguments, result);
        }

    }

    private void sendMessage(Object args, Result result) {
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        EMMessage message = EMHelper.convertDataMapToMessage(argMap);
        manager.sendMessage(message);
    }

    private void ackMessageRead(Object args, Result result) {
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        String to = (String)argMap.get("to");
        String messageId= (String)argMap.get("id");
        try{
            manager.ackMessageRead(to, messageId);
            onSuccess(result);
        }catch(HyphenateException e) {
            onError(result, e);
        }
    }

    private void recallMessage(Object args, Result result) {
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        EMMessage message = EMHelper.convertDataMapToMessage(argMap);
        try{
            manager.recallMessage(message);
            onSuccess(result);
        }catch(HyphenateException e) {
            onError(result, e);
        }
    }

    private void getMessage(Object args, Result result) {
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        String messageId = (String)argMap.get("id");
        EMMessage message = manager.getMessage(messageId);
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.TRUE);
        data.put("message", EMHelper.convertEMMessageToStringMap(message));
        result.success(data);
    }

    private void getConversation(Object args, Result result) {
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        String conversationId = (String)argMap.get("id");
        EMConversation.EMConversationType type = (EMConversation.EMConversationType) argMap.get("type");
        Boolean createIfNotExists = (Boolean)argMap.get("createIfNotExists");
        EMConversation conversation = manager.getConversation(conversationId, type, createIfNotExists);
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.TRUE);
        data.put("conversation", EMHelper.convertEMConversationToStringMap(conversation));
        result.success(data);
    }

    private void markAllMessagesAsRead(Object args, Result result) {
        assert(args instanceof Map);
        manager.markAllConversationsAsRead();
    }

    private void getUnreadMessageCount(Object args, Result result) {
        assert(args instanceof Map);
        int count = manager.getUnreadMessageCount();
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.TRUE);
        data.put("count", count);
        result.success(data);
    }

    private void saveMessage(Object args, Result result) {
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        EMMessage message = EMHelper.convertDataMapToMessage(argMap);
        manager.saveMessage(message);
    }

    private void updateMessage(Object args, Result result) {
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        EMMessage message = EMHelper.convertDataMapToMessage(argMap);
        boolean status = manager.updateMessage(message);
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.TRUE);
        data.put("status", Boolean.valueOf(status));
        result.success(data);
    }

    private void downloadAttachment(Object args, Result result) {
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        EMMessage message = EMHelper.convertDataMapToMessage(argMap);
        manager.downloadAttachment(message);
    }

    private void downloadThumbnail(Object args, Result result) {
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        EMMessage message = EMHelper.convertDataMapToMessage(argMap);
        manager.downloadThumbnail(message);
    }

    private void importMessages(Object args, Result result) {
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        List<Map<String, Object>> list = (List<Map<String, Object>>)argMap.get("messages");
        List<EMMessage> messages = new LinkedList<EMMessage>();
        for(Map<String, Object> message : list) {
            messages.add(EMHelper.convertDataMapToMessage(message));
        }
        manager.importMessages(messages);
    }

    private void getConversationsByType(Object args, Result result) {
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        EMConversation.EMConversationType type = (EMConversation.EMConversationType)argMap.get("type");
        List<EMConversation> list = manager.getConversationsByType(type);
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.TRUE);
        List<Map<String, Object>> conversations = new LinkedList<Map<String, Object>>();
        for(EMConversation conversation : list) {
            conversations.add(EMHelper.convertEMConversationToStringMap(conversation));
        }
        data.put("conversations",conversations);
        result.success(data);
    }

    private void downloadFile(Object args, Result result) {
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        String remoteUrl = (String)argMap.get("remoteUrl");
        String localFilePath = (String)argMap.get("localFilePath");
        Map<String, String> headers = (Map<String, String>)argMap.get("headers");
        manager.downloadFile(remoteUrl,localFilePath,headers,new EMWrapperCallBack(result));
    }

    private void getAllConversations(Object args, Result result) {
        assert(args instanceof Map);
        Map<String, EMConversation> list = manager.getAllConversations();
        List<Map<String, Object>> conversations = new LinkedList<Map<String, Object>>();
        list.forEach((String id, EMConversation conversation)->{
            conversations.add(EMHelper.convertEMConversationToStringMap(conversation));
        });
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.TRUE);
        data.put("conversations", conversations);
        result.success(data);
    }

    private void loadAllConversations(Object args, Result result) {
        assert(args instanceof Map);
        manager.loadAllConversations();
    }

    private void deleteConversation(Object args, Result result) {
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        String userName = (String)argMap.get("userName");
        Boolean deleteMessages = (Boolean)argMap.get("deleteMessages");
        boolean status = manager.deleteConversation(userName,deleteMessages.booleanValue());
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.TRUE);
        data.put("status", status);
        result.success(data);
    }

    private void setMessageListened(Object args, Result result) {
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        EMMessage message = EMHelper.convertDataMapToMessage(argMap);
        manager.setMessageListened(message);
    }

    private void setVoiceMessageListened(Object args, Result result) {
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        EMMessage message = EMHelper.convertDataMapToMessage(argMap);
        manager.setVoiceMessageListened(message);
    }

    private void updateParticipant(Object args, Result result) {
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        String from = (String)argMap.get("from");
        String changeTo = (String)argMap.get("changeTo");
        manager.updateParticipant(from, changeTo);
    }

    private void fetchHistoryMessages(Object args, Result result) {
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        String conversationId = (String)argMap.get("id");
        EMConversation.EMConversationType type = (EMConversation.EMConversationType)argMap.get("type");
        Integer pageSize = (Integer)argMap.get("pageSize");
        String startMsgId = (String)argMap.get("startMsgId");
        try{
            EMCursorResult<EMMessage> cursorResult = manager.fetchHistoryMessages(conversationId, type, pageSize.intValue(), startMsgId);
            Map<String, Object> data = new HashMap<String, Object>();
            data.put("success", Boolean.TRUE);
            String cursorId = UUID.randomUUID().toString();
            cursorResultList.put(cursorId, cursorResult);
            data.put("cursorId", cursorId);
            result.success(data);
        }catch (HyphenateException e) {
            onError(result, e);
        }
    }

    private void getCursor(Object args, Result result) {
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;

    }

    private void searchMsgFromDB(Object args, Result result) {
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        String keywords = (String)argMap.get("keywords");
        EMConversation.EMConversationType type = (EMConversation.EMConversationType) argMap.get("type");
        Integer timeStamp = (Integer)argMap.get("timeStamp");
        Integer maxCount = (Integer)argMap.get("maxCount");
        String from = (String)argMap.get("from");
        EMConversation.EMSearchDirection direction = (EMConversation.EMSearchDirection) argMap.get("direction");
        List<EMMessage> list = manager.searchMsgFromDB(keywords, timeStamp, maxCount, from, direction);
        List<Map<String, Object>> messages = new LinkedList<Map<String, Object>>();
        list.forEach((message)->{
            messages.add(EMHelper.convertEMMessageToStringMap(message));
        });
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.TRUE);
        data.put("messages", messages);
        result.success(data);
    }
}

