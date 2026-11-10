#!/usr/bin/env python3
"""Generate ignored CI reports from Flutter's JSON reporter, without running tests.

Device runners call start/finish automatically. render rebuilds a saved run;
merge combines only explicitly named runs. See docs/testing/2026-11-09-reports.md.
Python 3 standard library only. Never read test credentials into report metadata.
"""

import argparse
from collections import Counter
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile
from urllib.parse import quote


ROOT = Path(__file__).resolve().parents[2]
LABELS = {"passed": "通过", "failed": "失败", "skipped": "跳过",
          "incomplete": "未完成", "not_run": "未执行"}


def now():
    return datetime.now(timezone.utc).isoformat()


def read(path):
    return json.loads(Path(path).read_text())


def write(path, value):
    Path(path).write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n")


def cell(value):
    return str(value if value is not None else "未知").replace("|", "\\|").replace("\n", "<br>")


def link(path, directory, title=None):
    if not Path(path).exists():
        return f"{cell(title or Path(path).name)}（未生成）"
    return f'[{cell(title or Path(path).name)}]({quote(os.path.relpath(path, directory), safe="/.-_")})'


def configuration(target):
    source = ROOT / "im_flutter_sdk/example" / target
    if not source.is_file():
        return {}
    text = source.read_text()
    values = {}
    for key in ("debugMode", "autoLoadConversations", "enableChatroomConversation", "enableUserInfo"):
        match = re.search(rf"\b{key}:\s*(true|false)\b", text)
        if match:
            values[key] = match[1] == "true"
    match = re.search(r"\bdataSyncType:\s*([^,]+),", text)
    if match:
        values["dataSyncType"] = " ".join(match[1].split())
    return values


def start(args):
    if args.output:
        directory = Path(args.output).resolve()
        directory.mkdir(parents=True, exist_ok=False)
    else:
        parent = ROOT / "artifacts/ci"
        parent.mkdir(parents=True, exist_ok=True)
        prefix = datetime.now().strftime("%Y%m%d-%H%M%S-") + args.platform + "-"
        directory = Path(tempfile.mkdtemp(prefix=prefix, dir=parent))
    commit = subprocess.run(["git", "rev-parse", "HEAD"], cwd=ROOT, capture_output=True, text=True)
    dirty = subprocess.run(["git", "status", "--porcelain"], cwd=ROOT, capture_output=True, text=True)
    version = re.search(r"^version:\s*(\S+)", (ROOT / "im_flutter_sdk/pubspec.yaml").read_text(), re.M)
    write(directory / "run.json", {
        "schemaVersion": 1, "startedAt": now(), "platform": args.platform,
        "target": args.target, "filter": args.name, "device": args.device,
        "sdkPackageVersion": version[1] if version else "unknown",
        "commit": commit.stdout.strip(), "worktreeDirty": bool(dirty.stdout.strip()),
        "initialization": configuration(args.target), "attempts": [],
    })
    print(directory)


def parse_attempt(directory, attempt):
    events_file = directory / f"attempt-{attempt['number']}.events.jsonl"
    tests, root_counts, suite_paths, faults = {}, {}, {}, []
    ended = False
    if events_file.exists():
        for line_number, line in enumerate(events_file.read_text().splitlines(), 1):
            try:
                event = json.loads(line)
            except ValueError:
                faults.append(f"结构化事件第 {line_number} 行不完整或格式错误")
                continue
            kind = event.get("type")
            if kind == "suite":
                suite = event["suite"]
                suite_paths[suite["id"]] = suite.get("path", "")
            elif kind == "group" and event["group"].get("parentID") is None:
                group = event["group"]
                root_counts[group["suiteID"]] = group["testCount"]
            elif kind == "testStart":
                test = event["test"]
                tests[test["id"]] = {"name": test["name"], "suite": suite_paths.get(test["suiteID"], ""),
                                     "status": "incomplete", "startedMs": event.get("time", 0),
                                     "errors": [], "hidden": False,
                                     "skipReason": test.get("metadata", {}).get("skipReason")}
            elif kind == "error":
                test = tests.get(event.get("testID"))
                message = event.get("error", "Unknown test error")
                if test is None:
                    faults.append(message)
                else:
                    test["errors"].append(message)
            elif kind == "testDone" and event["testID"] in tests:
                test = tests[event["testID"]]
                test["hidden"] = event.get("hidden", False)
                test["durationMs"] = max(0, event.get("time", 0) - test["startedMs"])
                test["status"] = ("skipped" if event.get("skipped") else
                                  "passed" if event.get("result") == "success" else "failed")
            elif kind == "done":
                ended = True
                if not event.get("success", False):
                    faults.append("Flutter 报告执行未成功结束，详见用例或准备/收尾记录")
    cases, checks = [], []
    for test in tests.values():
        name = test["name"]
        if test["hidden"] or name.startswith("loading ") or re.search(r"\((?:setUpAll|tearDownAll)\)$", name):
            checks.append(test)
        else:
            case_id = re.search(r"\bFL-[A-Z]+-\d+\b", name)
            test["id"] = case_id[0] if case_id else name
            cases.append(test)
    counts = {key: 0 for key in LABELS}
    counts.update(Counter(test["status"] for test in cases))
    # Root groups describe the selected tests, including ones not yet started.
    # Before discovery, the total is unknown, never a successful empty suite.
    total = max(sum(root_counts.values()), len(cases)) if root_counts or cases else None
    if total is not None:
        counts["not_run"] += total - len(cases)
    if not ended:
        faults.append("缺少 Flutter 完成事件（构建/启动失败或执行中断），不能判为全部通过")
    if not cases:
        faults.append("没有业务用例执行记录；用例总数在未完成发现时未知")
    if attempt.get("exitCode") not in (None, 0):
        faults.append(f"执行命令退出码：{attempt['exitCode']}")
    for check in checks:
        if check["status"] != "passed":
            faults.append(f"准备/收尾：{check['name']}：{'; '.join(check['errors']) or check['status']}")
    return {**attempt, "cases": cases, "checks": checks, "counts": counts,
            "total": total, "faults": faults, "events": str(events_file),
            "log": str(directory / f"attempt-{attempt['number']}.log")}


