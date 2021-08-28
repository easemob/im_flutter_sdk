
# 常见问题

### 如何开启推送






### 同时使用了其他推送是否会和环信SDK冲突？

目前已知在使用 [极光推送插件](https://github.com/jpush/jpush-flutter-plugin) 时获取DeviceToken时会出现冲突，环信提供了单独的Api供给应用来主动设置DeviceToken

```iOS
EMClient.getInstance.pushManager.updateAPNsDeviceToken("token");
```

