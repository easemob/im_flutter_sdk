# Example 测试体系 v2

**请记住并遵守 spec.md 文档规则。这是最高优先级。**

基于 Dart 的独立测试工具工程。目标包括数据准备、设备准备、多设备协同执行、日志报告和清理；单设备执行暂缓。

入口见[执行流程](docs/2026-11-06-test-execution-flow.md)及[执行规格](../docs/spec/2026-11-06-testing-v2-spec.md)。

## 目录

```text
testing_v2/
├── README.md
├── spec.md               # 规则与边界
├── pubspec.yaml
├── pubspec.lock
├── analysis_options.yaml
├── .gitignore
├── lib/                  # Dart 源码；生成的 accounts.g.dart 保存账号数据，Git 忽略
│   └── testing_v2.dart   # 程序入口
├── scripts/              # 账号数据生成脚本，纳入 Git
├── data/                 # YAML 流程、JSON 命令等静态数据
├── docs/                 # 项目文档
├── troubleshooting/      # 故障排查与修复记录，纳入 Git
├── tmp/                  # 运行临时数据，Git 忽略
├── build/                # 构建产物与缓存，Git 忽略
└── reports/              # 每次运行的报告，Git 忽略
```
