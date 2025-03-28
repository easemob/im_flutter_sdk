# 环信 im flutter sdk 项目介绍

1. 使用联合插件的方式开发，支持安卓，iOS，鸿蒙 三个平台;
2. sdk readme 在 [README](/im_flutter_sdk/README.md);



## 如何添加鸿蒙支持


1. 使用鸿蒙版 flutter `https://gitee.com/harmonycommando_flutter/flutter`

2. 在项目 pubspec.yaml 中添加：
```dart
im_flutter_sdk: ^4.13.0
im_flutter_sdk_ohos:
  git:
    url: "https://github.com/easemob/im_flutter_sdk_oh.git"
    ref: 1.5.3

```
3. 执行 `flutter pub get`;