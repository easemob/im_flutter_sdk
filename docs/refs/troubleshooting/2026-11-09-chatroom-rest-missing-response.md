# 聊天室删除后的 REST 缺失响应使用 group 字样

- 日期：2026-11-09。
- 状态：测试清理误判已修复并复验。
- 触发仓库：`im_flutter_sdk`，5.1.0 测试覆盖。
- 适用环境：当前测试公有云 REST 环境；其他部署不能仅按任意 404 推断资源已删除。

## 结论

查询已删除聊天室 `GET chatrooms/<id>`，实际返回 HTTP 404、`service_resource_not_found`，描述却是 `do not find this group:<id>`。该响应不是 SDK 聊天室发送失败，也不意味着聊天室仍存在。

## 现象、根因与修复

`FL-CONV-013` 的发送最终回调及默认会话过滤断言通过，REST 清理检查却失败，因为新 fixture 只识别聊天室专用错误名。

`CiRestFixture.chatRoom()` 现额外接受上述三个字段精确匹配的响应，要求描述中的 ID 等于请求 ID。新增测试拒绝其他 ID、共享前缀、服务不可用及 401；不吞任意网络或鉴权错误。

首轮证据：`reports/5.1.0/test-coverage/nightly-android.log:206`。修复后 `nightly-android-r2.log`、`nightly-ios.log` 均明确输出 REST room absent，核心行为和清理分别核实。

## 排查备忘

```bash
rg -n 'FL-CONV-013|service_resource_not_found' reports/5.1.0/test-coverage/nightly-*.log
```