def load_run(directory):
    directory = Path(directory).resolve()
    if not (directory / "run.json").exists():
        return {"directory": str(directory), "target": directory.name, "platform": "未知",
                "attempts": [], "counts": {key: 0 for key in LABELS}, "total": None,
                "faults": ["批次未启动，未发现用例，总数未知"]}
    metadata = read(directory / "run.json")
    attempts = [parse_attempt(directory, attempt) for attempt in metadata["attempts"]]
    final = attempts[-1] if attempts else {"counts": {key: 0 for key in LABELS}, "total": None,
                                           "faults": ["执行尚未进入 Flutter 测试阶段"]}
    result = {**metadata, "directory": str(directory), "attempts": attempts,
              "counts": final["counts"], "total": final["total"], "faults": list(final["faults"])}
    if metadata.get("exitCode") not in (None, 0):
        result["faults"].append(f"批次退出码：{metadata['exitCode']}；详见 runner.log")
    if not metadata.get("finishedAt"):
        result["faults"].append("批次缺少结束记录")
    return result


def render(directories, output):
    output = Path(output).resolve()
    output.mkdir(parents=True, exist_ok=True)
    batches = [load_run(directory) for directory in directories]
    identities = set()
    for batch in batches:
        identity = (batch["platform"], batch["target"], json.dumps(batch.get("initialization", {}), sort_keys=True))
        if identity in identities:
            raise ValueError("同平台同初始化入口不能重复合计；请选择本次要采用的运行，历史报告仍保留")
        identities.add(identity)
    counts = {key: sum(b["counts"][key] for b in batches) for key in LABELS}
    known_total = sum(b["total"] or 0 for b in batches)
    unknown = sum(b["total"] is None for b in batches)
    ids = {case["id"] for batch in batches for case in (batch["attempts"][-1]["cases"] if batch["attempts"] else [])}
    complete = bool(batches) and not unknown and all(not b["faults"] for b in batches) and not any(counts[k] for k in LABELS if k != "passed")
    report = {"schemaVersion": 1, "category": "ci", "generatedAt": now(),
              "status": "passed" if complete else "attention", "knownTotal": known_total,
              "unknownTotalBatches": unknown, "counts": counts, "distinctObservedCases": len(ids),
              "batches": batches}
    write(output / "report.json", report)
    lines = ["# CI 持续回归测试报告", "", f"生成时间：{report['generatedAt']}", "",
             f"结论：{'本轮选测全部通过' if complete else '存在失败、跳过、未执行或执行异常，请查看明细'}。", "",
             f"已知执行项总数：**{known_total}**；总数未知批次：**{unknown}**；已观察去重用例：**{len(ids)}**。",
             "统计单位：用例 × 平台 × 初始化批次；各批次仅取最后一次尝试，重试历史单列。",
             "", "| 通过 | 失败 | 跳过 | 未完成 | 未执行 |", "|---:|---:|---:|---:|---:|",
             "| " + " | ".join(str(counts[k]) for k in LABELS) + " |", "",
             "## 批次统计", "", "| 批次 / 平台 | 总数 | 通过 | 失败 | 跳过 | 未完成 | 未执行 | 尝试数 | 原始记录 |",
             "|---|---:|---:|---:|---:|---:|---:|---:|---|"]
    for batch in batches:
        directory = Path(batch["directory"])
        lines.append("| " + " | ".join([cell(batch["target"] + " / " + batch["platform"]), cell(batch["total"]),
                     *(str(batch["counts"][k]) for k in LABELS), str(len(batch["attempts"])),
                     link(directory / "run.json", output, "运行信息") if (directory / "run.json").exists() else "未启动"]) + " |")
    if (output / "runner.log").exists():
        lines += ["", f"入口过程日志：{link(output / 'runner.log', output)}"]
    for batch in batches:
        directory = Path(batch["directory"])
        duration = "未知"
        if batch.get("startedAt") and batch.get("finishedAt"):
            duration = f"{(datetime.fromisoformat(batch['finishedAt']) - datetime.fromisoformat(batch['startedAt'])).total_seconds():.1f} 秒"
        lines += ["", f"## {cell(batch['target'])} / {cell(batch['platform'])}", "",
                  f"- 设备：{cell(batch.get('device'))}",
                  f"- SDK 包版本：{cell(batch.get('sdkPackageVersion'))}；提交：{cell(batch.get('commit'))}；未提交改动：{cell(batch.get('worktreeDirty'))}",
                  "- Native 版本：未自动核验，不能由包版本或分支名推断。",
                  f"- 开始：{cell(batch.get('startedAt'))}；结束：{cell(batch.get('finishedAt'))}",
                  f"- 批次总耗时（含准备与构建）：{duration}",
                  f"- 选择范围：{cell(batch.get('filter') or '入口全部用例')}",
                  f"- 初始化源码快照（未列字段未采集）：`{cell(json.dumps(batch.get('initialization', {}), ensure_ascii=False))}`",
                  f"- 过程日志：{link(directory / 'runner.log', output)}"]
        for fault in batch["faults"]:
            lines.append(f"- **执行异常**：{cell(fault)}")
        for attempt in batch["attempts"]:
            lines += ["", f"### 尝试 {attempt['number']} {'（最终统计）' if attempt is batch['attempts'][-1] else '（历史，保留失败）'}", "",
                      f"原始证据：{link(attempt['events'], output, 'Flutter JSON 事件')} · {link(attempt['log'], output, '设备日志')}", "",
                      "| 用例 | 结果 | 耗时 ms | 原因 / 失败断言 |", "|---|---|---:|---|"]
            for case in attempt["cases"]:
                lines.append("| " + " | ".join([cell(case["name"]), LABELS[case["status"]], cell(case.get("durationMs")),
                             cell("; ".join(case["errors"]) or case.get("skipReason") or "—")]) + " |")
            for check in attempt["checks"]:
                lines.append(f"\n准备/收尾 `{cell(check['name'])}`：{LABELS[check['status']]}。{cell('; '.join(check['errors']))}")
            if attempt["counts"]["not_run"]:
                lines.append(f"\n另有 {attempt['counts']['not_run']} 项已发现但未启动，JSON 协议没有提供这些项的名称。")
            for fault in attempt["faults"]:
                lines.append(f"\n执行异常：{cell(fault)}")
    lines += ["", "本报告只覆盖显式纳入的批次；未选平台不计通过。准备/收尾不计业务用例。",
              "用例内的 addTearDown 失败由 Flutter 归入该用例，具体断言见错误与原始日志。",
              f"结构化统计：{link(output / 'report.json', output)}", ""]
    (output / "summary.md").write_text("\n".join(lines))
    print(f"CI report: {output / 'summary.md'}")
    print(f"CI cases: known_total={known_total} " + " ".join(f"{k}={v}" for k, v in counts.items()) + f" unknown_batches={unknown}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="action", required=True)
    begin = sub.add_parser("start")
    begin.add_argument("--output")
    begin.add_argument("--platform", required=True)
    begin.add_argument("--target", required=True)
    begin.add_argument("--device", default="unknown")
    begin.add_argument("--name", default="")
    for action in ("attempt", "finish", "render"):
        item = sub.add_parser(action)
        item.add_argument("--run", required=True)
        if action != "render":
            item.add_argument("--exit-code", required=action == "finish", type=int)
        if action == "attempt":
            item.add_argument("--number", required=True, type=int)
        if action == "finish":
            item.add_argument("--device", default="unknown")
    merge = sub.add_parser("merge")
    merge.add_argument("--run", action="append", required=True)
    merge.add_argument("--output", required=True)
    args = parser.parse_args()
    if args.action == "start":
        start(args)
    elif args.action == "merge":
        if len(set(map(os.path.realpath, args.run))) != len(args.run):
            parser.error("同一运行目录不能重复计入")
        render(args.run, args.output)
    elif args.action == "render":
        render([args.run], args.run)
    else:
        directory = Path(args.run)
        metadata = read(directory / "run.json")
        if args.action == "attempt":
            existing = next((item for item in metadata["attempts"] if item["number"] == args.number), None)
            if existing is None:
                existing = {"number": args.number, "startedAt": now()}
                metadata["attempts"].append(existing)
            existing["exitCode"] = args.exit_code
            if args.exit_code is not None:
                existing["finishedAt"] = now()
        else:
            metadata.update(exitCode=args.exit_code, finishedAt=now(), device=args.device)
        write(directory / "run.json", metadata)
        if args.action == "finish":
            render([directory], directory)


if __name__ == "__main__":
    main()
