package com.easemob.im_flutter_test;

import android.app.Activity;
import android.content.Intent;
import android.os.Handler;
import android.os.Looper;

import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMConversation;
import com.hyphenate.chat.EMMessage;

import java.util.Collections;
import java.util.Map;
import java.util.HashMap;
import java.util.Set;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * Test-only control plane. Business APIs remain on the interface SDK channels.
 */
public final class TestControlBridge implements MethodChannel.MethodCallHandler {
    private static final String CHANNEL = "com.chat.im/test_control";

    private final Activity activity;
    private final Handler mainHandler = new Handler(Looper.getMainLooper());
    private final ExecutorService worker = Executors.newSingleThreadExecutor();
    private final MethodChannel channel;

    public TestControlBridge(Activity activity, BinaryMessenger messenger) {
        this.activity = activity;
        channel = new MethodChannel(messenger, CHANNEL);
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        Map<?, ?> arguments = call.arguments instanceof Map
                ? (Map<?, ?>) call.arguments
                : Collections.emptyMap();
        switch (call.method) {
            case "getRunnerInfo":
                result.success(runnerInfo());
                return;
            case "createUpgradeMessage":
                createUpgradeMessage(arguments, result);
                return;
            case "exportUpgradeSnapshot":
                exportUpgradeSnapshot(arguments, result);
                return;
            default:
                result.notImplemented();
        }
    }

    private void createUpgradeMessage(
            Map<?, ?> arguments,
            MethodChannel.Result result
    ) {
        final String marker = String.valueOf(arguments.get("marker"));
        final Object conversationValue = arguments.get("conversationId");
        final String conversationId = conversationValue == null
                ? "phase1-upgrade"
                : String.valueOf(conversationValue);
        worker.execute(() -> {
            EMMessage message = EMMessage.createTxtSendMessage(marker, conversationId);
            message.setMsgId(marker);
            EMConversation conversation = EMClient.getInstance()
                    .chatManager()
                    .getConversation(
                            conversationId,
                            EMConversation.EMConversationType.Chat,
                            true
                    );
            conversation.insertMessage(message);
            Map<String, Object> snapshot = new HashMap<>();
            snapshot.put("marker", marker);
            snapshot.put("conversationId", conversationId);
            snapshot.put(
                    "exists",
                    EMClient.getInstance().chatManager().getMessage(marker) != null
            );
            post(result, snapshot);
        });
    }

    private void exportUpgradeSnapshot(
            Map<?, ?> arguments,
            MethodChannel.Result result
    ) {
        final String marker = String.valueOf(arguments.get("marker"));
        worker.execute(() -> {
            EMMessage message = EMClient.getInstance().chatManager().getMessage(marker);
            Map<String, Object> snapshot = new HashMap<>();
            snapshot.put("marker", marker);
            snapshot.put("exists", message != null);
            if (message != null) {
                snapshot.put("messageId", message.getMsgId());
                snapshot.put("conversationId", message.conversationId());
                snapshot.put(
                        "body",
                        message.getBody() == null ? null : message.getBody().toString()
                );
            }
            post(result, snapshot);
        });
    }

    private Map<String, Object> runnerInfo() {
        // capabilities 由 Artifact Manifest 和 API Matrix 管理，
        // 测试 Runner 不硬编码；sdk423 使用生产 ImFlutterSdkPlugin
        // 支持全部 API。
        Map<String, Object> info = new HashMap<>();
        info.put("runnerId", intentString("runnerId", BuildConfig.FLAVOR));
        info.put("deviceName", intentString("runnerDevice", "deviceA"));
        info.put("runId", intentString("runnerRunId", ""));
        info.put("logicalDevice", intentString("runnerLogicalDevice", ""));
        info.put("artifactId", intentString("runnerArtifactId", ""));
        info.put("wrapperCommit", intentString("runnerWrapperCommit", ""));
        info.put(
                "nativeSdkSha256",
                intentString("runnerNativeSdkSha256", "")
        );
        info.put("platform", "android");
        info.put("sdkVersion", BuildConfig.CHAT_SDK_VERSION);
        info.put("appVersion", BuildConfig.VERSION_NAME);
        info.put("topic", intentString("runnerTopic", ""));
        info.put("webSocketBaseUrl", intentString("runnerWsBaseUrl", ""));
        info.put(
                "managedWebSocket",
                Boolean.parseBoolean(intentString("runnerWsManaged", "false"))
        );
        // capabilities 由 Artifact Manifest / API Matrix 管理；Runner 不上报
        // capabilities 字段，CapabilityResolver 视为"委托 Matrix"。
        return info;
    }

    private String intentString(String key, String fallback) {
        Intent intent = activity.getIntent();
        String value = intent == null ? null : intent.getStringExtra(key);
        return value == null || value.trim().isEmpty() ? fallback : value;
    }

    private void post(MethodChannel.Result result, Object value) {
        mainHandler.post(() -> result.success(value));
    }

    public void dispose() {
        channel.setMethodCallHandler(null);
        worker.shutdownNow();
    }
}
