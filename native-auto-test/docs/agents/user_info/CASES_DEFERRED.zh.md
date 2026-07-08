# UserInfo 模块 Cases 暂缓清单（按 API）

— 说明
- 本文件仅记录 UserInfo 模块暂缓项。
- MissingPluginException 统一记录为桥接/平台通道缺口，不作为 SDK API 正常业务预期。

## 暂缓项
- `tests/user_info/test_user_info.py::test_user_info_update_then_fetch_own_info`
  - API：`fetchOwnInfo`
  - 原因：当前原生通道未实现 direct cmd，实测返回 `MissingPluginException`；成功语义暂由 `fetchUserInfoById([currentUser])` 等价链路覆盖。
  - 恢复条件：桥接补齐后按真实返回重新 discovery 并改为 strict 断言。
