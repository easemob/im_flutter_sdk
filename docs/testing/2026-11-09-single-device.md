# 单设备平版测试

用于新增或变更 API 的默认值、显式参数、返回字段、本地读写和明确错误边界。一个运行中客户端能完成的目标使用这一类；可读取多个账号配置，不因此升级为多设备场景。

## 设计规则

- 场景放在 `testing/single/cases/`，复用已有 JSON 引擎和 example API 注册，不在执行端伪造业务结果。
- 新增版本场景沿用 5.0.0 的正向、逆向分文件方式：`script_<版本数字>_apis_positive.json` 与 `script_<版本数字>_apis_negative.json`。两者各自准备和清理、可独立运行；初始化依赖项在 `init` 中显式设置。合法布尔值 true/false 均属正向，逆向只使用契约明确的错误输入。
- API 调用成功只证明该契约的完成条件；查询、筛选、分页、写后读取应按目标检查相关字段和内容。
- 用 `expect.success`、`expect.errorCode` 和 `expect.checks` 表达断言；`checks` 针对返回 `data`。引用通过 `$config`、`$prev`、`$step.<id>` 获取。
- 核对执行端已暴露所需 API、参数和结果。缺少核心断言能力时记录缺口，不能降为“调用成功”并宣称验收通过。
- 步骤可串联成最小业务场景。引用的生产步骤失败会阻断依赖步骤；普通失败继续执行，清理要按实际运行结果核查。
- 既有场景按覆盖需要复用。`loadAllConversations(isSort:false)` 不能断言其顺序必须与 `true` 不同。

## 使用

从仓库根运行 `make auto-report PLATFORM=android SCRIPT=testing/single/cases/<文件>.json`，iOS 使用 `PLATFORM=ios`。先按 [example 配置说明](../../im_flutter_sdk/example/README.md#setup) 准备测试环境。

当前默认仍是 5.0.0 正向脚本，报告仍在 `reports/5.0.0/`；目录归属不代表完成了 5.1.0 验收。其他场景必须显式指定 `SCRIPT`。具体参数及结果文件见 [单设备入口](../../testing/single/README.md)。
