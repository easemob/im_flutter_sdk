# Contact 模块 Cases 暂缓清单（按 API）

— 说明
- 本文件仅记录 Contact 模块暂缓项。
- MissingPluginException 统一记录为桥接/平台通道缺口，不作为 SDK API 正常业务预期。

## 暂缓项
- `tests/contact/test_contact.py::test_contact_fetch_all_contact_ids_bridge_missing`
  - API：`fetchAllContactIds`
  - 原因：当前原生通道未实现 direct cmd，实测返回 `MissingPluginException`；该结果属于桥接缺口，不作为 SDK 成功语义。
  - 恢复条件：桥接补齐后按真实返回重新 discovery 并改为 strict 断言。
- `tests/contact/test_contact.py::test_contact_get_all_contact_ids_bridge_missing`
  - API：`getAllContactIds`
  - 原因：当前原生通道未实现 direct cmd，实测返回 `MissingPluginException`；本地 ID 成功语义已由 `getAllContactsFromDB` 覆盖。
  - 恢复条件：桥接补齐后按真实返回重新 discovery 并改为 strict 断言。
- 官方 4.x `test_friend_info_auto_sync_after_login`
  - API/事件：`onFriendStartSync` / `onFriendSyncFinished`
  - 原因：5.0 原生 SDK 已移除这些好友同步回调，不再迁移到 5.0。
  - 替代：`tests/contact/test_friend_info_sync.py::test_contact_data_sync_events_after_relogin`
    验证 5.0 的 `onDataSyncStart` / `onDataSyncFinish`。
