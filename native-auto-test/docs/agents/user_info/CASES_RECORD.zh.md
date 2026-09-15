# UserInfo 模块 Cases 总记录（按 API）

> 2026-09-15 精简后：pytest 收集 **11 条**（展开参数），源码 **11 个测试函数**。历史条目编号不重排，不能用最大编号计算用例数。删除组合查询重复用例；全量查询和指定字段查询分别由 test_user_info_update_then_fetch_user_info_by_id、test_user_info_update_then_fetch_user_info_by_id_with_type 保留。

— 说明
- 本文件记录 UserInfo 模块已覆盖用例（按 API 组织）。
- 条目序号保留历史编号，删除后不重排；当前用例数量以 pytest 收集为准。
- 暂缓与 skip 项统一写 `CASES_DEFERRED.zh.md`。

## updateOwnUserInfo

正常 cases
1. `tests/user_info/test_user_info.py::test_user_info_update_own_set_and_modify`
   更新本人资料字段并再次修改，验证字段变更可持续生效。
2. `tests/user_info/test_user_info.py::test_user_info_update_then_fetch_user_info_by_id`
   更新本人资料后按 userId 查询，验证更新结果可被服务端读取。
3. `tests/user_info/test_user_info.py::test_user_info_update_then_fetch_user_info_by_id_with_type`
   更新本人资料后按类型查询，验证 type 过滤下字段回传正确。
异常 cases
5. `tests/user_info/test_user_info.py::test_user_info_update_own_nickname_length_over_64`
   昵称长度超过上限更新，验证长度边界错误语义。
6. `tests/user_info/test_user_info.py::test_user_info_update_own_nickname_empty`
   昵称设为空字符串更新，验证空值输入语义稳定。

## updateOwnUserInfoWithType

正常 cases
7. `tests/user_info/test_user_info.py::test_user_info_update_own_with_type_nickname`
   使用 type=nickname 更新本人资料；当前实测同步返回为 JSON 字符串，包含 `nickname/sign/gender`。

异常 cases
8. 无（当前测试集中未单独覆盖该 API 的错误入参）。
   当前仅覆盖正常 type 路径，异常 type 参数待后续补齐。

## fetchUserInfoById

正常 cases
9. `tests/user_info/test_user_info.py::test_user_info_fetch_by_id_normal`
   按 userIds 批量查询用户资料，验证正常返回结构与字段。
10. `tests/user_info/test_user_info.py::test_user_info_update_then_fetch_user_info_by_id`
    更新本人资料后再次按 userId 查询，验证数据同步一致。

异常 cases
11. `tests/user_info/test_user_info.py::test_user_info_fetch_by_id_empty_user_ids`
    传空 userIds 列表查询，冻结当前实测返回 `code=205`、`description=userIds is empty`。
12. `tests/user_info/test_user_info.py::test_user_info_fetch_by_id_user_ids_over_100`
    userIds 数量超过上限查询，验证数量边界错误语义。

## fetchOwnInfo

正常 cases
13. `tests/user_info/test_user_info.py::test_user_info_update_then_fetch_user_info_by_id`
    `fetchOwnInfo` Dart 成功语义等价于当前登录用户 `fetchUserInfoById([currentUser])`，更新本人资料后按 userId 拉取，验证 userId、昵称、签名和邮箱字段。

异常 cases
14. 无（直接调用 `fetchOwnInfo` cmd 当前原生通道返回 `MissingPluginException`，已移入 `CASES_DEFERRED.zh.md` 作为桥接缺口记录）。

## fetchUserInfoByIdWithType

正常 cases
15. `tests/user_info/test_user_info.py::test_user_info_fetch_by_id_with_type_normal`
    按 userInfoTypes 过滤查询用户资料，验证类型过滤结果。
16. `tests/user_info/test_user_info.py::test_user_info_update_then_fetch_user_info_by_id_with_type`
    更新后按类型查询本人资料，验证字段回传与过滤一致。

异常 cases
17. 无（当前测试集中未单独覆盖该 API 的错误入参）。
    当前仅覆盖正常类型过滤路径，异常 type 组合待补充。

## 统计
- 当前记录 case 条目总数：`16`
