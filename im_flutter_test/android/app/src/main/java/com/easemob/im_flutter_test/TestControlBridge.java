package com.easemob.im_flutter_test;

import android.app.Activity;
import android.content.Intent;
import android.os.Handler;
import android.os.Looper;

import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMConversation;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.chat.EMTextMessageBody;

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
            case "prepareDefaultMediaPath":
                prepareDefaultMediaPath(arguments, result);
                return;
            default:
                result.notImplemented();
        }
    }

    /**
     * 测试支撑：返回默认媒体素材的真实本地路径（从 assets/media 拷贝到应用文档目录）。
     * 参数 type: file/image/image_heic/video/voice；case 未传 filePath 时用它填 payload.filePath。
     */
    private void prepareDefaultMediaPath(Map<?, ?> arguments, MethodChannel.Result result) {
        final String type = String.valueOf(arguments.get("type"));
        final String assetName;
        switch (type == null ? "" : type) {
            case "image_heic":
                assetName = "imgHeic.HEIC";
                break;
            case "image":
                assetName = "bigPic.jpg";
                break;
            case "video":
                assetName = "video.mov";
                break;
            case "voice":
                assetName = "voice.mp3";
                break;
            case "file":
            default:
                assetName = "bigPic.jpg";
                break;
        }
        worker.execute(() -> {
            try {
                String dest = new java.io.File(activity.getFilesDir(), assetName).getAbsolutePath();
                java.io.File f = new java.io.File(dest);
                if (!f.exists()) {
                    java.io.InputStream in = activity.getAssets().open("flutter_assets/assets/media/" + assetName);
                    java.io.OutputStream out = new java.io.FileOutputStream(f);
                    byte[] buf = new byte[8192];
                    int n;
                    while ((n = in.read(buf)) > 0) {
                        out.write(buf, 0, n);
                    }
                    in.close();
                    out.close();
                }
                final String path = dest;
                mainHandler.post(() -> result.success(path));
            } catch (Exception e) {
                mainHandler.post(() -> result.error("prepare_default_media_path", e.toString(), null));
            }
        });
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
            // 5.0 移除 createTxtSendMessage，改用 createSendMessage + setBody
            EMMessage message = EMMessage.createSendMessage(EMMessage.Type.TXT);
            message.setBody(new EMTextMessageBody(marker));
            message.setTo(conversationId);
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
        // capabilities 由 Artifact Manifest 和 API Matrix 管理，测试 Runner 不硬编码。
        Map<String, Object> info = new HashMap<>();
        info.put("runnerId", intentString("runnerId", "main"));
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
