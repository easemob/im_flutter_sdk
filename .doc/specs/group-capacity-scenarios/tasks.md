# Group 容量场景参数化任务

## Task 1：容量场景状态与 pytest 参数

- [x] 新增 `native-auto-test/tests/group/test_group_capacity.py` 的无设备单元测试：默认容量、配置为 3000、拒绝非正整数。
- [x] 使用 `.venv/bin/python -m pytest --confcutdir=tests/group tests/group/test_group_capacity.py` 运行新增测试，确认缺失容量模块导致预期失败。
- [x] 新增 `native-auto-test/src/tools/group_capacity.py`，实现默认值 200、配置、读取、重置和正整数校验。
- [x] 在 `native-auto-test/tests/conftest.py` 注册 `--group-create-max-count`，在 pytest 配置钩子中配置、在 unconfigure 钩子中重置。
- [x] 重跑无设备单元测试并确认通过（5 passed）；覆盖 `assert_group_snapshot()` 未显式传容量时读取当前场景的行为。

## Task 2：将 Group 建群请求接入场景容量

- [x] 修改 `native-auto-test/tests/group/group_helpers.py`：`create_group()` 未传 `max_count` 时读取活动容量，显式参数保持不变。
- [x] 修改 `native-auto-test/tests/group/test_group_exceptions_lifecycle.py`：常规 `maxCount=200` 请求和 `maxUserCount` 预期使用运行时活动容量；保留 `0`、`-1`、`1` 容量边界值，并保留用户当前禁用的超长群名参数。
- [x] 用静态检索确认 Group case 中只剩边界语义的显式 `maxCount` 数值，且不会存在普通请求写死 200。

## Task 3：验证与台账

- [x] 运行容量单元测试、`compileall` 和 pytest collection 参数预检查；未执行会创建真实群的默认容量 Group case。
- [ ] 以 `--group-create-max-count=3000` 对一个常规 Group 创建 case 做 discovery，确认请求和返回容量均为 3000；随后运行严格回归。未执行：该步骤会写入共享测试环境，需当前明确授权。
- [x] 更新 `native-auto-test/docs/agents/group/CASES_RECORD.zh.md`，记录两个运行命令、边界值豁免和静态验证结果。
- [x] 回填本文件所有任务状态；设计已同步为 pytest 配置/清理钩子实现。
