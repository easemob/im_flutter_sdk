# Contact 模块 Cases 总记录（按 API）

— 说明
- 本文件记录 Contact 模块已覆盖用例（按 API 组织）。
- 每条 case 以全局序号编号；统计按“当前记录条目数”计算。
- 暂缓与 skip 项统一写 `CASES_DEFERRED.zh.md`。

## addContact

正常 cases
1. `tests/contact/test_contact.py::test_friend_add_accept_and_list`
   A 向 B 发起好友申请并被接受，校验申请、同意、好友列表与事件链路。
2. `tests/contact/test_contact.py::test_friend_add_decline_and_verify_not_friends`
   A 向 B 发起好友申请并被拒绝，校验拒绝回调与双方非好友状态。

异常 cases
3. `tests/contact/test_contact.py::test_contact_add_nonexistent_user`
   向不存在用户发起添加好友，冻结错误码与错误描述语义。
4. `tests/contact/test_contact.py::test_contact_add_empty_user_id`
   传空 userId 添加好友，验证参数非法语义。
5. `tests/contact/test_contact.py::test_contact_add_self`
   添加自己为好友，验证自添加被拒绝的异常语义。

## acceptInvitation

正常 cases
6. `tests/contact/test_contact.py::test_friend_add_accept_and_list`
   在存在待处理邀请时执行同意，验证好友关系建立成功。

异常 cases
7. `tests/contact/test_contact.py::test_contact_accept_invitation_without_pending`
   无待处理邀请时执行同意，验证当前端稳定返回语义。

## declineInvitation

正常 cases
8. `tests/contact/test_contact.py::test_friend_add_decline_and_verify_not_friends`
   在存在待处理邀请时执行拒绝，验证拒绝结果和非好友状态。

异常 cases
9. `tests/contact/test_contact.py::test_contact_decline_invitation_without_pending`
   无待处理邀请时执行拒绝，验证当前端稳定返回语义。

## deleteContact

正常 cases
10. `tests/contact/test_contact.py::test_friend_add_accept_and_list`
    成为好友后删除联系人，验证删除成功与后置列表变化。

异常 cases
11. `tests/contact/test_contact.py::test_contact_delete_contact_not_friend`
    删除非好友用户，验证异常或稳定返回语义。
12. `tests/contact/test_contact.py::test_contact_delete_contact_nonexistent_user`
    删除不存在用户，验证目标不存在类错误语义。

## getAllContactsFromServer

正常 cases
13. `tests/contact/test_contact.py::test_friend_add_accept_and_list`
    好友同意后拉取服务端好友列表，验证列表包含目标好友。
14. `tests/contact/test_contact.py::test_friend_add_decline_and_verify_not_friends`
    好友拒绝后拉取服务端好友列表，验证列表不包含目标用户。
15. `tests/contact/test_contact.py::test_contact_block_list_flow_then_unblock_restores_friend`
    黑名单切换链路中拉取服务端好友列表，验证状态切换一致。

异常 cases
16. 无（当前测试集中未单独覆盖该 API 的错误入参）。
    该 API 当前主要用于状态链路校验，异常参数场景待补充。

## getContact

正常 cases
17. `tests/contact/test_contact.py::test_contact_remark_set_then_list_includes_remark`
    设置好友备注后拉取单个好友信息，验证备注字段可见。
18. `tests/contact/test_contact.py::test_contact_remark_empty_string`
    设置空备注后拉取好友信息，验证空值语义稳定。
19. `tests/contact/test_contact.py::test_contact_remark_not_preserved_after_delete_and_readd`
    删好友再重加后拉取好友信息，验证备注不会被错误继承。
20. `tests/contact/test_friend_info_sync.py::test_friend_info_sync_on_peer_metadata_change`
    对端元数据变化后拉取好友信息，验证同步字段更新。

异常 cases
21. 无（当前测试集中未单独覆盖该 API 的错误入参）。
    `getContact` 当前主要作为流程断言点使用，未拆独立异常参数用例。

## setContactRemark

正常 cases
22. `tests/contact/test_contact.py::test_contact_remark_set_then_list_includes_remark`
    给好友设置普通备注，验证写入成功并可在列表中读取。
23. `tests/contact/test_contact.py::test_contact_remark_empty_string`
    给好友设置空字符串备注，验证空备注可被正确处理。
