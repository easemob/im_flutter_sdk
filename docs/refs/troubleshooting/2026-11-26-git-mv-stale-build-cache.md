# git mv 会连同未跟踪构建缓存一起搬走，绝对路径失效导致构建失败

- 日期：2026-11-26
- 状态：已确认并修复
- 触发仓库：`im_flutter_sdk`，`5.2.0` 分支（`im_flutter_sdk/example` → `workbench` 迁移）
- 适用环境：Flutter 3.47.0，iOS SPM 集成（`FlutterGeneratedPluginSwiftPackage`），Android 同理

## 结论

`git mv <dir> <new-dir>` 是文件系统级整体移动，**未跟踪的构建产物（`build/`、`.dart_tool/`、`ios/Flutter/ephemeral`）会一起被搬走**，其中缓存的是旧位置的绝对路径。改名后第一次构建会以"找不到旧路径下的产物"失败。修法：改名后（或改名前先清理）对被移动目录执行 `flutter clean && flutter pub get`，不要尝试手工改缓存文件。

## 现象与根因

iOS 冒烟构建报错：

```
Error (Xcode): There is no XCFramework found at
  '.../im_flutter_sdk/example/build/ios/SourcePackages/artifacts/hyphenatechat_ios/...'
```

注意路径是**旧位置** `im_flutter_sdk/example/build/...`，而实际构建发生在 `workbench/`。根因：SPM artifact 路径记录在随目录一起搬走的 `workbench/build/ios/XCBuildData/PIFCache` 和 `workbench/.dart_tool/hooks_runner/` 缓存里，全部以绝对路径指向旧目录。此次迁移恰好又在原路径新建了最小 `example/`，旧路径"存在但没有产物"，报错更具迷惑性。

附带现象：Android 端 APK 能编译成功（Gradle 对路径变化做了重算），但不能据此认为缓存无害——iOS 端必现。

## 修法

```bash
cd <被移动目录>
flutter clean      # 删除 build/ .dart_tool/ ephemeral 等全部缓存
flutter pub get    # 重新生成，全部使用新路径
```

## 排查命令备忘

```bash
# 定位残留的绝对路径引用（全部应只命中 build/ .dart_tool/ 等缓存，否则是真问题）
grep -rln '<旧目录名>' <被移动目录>/build <被移动目录>/.dart_tool <被移动目录>/ios 2>/dev/null
```
