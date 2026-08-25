---
name: im-sdk-test-case-design
description: 设计、实现和审查 IM SDK native-auto-test 用例，统一普通 Case、双端 Case、拓扑 Case、离线 Case、断言、Allure 和回归方式。
---

# IM SDK Case 编写规范

本 skill 只负责 Python Case。不要为了让 Case 通过而修改 Wrapper、SDK 或预期结果；发现桥接能力缺失时，记录为能力缺口或 deferred。

## 1. 开始前只看这些

1. 目标模块的 `CASES_RECORD.zh.md` 和 `CASES_DEFERRED.zh.md`。
2. 目标测试文件、`src/sdk_api/cmd_keys.py`、`src/sdk_api/event_keys.py`、已有 helper。
3. 使用的 scenario；只有拓扑/离线 Case 才需要阅读 [references/topology-and-assertions.md](references/topology-and-assertions.md)。

不要求阅读 API Matrix、events Matrix 或原生 API 映射文档。若 cmd/event 在测试桥接中不存在，不自行猜测协议，直接记录能力缺口。

## 2. 先写 Case 设计卡

实现前用几行写清：

- 业务目标和被测 `manager/cmd`；
- 前置账号、群/会话/消息状态；
- Case 类型和动作端；
- 要观察的端点及业务关联键，如 `msgId`、`groupId`；
- response、event 和最终状态的通过条件；
- 清理内容。

每个 Case 的 docstring 至少说明：前置、步骤、关键断言和后置。

Allure 只记录业务过程：

- 测试准备：创建账号、群、消息或恢复状态；
- 动作：谁在哪个端调用什么 API；
- 验证：response、event、最终状态；
- 后置：销毁数据、恢复登录和选项。

步骤标题写清“谁 / 做什么 / 验证什么”，不要把 runner ID、WebSocket 序列号等技术信息当作业务步骤。

## 3. 选择 Case 类型

| 场景 | 写法 |
|---|---|
| 单端 API、查询、参数边界 | 普通 Case，只声明实际需要的 fixture。 |
| A/B 参与，但只验证一次动作和指定观察端 | 普通双端 Case，使用 `device_a`、`device_b`。 |
| 消息投递、已读、撤回、reaction、账号级同步，要求验证端点集合 | 拓扑 Case，使用 `@pytest.mark.topology(...)` 和 `topology`。 |
| 先下线、再登录并验证回放 | 离线拓扑 Case。 |
| 只有某个平台支持的能力 | 平台专项 Case，明确平台和 skip 条件。 |

普通双端不因为有两个账号就使用 topology；拓扑 Case 也不能写死主端、副端数量。

角色命名统一：

- 普通 Case：`device_a`、`device_b`；
- 拓扑 Case：`sender_action_device`、`recipient_action_device`、`sender_devices`、`recipient_devices`；
- `user_c` 只有账号没有设备时，不要虚构 `device_c`；
- 不使用 `observer_device`、`deviceA/deviceB` 作为新的 Python fixture 名。

## 4. 多端和离线规则

- API 动作通常只在 `*_action_device` 执行一次；同账号其他端用于验证同步或回调。
- 只有 SDK 语义要求所有相关在线端收到时，才遍历全部相关端点；否则按契约验证动作端或最终状态。
- 事件必须用 `msgId`、`groupId`、用户 ID 等业务键关联，不能只按事件类型判断。
- `onMessagesDelivered` 等端点粒度事件可能包含同一 `msgId` 的多条记录，不能无条件去重或固定断言为 1。
- 离线前按账号遍历相关端点下线，恢复时逐端登录并逐端验证；副端不重复执行 accept、decline、remove 等动作。
- `finally` 恢复所有相关端点和测试期间修改的选项。
- 不用固定 `sleep` 掩盖时序问题；最终一致性使用带超时的轮询，超时保留实际响应和已观察事件。

## 5. 断言规则

