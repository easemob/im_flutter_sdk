package com.easemob.im_flutter_sdk;
import com.hyphenate.chat.EMMessage;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import java.util.Map;
public class HelpTool {
    public static void mergeMessage(EMMessage msg, EMMessage dbMsg) throws JSONException {
        dbMsg.setMsgTime(msg.getMsgTime());
        dbMsg.setLocalTime(msg.localTime());
        dbMsg.setStatus(msg.status());
        dbMsg.setAcked(msg.isAcked());
        dbMsg.setIsChatThreadMessage(msg.isChatThreadMessage());
        dbMsg.setIsNeedGroupAck(msg.isNeedGroupAck());
        dbMsg.setDeliverAcked(msg.isDelivered());
        dbMsg.setUnread(msg.isUnread());
        dbMsg.setListened(msg.isListened());
        dbMsg.setReceiverList(msg.receiverList());
        dbMsg.deliverOnlineOnly(msg.isDeliverOnlineOnly());
        Map<String, Object> list = msg.getAttributes();
        if (!list.isEmpty()) {
            JSONObject jsonParams = new JSONObject(list);
            for (Map.Entry<String, Object> entry : list.entrySet()) {
                String key = entry.getKey();
                Object result = entry.getValue();
                if (result.getClass().getSimpleName().equals("Integer")) {
                    dbMsg.setAttribute(key, (Integer)result);
                } else if (result.getClass().getSimpleName().equals("Boolean")) {
                    dbMsg.setAttribute(key, (Boolean)result);
                } else if (result.getClass().getSimpleName().equals("Long")) {
                    dbMsg.setAttribute(key, (Long)result);
                } else if (result.getClass().getSimpleName().equals("Double") ||
                        result.getClass().getSimpleName().equals("Float")) {
                    dbMsg.setAttribute(key, (Double)result);
                } else if (result.getClass().getSimpleName().equals("JSONObject")) {
                    dbMsg.setAttribute(key, (JSONObject)result);
                } else if (result.getClass().getSimpleName().equals("JSONArray")) {
                    dbMsg.setAttribute(key, (JSONArray)result);
                } else {
                    dbMsg.setAttribute(key, jsonParams.getString(key));
                }
            }
        }
        dbMsg.setBody(msg.getBody());
    }
}