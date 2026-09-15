# Push 模块 Cases 暂缓清单（按 API）

本文件记录尚未形成有效业务回归的能力缺口。

## APNs 平台覆盖缺口

- 2026-09-15 已按用户要求删除 Android 上仅检查 MissingPluginException 的 APNs 探测用例，不再作为可恢复的现有 case 列出。
- `updateAPNsPushToken` 的真实业务验证应在 iOS 和有效 APNs 配置下设计，包含绑定及推送结果；Android 的 MissingPlugin 不作为正常业务预期。
