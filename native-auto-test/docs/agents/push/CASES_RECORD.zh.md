# Push 模块 Cases 总记录（按 API）

Allure：推送配置、静默模式、语言模板和厂商 token 用例已补充业务步骤。

— 说明
- 本文件记录 Push 模块已覆盖用例（按 API 组织）。
- 每条 case 以全局序号编号；统计按“当前记录条目数”计算。
- 暂缓与 skip 项统一写 `CASES_DEFERRED.zh.md`。

## getImPushConfigFromServer / updatePushNickname / updateImPushStyle

正常/当前环境 cases
1. `tests/push/test_push_remaining_api_coverage.py::test_push_fetch_configs_update_nickname_and_style`
   拉取服务端推送配置，并更新推送昵称、推送展示样式。当前模拟器实测 `getImPushConfigFromServer` 可能返回配置对象（含 `displayName/pushStyle`）或 `209/Failed to update push configurations`；更新类接口冻结成功 `true` 或同一 `209` 环境错误两类稳定语义。

异常 cases
2. 无（本批先覆盖当前环境真实返回；厂商推送配置不可用导致的 `209` 已在正常/当前环境 case 中冻结）。

## setSilentModeForAll / fetchSilentModeForAll

正常 cases
3. `tests/push/test_push_remaining_api_coverage.py::test_push_global_silent_mode_flow`
   设置当前用户全局离线推送提醒类型为 `ALL`，随后拉取全局免打扰设置，校验 `remindType=0`、时间段为 `0:0`。

异常 cases
4. 无（本批按方法级正常链路覆盖；非法 param 后续作为边界专项补充）。

## setConversationSilentMode / fetchConversationSilentMode / fetchSilentModeForConversations / removeConversationSilentMode

正常 cases
5. `tests/push/test_push_remaining_api_coverage.py::test_push_conversation_silent_mode_flow`
   对单聊会话设置离线推送提醒类型，分别单会话查询和批量查询，校验返回包含目标 `convId`、`conversationType=0`、`remindType=0`，最后移除该会话设置。

异常 cases
6. 无（本批按方法级正常链路覆盖；非法 convId/conversationType 后续作为边界专项补充）。

## setPreferredNotificationLanguage / fetchPreferredNotificationLanguage / setPushTemplate / getPushTemplate

正常 cases
7. `tests/push/test_push_remaining_api_coverage.py::test_push_preferred_language_and_template`
   设置推送语言为 `en` 并拉取确认；设置推送模板为 `default` 并拉取确认。

异常 cases
8. 无（本批按方法级正常链路覆盖；非法语言码/模板名后续作为边界专项补充）。

## updateHMSPushToken / updateFCMPushToken / bindDeviceToken

正常/当前环境 cases
9. `tests/push/test_push_remaining_api_coverage.py::test_push_vendor_token_update_current_environment[updateHMSPushToken-info0-hms-token-api-coverage]`
   Android 模拟器调用 HMS token 更新，冻结实测返回传入 token 字符串的语义。
10. `tests/push/test_push_remaining_api_coverage.py::test_push_vendor_token_update_current_environment[updateFCMPushToken-info1-expected_result1]`
    Android 模拟器调用 FCM token 更新，冻结当前未传 notifierName 时返回 `code=110`、`description=Notifier name should not be empty!` 的语义。
11. `tests/push/test_push_remaining_api_coverage.py::test_push_vendor_token_update_current_environment[bindDeviceToken-info2-None]`
    调用 `bindDeviceToken` 传入 notifierName 与 deviceToken，冻结实测成功返回 `result=null`。

异常 cases
12. 无（本批按当前环境真实返回覆盖；更多厂商 token 非法格式后续可作为边界专项补充）。

## syncSilentModels

正常 cases
13. `tests/push/test_push_remaining_api_coverage.py::test_push_sync_conversations_silent_mode_current_environment`
    调用 `syncSilentModels` 同步所有会话免打扰信息，冻结实测成功返回 `result=null` 的语义。

异常 cases
14. 无（该 API 无入参，当前仅覆盖正常同步链路）。

## 统计
- 当前记录 case 条目总数：`14`
