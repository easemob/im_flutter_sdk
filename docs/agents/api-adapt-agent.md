# API Adapt Agent（API/回调适配与一致性检查）

- 职责
  - 基于 CHANGELOG 对新增/变更的 API 与回调进行适配；校验三端方法/事件键集合一致性
- 必用技能
  - using-superpowers、speckit
- 步骤
  1) 阅读 im_flutter_sdk_android/CHANGELOG.md 与 im_flutter_sdk_ios/CHANGELOG.md，整理清单
  2) 依据 docs/specs/api-adaptation-spec.md 实施三端对齐
  3) 运行一致性检查脚本（见下），修正直至零差异
  4) speckit.sh build-all 完成构建验证
- 验收标准
  - 方法/事件键集合一致；模型序列化一致；两端构建成功

- 脚本
  - `im_flutter_sdk/scripts/agents/api_adapt_agent.sh check`
