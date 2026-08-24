# Client 模块 Cases 总记录（按 API）

Allure：客户端登录、会话边界与多设备查询用例已补充业务动作和结果验证步骤。

— 说明
- 本文件记录 Client 模块已覆盖用例（按 API 组织）。
- 每条 case 以全局序号编号；统计按“当前记录条目数”计算。
- 暂缓与 skip 项统一写 `CASES_DEFERRED.zh.md`。

## login

正常 cases
1. `tests/client/test_client.py::test_login_then_receive_offline_sync_event`
   重新登录后在同连接等待离线同步启动事件，验证登录成功后会触发基础同步回调。

异常 cases
2. `tests/client/test_client.py::test_client_login_invalid_password`
   使用错误密码登录，断言返回失败语义或可识别错误结构，避免误判为成功。

## createAccount

异常/边界 cases
3. `tests/client/test_client_remaining_api_coverage.py::test_client_create_account_empty_user_boundary`
   覆盖 `createAccount` 空 userId/password 边界，冻结真实模拟器返回 `205/illegal user name`，不创建新账号且不影响当前登录态。

## getCurrentUser

正常 cases
4. `tests/client/test_client.py::test_client_get_current_user`
   在 session 已登录前提下调用 `getCurrentUser`，验证返回当前登录用户信息。

异常 cases
5. 无（当前测试集中未单独覆盖该 API 的异常入参）。
   说明：该 API 目前仅在已登录上下文使用，未单测非法登录态或参数异常路径。

## isConnected / isLoggedInBefore

正常 cases
6. `tests/client/test_client_remaining_api_coverage.py::test_client_connection_state_queries`
   在已登录 session 下分别调用 `isConnected` 与 `isLoggedInBefore`，冻结实测返回 `true` 的连接态与历史登录态语义。

异常 cases
7. 无（两者无入参；未登录态需要独立登录态隔离，后续可作为边界补充）。

## init

正常/边界 cases
8. `tests/client/test_client_remaining_api_coverage.py::test_client_init_repeated_call_idempotent`
   覆盖 `init` 已初始化后的重复调用幂等场景，冻结真实模拟器返回 `result=null`，并用 `getCurrentUser` 验证当前登录态未被清空。

## getToken / getCurrentDeviceId

正常 cases
9. `tests/client/test_client_remaining_api_coverage.py::test_client_current_token_and_device_id`
   在已登录 session 下调用 `getToken` 与 `getCurrentDeviceId`，校验 token 为非空字符串，并冻结 `getCurrentDeviceId` 实测返回设备信息字典且 `deviceUUID` 非空。

异常 cases
10. 无（两者无入参；未登录态需要独立登录态隔离，后续可作为边界补充）。

## compressLogs

正常 cases
11. `tests/client/test_client_remaining_api_coverage.py::test_client_compress_logs_returns_path`
   调用 `compressLogs` 压缩本地日志，校验实测返回非空 `log.gz` 路径字符串。

异常 cases
12. 无（该 API 无入参，当前仅覆盖正常压缩链路）。

## update*Setting

正常 cases
13. `tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateUsingHttpsOnlySetting-info0]`
    更新 `usingHttpsOnly` 运行时配置，冻结实测成功返回 `result=null`。
14. `tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateLoginExtensionInfo-info1]`
    更新登录扩展信息 `extension`，冻结实测成功返回 `result=null`。
15. `tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateDeleteMessagesWhenLeaveGroupSetting-info2]`
    按测试基线更新离开群组是否删除消息配置为 `true`，冻结实测成功返回 `result=null`。
16. `tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateDeleteMessageWhenLeaveRoomSetting-info3]`
    按测试基线更新离开聊天室是否删除消息配置为 `true`，冻结实测成功返回 `result=null`。
17. `tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateRoomOwnerCanLeaveSetting-info4]`
    更新聊天室 owner 是否可离开配置，冻结实测成功返回 `result=null`。
18. `tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateAutoAcceptGroupInvitationSetting-info5]`
    按测试基线更新是否自动接受群邀请配置为 `true`，冻结实测成功返回 `result=null`。
19. `tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[acceptInvitationAlways-info6]`
    按测试基线更新是否自动接受好友邀请配置为 `true`，冻结实测成功返回 `result=null`。
20. `tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateAutoDownloadAttachmentThumbnailSetting-info7]`
    更新是否自动下载附件缩略图配置，冻结实测成功返回 `result=null`。
21. `tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateRequireAckSetting-info8]`
    更新是否需要已读回执配置，冻结实测成功返回 `result=null`。
22. `tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateDeliveryAckSetting-info9]`
    按测试基线更新是否需要送达回执配置为 `true`，冻结实测成功返回 `result=null`。
23. `tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateSortMessageByServerTimeSetting-info10]`
    更新消息是否按服务端时间排序配置，冻结实测成功返回 `result=null`。
24. `tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateMessagesReceiveCallbackIncludeSendSetting-info11]`
    按测试基线更新消息接收回调是否包含发送消息配置为 `true`，冻结实测成功返回 `result=null`。
25. `tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateRegradeMessagesSetting-info12]`
    更新导入消息是否视为已读配置，冻结实测成功返回 `result=null`。

异常 cases
26. 无（本批按方法级正常链路覆盖；非法类型入参由桥接/Dart 类型约束处理，后续可按边界专项补充）。

## renewToken / changeAppKey / getLoggedInDevicesFromServer / kickDevice / kickAllDevices / loginWithAgoraToken

异常/边界 cases
27. `tests/client/test_client_remaining_api_coverage.py::test_client_session_sensitive_api_boundaries[renewToken-info0-expected_result0]`
    覆盖 `renewToken` 空 token 边界，只断言错误码 `104`；Android/iOS 的 description 不参与断言。
28. `tests/client/test_client_remaining_api_coverage.py::test_client_session_sensitive_api_boundaries[changeAppKey-info1-expected_result1]`
    覆盖 `changeAppKey` 空 appKey 边界，冻结实测错误 `110/appkey is null or empty`。
29. `tests/client/test_client_remaining_api_coverage.py::test_client_session_sensitive_api_boundaries[getLoggedInDevicesFromServer-info2-expected_result2]`
    覆盖 `getLoggedInDevicesFromServer` / `fetchLoggedInDevices` 错误账号密码边界，冻结实测错误 `204/User does not exist`。
30. `tests/client/test_client_remaining_api_coverage.py::test_client_session_sensitive_api_boundaries[kickDevice-info3-expected_result3]`
    覆盖 `kickDevice` 错误账号密码与空 resource 边界，冻结实测错误 `205/Invalid parameter`，不影响当前已登录设备。
31. `tests/client/test_client_remaining_api_coverage.py::test_client_session_sensitive_api_boundaries[kickAllDevices-info4-expected_result4]`
    覆盖 `kickAllDevices` 错误账号密码边界，冻结实测错误 `204/User does not exist`，不影响当前已登录设备。
32. `tests/client/test_client_remaining_api_coverage.py::test_client_session_sensitive_api_boundaries[loginWithAgoraToken-info5-expected_result5]`
    覆盖 `loginWithAgoraToken` 非法账号与空 token 边界，冻结真实模拟器返回 `110/username or token is null or empty!`，不切换当前密码登录态。

## 统计
- 当前记录 case 条目总数：`32`