- response 和 event 分开验证：response 证明命令结果，event 证明异步回调。
- `expected` 只写当前业务必需字段；动态字段只在确认不稳定时加入最小 `ignore_keys`。
- 不忽略 `result`、`error`、业务 ID 或关键状态；不把 actual 当 expected。
- 成功 Case 断言必要的 `manager/cmd/device/result`；错误 Case 至少严格断言 `code`。
- `description` 只有在 Android/iOS/Web 已确认一致时才断言；平台文案不同只断言 `code`，不要修改 Wrapper 伪造文案。
- 错误 Case 不以普通成功事件作为通过条件；正常 Case 同时验证 response 和必要 event。
- 事件直接关联原始事件中的业务字段，不重组对象后再伪造断言。
- 分页接口按实际 `cursor/list` 处理：cursor 为空不继续翻页，非空才请求下一页，并防止 cursor 不前进。

## 6. 四类 Case 示例

```python
# 单端 Case：只测一个端点的 API/状态
def test_local_query(device_a, assert_api, user_a):
    with _allure_step("A 查询本地数据"):
        response = device_a.call("Manager", "cmd", info={})
        # 直接断言 response

# 普通双端 Case：A 做动作，B 验证一个明确事件
def test_two_party_action(device_a, device_b, assert_api, user_a, user_b):
    with _allure_step("A 执行动作"):
        response = device_a.call("Manager", "cmd", info={"to": user_b})
    with _allure_step("B 验证目标事件"):
        event = device_b.receive_message(timeout=10)
        # 用 msgId/groupId 等业务键断言 event

# 拓扑 Case：验证账号下相关端点集合
@pytest.mark.topology("account_a_to_account_b")
def test_multi_endpoint_delivery(topology, assert_api):
    action_device = topology.sender_action_device
    with _allure_step("发送端动作端发送消息"):
        response = action_device.call("ChatManager", "sendMessage", info={})
    with _allure_step("接收账号全部相关端点验证投递"):
        for endpoint in topology.recipient_devices:
            # 按业务键等待并断言
            ...

# 离线 Case：按账号下线、恢复和逐端验证
@pytest.mark.topology("account_a_to_account_b")
def test_offline_replay(topology, assert_api):
    with _allure_step("接收账号相关端点下线"):
        ...
    with _allure_step("动作端执行一次业务操作"):
        ...
    with _allure_step("逐端恢复并验证离线结果"):
        ...
# finally：恢复全部端点和选项
```

## 7. 运行与交付

```bash
# 普通单端
.venv/bin/python -m pytest \
  --scenario config/scenarios/android_500_single_device_default.yaml \
  tests/<module>/test_xxx.py::test_xxx

# 双端、拓扑或离线：按目标平台选择 scenario
.venv/bin/python -m pytest \
  --scenario config/scenarios/ios_500_multi_device_default.yaml \
  tests/<module>/test_xxx.py::test_xxx
# 也可使用 android_500_multi_device_default.yaml 或 web_500_multi_device_default.yaml

# 修改了测试 App、Wrapper、JAR 或 SO 后
.venv/bin/python -m pytest --build \
  --scenario <scenario.yaml> tests/<module>/test_xxx.py::test_xxx
```

- 只改 Python Case/helper：不构建 App，先跑单 Case，再跑受影响文件。
- 修改桥接或依赖：使用 `--build`，并说明构建结果。
- 测试失败要区分业务失败、SDK/Wrapper 问题、网络问题和 Runner/设备问题；连接、登录、设备异常不要改成业务 skip。
- 新增或调整 Case 后更新对应模块的 `CASES_RECORD.zh.md`；暂缓、平台不支持或环境阻塞写入 `CASES_DEFERRED.zh.md`。

## 8. 完成前检查

- Case 类型和 fixture 使用正确；没有写死设备数量。
- docstring、Allure 步骤、前置、动作、断言、后置完整。
- response/event 使用业务键关联，关键字段没有被忽略。
- 错误码、平台文案和动态字段按规则断言。
- 拓扑/离线 Case 验证了业务要求的全部相关端点。
- 单 Case 和受影响文件已回归，记录文件已更新。
