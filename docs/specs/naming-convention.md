# 协议名命名规范（Naming Convention）

> 适用：im_flutter_sdk 多版本 SDK 适配（Android/iOS），5.0 基线 + 版本增量。

## 核心原则

**协议名（协议层 API/事件名）稳定，原生名随版本变，wrapper 消化差异。**

```
协议名（MethodKeys，Flutter 层统一，App 开发者用）
  ↔（映射，android_mapping / ios_mapping）
原生方法名（Android jar / iOS 头文件，随版本变）
```

## 命名规则（Android 为准）

| 场景 | 规则 | 例子 |
|---|---|---|
| 原生 `asyncXxx` | 协议名去 async（首字母转小写） | `asyncDeleteConversations` → `deleteConversations` |
| 原生同名 | 协议名透传 | `sendMessage` → `sendMessage` |
| 原生改名（版本间） | wrapper 消化：实现新原生方法名，**协议名保持旧名** | 原生 `onReadAckForGroupMessageUpdated` → `onReadReceiptForGroupMessageUpdated`，协议名仍 `onReadAckForGroupMessageUpdated` |
| 新增 API | 按规则命名（去 async / 透传） | 5.0 新增 6 个：`deleteConversations` 等 |
| 删除 API | 协议名移除，记录 matrix removed | `createAccount`、`reportMessage` |
| iOS 独有能力 | iOS 原生名直接做协议名 | `updateAPNsPushToken`（唯一 iOS 专属协议名） |
| 事件 | 原生回调 → 协议名（历史约定，稳定） | 原生 `onMessageReceived` → 协议 `onMessagesReceived` |

## 三层结构

```
1. 协议名清单：android.yaml / ios.yaml（Manager.cmd，能力矩阵，case skip 用）
2. 原生↔协议映射：android_mapping.yaml / ios_mapping.yaml（升级核对用）
3. wrapper 实现：Android MethodKey.java / iOS MethodKeys.h + wrapper 方法体
```

## 多版本模式（5.0 基线 + 差异增量）

```
基线：src/base500/java（Android）/ Classes/base500（iOS）= 5.0 全套 wrapper
差异：sdk423 / sdk424 = 只放有变动的 wrapper（同名覆盖基线）
合并：Android mergeWrapperSrc（Gradle）/ iOS merge_ios_sdk.sh
5.1 以后：新建 sdk501 目录，只放差异文件，复用基线
```

## 平台差异处理

```
Android 有、iOS 没有（iOS 原生无）→ ios.yaml unsupported（case skip，App 调用返回不支持）
iOS 有、Android 没有 → ios.yaml ios_only_native（平台能力，按需暴露）
iOS 原生改名（Android 协议有对应）→ ios_mapping 改名关系（不是平台独有）
```

## 一致性校验

```bash
python3 im_flutter_sdk/scripts/check_protocol_consistency.py
# 检查五方：Android MethodKey ↔ iOS MethodKeys ↔ Python cmd_keys ↔ android.yaml ↔ ios.yaml
```

## 5.1 升级流程（摘要）

```
1. javap diff 原生（API + Listener 事件）
2. 查映射文件定位协议名 → wrapper 改差异
3. 构建验证（sdk501 flavor / merge_ios_sdk.sh sdk501）
4. matrix yaml 记录 removed/added（versions 链）
5. 事件核对：javap Listener diff → wrapper 转发决策
```
