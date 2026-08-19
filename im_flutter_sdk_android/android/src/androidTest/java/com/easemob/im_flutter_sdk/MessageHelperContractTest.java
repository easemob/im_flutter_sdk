package com.easemob.im_flutter_sdk;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import android.content.Context;

import androidx.test.core.app.ApplicationProvider;
import androidx.test.ext.junit.runners.AndroidJUnit4;

import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.chat.EMOptions;
import com.hyphenate.chat.EMTextMessageBody;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;

import java.util.Arrays;
import java.util.Map;

@RunWith(AndroidJUnit4.class)
public class MessageHelperContractTest {

    @BeforeClass
    public static void initializeNativeSdk() {
        Context context = ApplicationProvider.getApplicationContext();
        EMOptions options = new EMOptions();
        options.setAppKey("contract#test");
        EMClient.getInstance().init(context, options);
    }

    @Test
    public void fromJsonPreservesObservableSendSemantics() throws JSONException {
        EMMessage message = MessageHelper.fromJson(textMessageFixture());

        assertEquals(EMMessage.Type.TXT, message.getType());
        assertEquals(EMMessage.Direct.SEND, message.direct());
        assertEquals(EMMessage.ChatType.ChatRoom, message.getChatType());
        assertEquals(EMMessage.Status.INPROGRESS, message.status());
        assertEquals("alice", message.getFrom());
        assertEquals("room-001", message.getTo());
        assertEquals("room-001", message.conversationId());
        assertEquals(1700000000000L, message.localTime());
        assertTrue(message.isDeliverOnlineOnly());
        assertEquals(Arrays.asList("bob", "carol"), message.receiverList());

        EMTextMessageBody body = (EMTextMessageBody) message.getBody();
        assertEquals("hello", body.getMessage());
        assertEquals(Arrays.asList("zh-Hans", "en"), body.getTargetLanguages());

        Map<String, Object> attributes = message.getAttributes();
        assertEquals("trace-001", attributes.get("trace"));
        assertEquals(2, attributes.get("retry"));
        assertEquals(true, attributes.get("silent"));
        assertTrue(attributes.get("meta") instanceof JSONObject);
        assertTrue(attributes.get("tags") instanceof JSONArray);
    }

    @Test
    public void fromJsonPreservesDoubleAttributeType() throws JSONException {
        EMMessage message = MessageHelper.fromJson(textMessageFixture());

        Object score = message.getAttributes().get("score");
        assertTrue("score must remain a Double but was " + score.getClass(),
                score instanceof Double);
        assertEquals(1.5d, (Double) score, 0.0d);
    }

    @Test
    public void toJsonPreservesStructuredAttributeTypes() throws JSONException {
        EMMessage message = MessageHelper.fromJson(textMessageFixture());

        Map<String, Object> output = MessageHelper.toJson(message);
        Map<?, ?> attributes = (Map<?, ?>) output.get("attributes");
        assertTrue("meta must remain structured", attributes.get("meta") instanceof JSONObject);
        assertTrue("tags must remain structured", attributes.get("tags") instanceof JSONArray);
    }

    @Test
    public void toJsonPreservesTargetingFields() throws JSONException {
        EMMessage message = MessageHelper.fromJson(textMessageFixture());

        Map<String, Object> output = MessageHelper.toJson(message);
        assertEquals(true, output.get("deliverOnlineOnly"));
        assertEquals(Arrays.asList("bob", "carol"), output.get("receiverList"));
    }

    private static JSONObject textMessageFixture() throws JSONException {
        JSONObject body = new JSONObject()
                .put("type", 0)
                .put("content", "hello")
                .put("targetLanguages", new JSONArray(Arrays.asList("zh-Hans", "en")));

        JSONObject attributes = new JSONObject()
                .put("trace", "trace-001")
                .put("retry", 2)
                .put("silent", true)
                .put("score", 1.5d)
                .put("meta", new JSONObject()
                        .put("source", "contract-test")
                        .put("level", 3))
                .put("tags", new JSONArray(Arrays.asList("a", "b")));

        return new JSONObject()
                .put("from", "alice")
                .put("to", "room-001")
                .put("body", body)
                .put("attributes", attributes)
                .put("direction", 0)
                .put("hasRead", true)
                .put("hasReadAck", false)
                .put("hasDeliverAck", false)
                .put("needGroupAck", false)
                .put("msgId", "local-001")
                .put("convId", "room-001")
                .put("chatType", 2)
                .put("localTime", 1700000000000L)
                .put("serverTime", 0L)
                .put("status", 1)
                .put("isThread", false)
                .put("isContentReplaced", false)
                .put("chatroomMessagePriority", 0)
                .put("deliverOnlineOnly", true)
                .put("receiverList", new JSONArray(Arrays.asList("bob", "carol")));
    }
}
