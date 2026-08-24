# Presence 模块 Cases 总记录（按 API）

Allure：在线状态发布、订阅、分页及边界用例已补充按业务语义命名的步骤。

— 说明
- 本文件记录 Presence 模块已覆盖用例（按 API 组织）。
- 每条 case 以全局序号编号；统计按“当前记录条目数”计算。
- 暂缓与 skip 项统一写 `CASES_DEFERRED.zh.md`。

## presenceWithDescription

正常 cases
1. `tests/presence/test_presence.py::test_presence_publish_subscribe_query_unsubscribe`
   发布在线描述并完成订阅、查询、取消订阅全链路校验；`publishPresenceWithDescription` 当前实测同步返回 `result=true`。
2. `tests/presence/test_presence.py::test_presence_publish_empty_desc_then_fetch`
   发布空描述后查询状态，验证空描述语义与返回结构；`publishPresenceWithDescription` 当前实测同步返回 `result=true`。

异常 cases
3. `tests/presence/test_presence.py::test_presence_publish_128k_desc`
   发布 128KB 超大描述，验证长度越界错误语义。

## presenceSubscribe

正常 cases
4. `tests/presence/test_presence.py::test_presence_publish_subscribe_query_unsubscribe`
   订阅已发布用户状态并验证订阅成功返回。

异常 cases
5. `tests/presence/test_presence.py::test_presence_subscribe_nonexistent_user`
   订阅不存在用户，验证目标不存在类错误语义。
6. `tests/presence/test_presence.py::test_presence_subscribe_expiry_over_30_days`
   订阅过期时长超过上限，验证时长边界错误语义。
7. `tests/presence/test_presence.py::test_presence_subscribe_over_100_members`
   单次订阅成员数超过上限，验证数量边界错误语义。

## presenceUnsubscribe

正常 cases
8. `tests/presence/test_presence.py::test_presence_publish_subscribe_query_unsubscribe`
   取消订阅后再次查询，验证订阅状态被正确移除。

异常 cases
9. `tests/presence/test_presence.py::test_presence_unsubscribe_over_100_members`
   取消订阅成员数超过上限，验证数量边界错误语义。

## fetchPresenceStatus

正常 cases
10. `tests/presence/test_presence.py::test_presence_publish_subscribe_query_unsubscribe`
    查询已发布用户状态，验证在线描述与状态字段。
11. `tests/presence/test_presence.py::test_presence_publish_empty_desc_then_fetch`
    查询空描述用户状态，验证空值场景返回语义。

异常 cases
12. 无（当前测试集中未单独覆盖该 API 的错误入参）。
    该 API 当前主要作为订阅链路结果断言点。

## fetchSubscribedMembersWithPageNum

正常 cases
13. `tests/presence/test_presence.py::test_fetch_subscribed_members_pagination`
    分页拉取订阅成员列表，验证常规分页参数语义。
14. `tests/presence/test_presence.py::test_fetch_subscribed_members_pagination_page_size_one`
    pageSize=1 拉取订阅成员列表，验证最小分页粒度行为。

异常 cases
15. `tests/presence/test_presence.py::test_fetch_subscribed_members_invalid_pagination`
    非法页码或页大小参数拉取订阅成员，验证分页错误语义。

## 统计
- 当前记录 case 条目总数：`15`
