# Sniff 模块 Cases 总记录（按 API）

— 说明
- 本文件记录 Sniff 模块已覆盖用例（按 API 组织）。
- 每条 case 以全局序号编号；统计按“当前记录条目数”计算。
- 暂缓与 skip 项统一写 `CASES_DEFERRED.zh.md`。

## wsSniff（事件嗅探）

正常 cases
1. `tests/sniff/test_ws_sniff.py::test_ws_sniff`
   在设定时长内持续打印 deviceA/deviceB 的 WS 收包，用于现场诊断回调顺序和消息形态。

异常 cases
2. 不适用（嗅探用例为诊断工具，不定义错误语义断言）。
   说明：sniff 用例不承载业务断言，核心目标是采样与可观测性。

## 统计
- 当前记录 case 条目总数：`2`
