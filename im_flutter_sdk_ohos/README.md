# 鸿蒙 im_flutter_sdk 快速入门

当前工程支持了`ios`，`android`，`ohos` 三个平台。

[flutter 鸿蒙支持环境搭建](https://gitee.com/harmonycommando_flutter/flutter)


### 向已存在的项目中添加鸿蒙支持

需要先进入到项目中，之后执行命令

```shell
flutter create  --platforms=ohos .
```

如果之前设置了org，此时可能会报org冲突，此时需要在命令中指定 org。

```shell
flutter create  --platforms=ohos . --org="xxx.xxx"
```

其中 `xxx.xxx` 为您 org 的名称。


### 新建支持鸿蒙的项目

```shell
flutter create new_project_name --org="xxx.xxx" --platforms=ios,android,ohos
```

### 添加 im_flutter_sdk

在工程的 `pubspec.yaml` 中添加 sdk 依赖。

```shell
im_flutter_sdk:
    git:
        url: "https://github.com/easemob/im_flutter_sdk_oh.git"
        ref: "main"
```

#### 修改 useNormalizedOHMUrl 模式

因为 环信 sdk 只支持 useNormalizedOHMUrl模式，最需要在你的项目中配置 useNormalizedOHMUrl 为 `true`

打开 `app/ohos/build-profile.json5` 文件，找到 `app:products:`, 并向其中添加 `buildOption`

```json
"products": [
  {
    "name": "default",
    "signingConfig": "default",
    "compatibleSdkVersion": "5.0.0(12)",
    "runtimeOS": "HarmonyOS",
    // 添加内容
    "buildOption": {
      "strictMode": {
        "useNormalizedOHMUrl": true
      }
    }
  }
]
```


运行项目时需要先 build hap包。 执行
```shell
flutter build hap --debug
```

目前 flutter 社区版框架不支持 floatingActionButton，如果需要运行项目，要删除 floatingActionButton。
同时，如果是模拟器运行，需要关闭 `impeller`,
关闭方法参考 [常见问题](https://gitee.com/harmonycommando_flutter/flutter#%E5%B8%B8%E8%A7%81%E9%97%AE%E9%A2%98)

### 打包

项目打包执行 `flutter build hap --release`



### 常见问题

1. 在sdk初始化时增加类华为appId的传参，调用后会把appID传给鸿蒙im sdk，以便它去获取推送和绑定deviceToken。调用方式：

```dart
EMOptions options = EMOptions.withAppKey(
    appKey,
    extSettings: {
      ExtSettings.kAppIDForOhOS: "",
    },
);
```

调用后sdk会自动获取deviceToken和绑定，不需要flutter层再去调用 bindDeviceToken方法了， 当然，bindDeviceToken方法依然可用，如果不想使用以上方法，可以调用bindDeviceToken。