24. `tests/contact/test_contact.py::test_contact_remark_not_preserved_after_delete_and_readd`
    删除并重建好友关系后再次设置备注，验证备注行为一致。

异常 cases
25. `tests/contact/test_contact.py::test_contact_remark_special_chars_length_101`
    备注包含特殊字符且长度超限，验证长度边界错误语义。
26. `tests/contact/test_contact.py::test_contact_set_contact_remark_non_friend`
    对非好友设置备注，验证权限或关系校验异常语义。

## fetchAllContacts / fetchContacts / getAllContacts

正常 cases
27. `tests/contact/test_contact.py::test_contact_fetch_all_fetch_page_fetch_ids_get_local_lists`
    对全量、分页、本地好友列表与 ID 列表做一致性校验。

异常 cases
28. `tests/contact/test_contact.py::test_contact_fetch_contacts_page_size_zero`
    分页拉取时 pageSize=0，验证参数边界语义。
29. `tests/contact/test_contact.py::test_contact_fetch_contacts_page_size_exceeds_50`
    分页拉取时 pageSize 超过上限，验证上限约束语义。
30. `tests/contact/test_contact.py::test_contact_fetch_contacts_page_size_negative`
    分页拉取时 pageSize 为负数，验证非法参数语义。

## addUserToBlockList / removeUserFromBlockList / getBlockListFromServer

正常 cases
31. `tests/contact/test_contact.py::test_contact_get_block_list_from_server_returns_list`
    拉取服务端黑名单列表，验证返回结构与列表语义。
32. `tests/contact/test_contact.py::test_contact_block_list_flow_then_unblock_restores_friend`
    执行拉黑与解除拉黑，验证好友状态切换与恢复行为。
33. `tests/contact/test_contact.py::test_contact_remove_from_block_list_when_not_blocked`
    对未拉黑用户执行解除拉黑，验证幂等或稳定返回语义。

异常 cases
34. `tests/contact/test_contact.py::test_contact_add_user_to_block_list_nonexistent`
    将不存在用户加入黑名单，验证目标不存在类错误语义。
35. `tests/contact/test_contact.py::test_contact_remove_from_block_list_nonexistent_user`
    从黑名单移除不存在用户，验证目标不存在类错误语义。

## 好友信息同步专项（事件链路）

正常 cases
36. `tests/contact/test_friend_info_sync.py::test_friend_info_auto_sync_after_login`
    重新登录后验证好友信息同步开始/结束回调链路。

异常 cases
37. 无（当前专项未定义独立错误入参路径）。
    该专项聚焦同步行为验证，不覆盖参数异常。

## getAllContactsFromDB

正常 cases
38. `tests/contact/test_contact_remaining_api_coverage.py::test_contact_get_all_contacts_from_db_after_server_sync`
    建立好友并调用 `getAllContactsFromServer` 同步后，直接调用 `getAllContactsFromDB`，冻结实测本地 DB 返回好友 ID 列表 `[user_b]` 的语义；Dart 公开方法 `getAllContactIds` 复用同一 native cmd，因此该链路同步覆盖 `getAllContactIds`。

异常 cases
39. 无（该 API 无入参，当前以有数据本地读取链路覆盖；空本地缓存场景后续可作为边界补充）。

## getBlockListFromDB

正常 cases
40. `tests/contact/test_contact_remaining_api_coverage.py::test_contact_get_block_list_from_db_after_server_sync`
    建立好友并拉黑后，先调用 `getBlockListFromServer` 同步，再直接调用 `getBlockListFromDB`，冻结实测本地 DB 返回黑名单 ID 列表 `[user_b]` 的语义。

异常 cases
41. 无（该 API 无入参，当前以有数据本地读取链路覆盖；空本地缓存场景后续可作为边界补充）。

## getSelfIdsOnOtherPlatform

正常 cases
42. `tests/contact/test_contact_remaining_api_coverage.py::test_contact_get_self_ids_on_other_platform_returns_list`
    当前账号仅保持单端登录时调用 `getSelfIdsOnOtherPlatform`，冻结实测返回空列表 `[]` 的语义。

异常 cases
43. 无（该 API 无入参，且多平台同时登录需要额外可控设备会话；当前先覆盖单端登录下的稳定返回）。

## 统计
- 当前记录 case 条目总数：`43`
