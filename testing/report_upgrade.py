#!/usr/bin/env python3
"""Render ignored upgrade reports from explicitly selected single/multi run evidence.

No test is executed. Inputs are ordered oldest to newest; repeated scenario +
platform/configuration items retain all attempts and use the last result.
Outputs: upgrade-report.md (human), upgrade-report.json (machine/reproduction).
"""

import argparse
import csv
import json
import os
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path
from urllib.parse import quote

STATUSES = ("passed", "failed", "skipped", "blocked", "incomplete", "not_run")
LABELS = dict(zip(STATUSES, ("通过", "失败", "跳过", "阻塞", "未完成", "未执行")))


def read_json(path):
    return json.loads(Path(path).read_text(encoding="utf-8"))


def relative(path, output):
    return os.path.relpath(Path(path).resolve(), output)


def counts(items):
    result = dict.fromkeys(STATUSES, 0)
    result.update(Counter(item["status"] for item in items))
    result["total"] = len(items)
    return result


def public_value(value):
    if isinstance(value, dict):
        return {key: "<redacted>" if any(word in key.lower().replace('_', '') for word in
                ('token', 'password', 'clientsecret', 'authorization', 'appkey')) else public_value(item)
                for key, item in value.items()}
    if isinstance(value, list):
        return [public_value(item) for item in value]
    return value


def cleanup_steps(steps):
    return [{"name": step["name"], "api": step.get("api"), "role": step.get("role"), "status": step["status"]}
            for step in steps if str(step.get("api", "")).endswith((".destroyGroup", ".destroyChatRoom", ".logout"))]


def duration(start, finish):
    try:
        return round((datetime.fromisoformat(finish.replace("Z", "+00:00")) -
                      datetime.fromisoformat(start.replace("Z", "+00:00"))).total_seconds(), 3)
    except (ValueError, TypeError, AttributeError):
        return None


def single_run(directory, output):
    meta = read_json(directory / "run.json")
    raw_steps = read_json(directory / "steps.json")
    completion = None
    event_path = directory / "events.jsonl"
    if event_path.exists():
        for line in event_path.read_text(encoding="utf-8").splitlines():
            event = json.loads(line)
            if event.get("source") == "script.done":
                completion = event.get("payload")
    steps = []
    for raw in raw_steps:
        status = {"not-run": "not_run", "crashed": "incomplete"}.get(raw["status"], raw["status"])
        if status not in STATUSES:
            raise ValueError(f"Unknown single step status: {status}")
        steps.append({"name": raw["id"], "api": raw.get("api"), "status": status,
                      "expected": public_value(raw.get("expected")),
                      "actual": public_value(raw.get("actual")) if status != "passed" else None})
    faults = list(meta.get("executionErrors", []))
    crash = directory / "crash.log"
    if crash.exists() and crash.stat().st_size:
        faults.append("存在崩溃、超时或格式异常证据，见 crash.log")
    if meta.get("processExitCode") not in (None, 0) and completion is None:
        faults.append(f"Flutter 进程退出码 {meta['processExitCode']}，未收到 script.done")
    if any(step["status"] == "failed" for step in steps):
        status = "failed"
    elif not any(step["status"] != "not_run" for step in steps):
        status = "not_run"
    elif completion is None or faults or any(step["status"] == "incomplete" for step in steps):
        status = "incomplete"
    elif any(step["status"] == "blocked" for step in steps):
        status = "blocked"
    elif any(step["status"] == "not_run" for step in steps):
        status = "incomplete"
    elif completion.get("total") != len(steps) or completion.get("failed", 0) or completion.get("blocked", 0):
        status = "incomplete"
        faults.append("script.done 与逐步结果不一致")
    else:
        status = "passed" if steps else "not_run"
    return [{
        "category": "single", "scenario": meta["script"], "platform": meta["platform"],
        "configuration": meta.get("initOptions", {"recorded": False, "scriptSha256": meta.get("scriptSha256")}),
        "devices": {"client": meta.get("device", "unknown")}, "direction": meta.get("scriptKind", "unknown"),
        "runId": meta["runId"], "attempt": 1, "status": status,
        "startedAt": meta.get("startedAt"), "finishedAt": meta.get("finishedAt"),
        "durationSeconds": duration(meta.get("startedAt"), meta.get("finishedAt")),
        "sdkVersion": meta.get("sdkVersion", "未记录"), "commit": meta.get("commit"),
        "steps": steps, "stepCounts": counts(steps), "faults": faults,
        "cleanup": {"observedDestroyOrLogout": cleanup_steps(steps),
                    "scope": "仅列已观测的资源销毁/登出操作，不推断未声明资源全部清理成功"},
        "evidence": [relative(directory / name, output) for name in
                     ("run.json", "steps.json", "events.jsonl", "crash.log", "issues.md", "summary.md")
                     if (directory / name).exists()],
    }]


def multi_run(directory, output):
    process = read_json(directory / "process.json")
    with (directory / "statistics.csv").open(encoding="utf-8", newline="") as file:
        rows = list(csv.DictReader(file))
    executions = {}
    faults = []
    for operation in process.get("operations", []):
        result = operation.get("result") or {}
        data = result.get("data") or {}
        if operation.get("stage") in ("execute", "execution") and data.get("caseName"):
            executions[(data["caseName"], data["attempt"])] = (operation, data)
        elif result.get("status") == "failure":
            faults.append({"stage": operation.get("stage"), "errors": result.get("errors", [])})
    faults += [{"stage": "report", "errors": process.get("gaps", [])}] if process.get("gaps") else []
    faults.extend({"stage": "unresolved", "detail": issue.get("detail"), "id": issue.get("id")}
                  for issue in process.get("issues", []) if issue.get("status") != "resolved")
    records = []
    attempt_meta = {(r["caseName"], r["attempt"]): r for r in process.get("attempts", [])}
    verdicts = {"是": "passed", "否": "failed", "未执行": "not_run", "未完成": "incomplete"}
    for row in rows:
        name, number = row["用例编号"], int(row["执行序号"])
        operation, execution = executions.get((name, number), ({}, {}))
        info = attempt_meta.get((name, number), {})
        evidence = [directory / "statistics.csv", directory / "process.json"]
        raw_path = (execution.get("report") or {}).get("path")
        raw = None
        row_faults = [row["原因"]] if row.get("原因") else []
        status = verdicts[row["是否通过"]]
        if raw_path and Path(raw_path).exists():
            raw = read_json(raw_path)
            if raw.get("runId") != process["runId"] or raw.get("flow") != name:
                raise ValueError("Multi flow evidence identity mismatch")
            evidence.append(Path(raw_path))
        elif status in ("passed", "failed"):
            status = "incomplete"
            row_faults.append("已判定场景缺失 flow-report.json，无法复核")
        steps = []
        for step in (raw or {}).get("steps", []):
            status_value = {"timeout": "failed"}.get(step["status"], step["status"])
            if status_value not in STATUSES:
                raise ValueError(f"Unknown multi step status: {status_value}")
            steps.append({"name": step.get("name", step.get("context")), "role": step.get("agent"),
                          "status": status_value, "durationMs": step.get("durationMs"),
                          "reason": step.get("reason"), "kind": step.get("kind"),
                          "api": (step.get("result") or {}).get("api")})
        finish = execution.get("finish", {})
        if any(not item.get("success") for item in finish.values()):
            row_faults.append("设备会话收尾失败，见角色收尾结果")
            if status == "passed":
                status = "incomplete"
        start = (raw or {}).get("startedAt", operation.get("startedAt"))
        end = (raw or {}).get("finishedAt", operation.get("finishedAt"))
        records.append({
            "category": "multi", "scenario": name, "platform": row["平台"],
            "configuration": info.get("configuration", {"recorded": False}),
            "devices": info.get("roles", {}), "direction": row["测试方向"],
            "runId": row["轮次"], "attempt": number, "status": status,
            "startedAt": start, "finishedAt": end, "durationSeconds": duration(start, end),
            "sdkVersion": process.get("sdkVersion", "未记录"),
            "steps": steps, "stepCounts": counts(steps), "faults": row_faults,
            "cleanup": finish or "未记录设备会话收尾；业务资源清理以场景步骤为准",
            "businessCleanup": cleanup_steps(steps),
            "requiredAssertions": [{"binding": r.get("binding"), "passed": r.get("passed")} for r in execution.get("required", [])],
            "evidence": [relative(path, output) for path in evidence],
            "processEvidence": list(dict.fromkeys(relative(ref["path"], output) for ref in info.get("evidence", [])
                                                   if ref.get("path") and Path(ref["path"]).exists())),
        })
    represented = {record["scenario"] for record in records}
    for selection in process.get("selection", []):
        if selection["caseName"] not in represented:
            records.append({"category": "multi", "scenario": selection["caseName"],
                            "platform": "+".join(sorted(set(r.get("platform", "unknown") for r in selection.get("roles", {}).values()))),
                            "configuration": {"recorded": False}, "devices": selection.get("roles", {}),
                            "direction": "unknown", "runId": process["runId"], "attempt": 0,
                            "status": "not_run", "steps": [], "stepCounts": counts([]),
                            "faults": ["已选定但未产生执行记录"], "cleanup": "未执行",
                            "evidence": [relative(directory / "process.json", output)]})
    return records, faults


def compact(value):
    if value is None:
        return "未记录"
    if isinstance(value, (dict, list)):
        value = json.dumps(value, ensure_ascii=False, separators=(",", ":"))
    return str(value).replace("|", "&#124;").replace("\n", "<br>")


def link(path, label=None):
    return f"[{compact(label or Path(path).name)}](<{quote(path, safe='/.-_')}>)"


def build_report(single, multi, output, version=None):
    output = Path(output).resolve()
    inputs, records, faults = [], [], []
    for kind, paths in (("single", single), ("multi", multi)):
        seen = set()
        for source in paths:
            source = Path(source).resolve()
            if source in seen:
                raise ValueError(f"Duplicate {kind} input: {source}")
            seen.add(source)
            inputs.append({"category": kind, "directory": relative(source, output)})
            if kind == "single":
                records.extend(single_run(source, output))
            else:
                items, run_faults = multi_run(source, output)
                records.extend(items)
                faults.extend({"run": relative(source, output), "detail": item} for item in run_faults)
    groups = {}
    for record in records:
        key = (record["category"], record["scenario"], record["platform"],
               json.dumps(record["configuration"], sort_keys=True), json.dumps(record["devices"], sort_keys=True))
        groups.setdefault(key, []).append(record)
    categories = {}
    for category in ("single", "multi"):
        cases = [{"latest": history[-1], "attempts": history} for key, history in groups.items() if key[0] == category]
        categories[category] = {"counts": counts([case["latest"] for case in cases]),
                                "attemptCount": sum(len(case["attempts"]) for case in cases), "scenarios": cases}
    report = {"schemaVersion": 1, "generatedAt": datetime.now(timezone.utc).isoformat(),
              "targetVersion": version or "未指定（以各运行记录为准）", "inputs": inputs,
              "categories": categories, "executionFaults": faults}
    current = [case["latest"] for category in categories.values() for case in category["scenarios"]]
    if not current:
        overall = "未形成可判定的场景结果；请查看执行故障。"
        report["overallStatus"] = "incomplete"
    elif faults or any(item["status"] != "passed" or item["faults"] for item in current):
        overall = "本次汇总存在异常：有场景未通过/未完成/未执行，或存在执行、收尾故障；不能视作全部通过。"
        report["overallStatus"] = "abnormal"
    elif any(item["status"] != "passed" or item["faults"] for item in records):
        overall = "当前选测结果通过，但存在历史失败或异常尝试，详见各场景执行记录。"
        report["overallStatus"] = "passed_with_history"
    else:
        overall = "本报告纳入的选测场景通过；未纳入的类别和平台不在本次结论范围。"
        report["overallStatus"] = "passed"
    lines = ["# 版本升级测试报告", "", f"目标版本：{compact(report['targetVersion'])}",
             f"生成时间：{report['generatedAt']}", "", f"**{overall}**", "",
             "仅统计下列显式输入批次；单设备与多设备分别计数，步骤数不与场景数相加。",
             "同场景、平台、设备及配置的复验保留全部记录，以输入顺序最后一次为当前结果；不代表未选平台或完整版本验收。", "",
             "| 分类 | 场景总数 | 通过 | 失败 | 跳过 | 阻塞 | 未完成 | 未执行 | 尝试记录 |",
             "|---|---:|---:|---:|---:|---:|---:|---:|---:|"]
    for kind, title in (("single", "单设备"), ("multi", "多设备")):
        category = categories[kind]
        c = category["counts"]
        lines.append(f"| {title} | {c['total']} | " + " | ".join(str(c[s]) for s in STATUSES) + f" | {category['attemptCount']} |")
    lines += ["", f"执行故障记录：{len(faults)}（另见各场景异常；不计作业务断言失败）。", "", "## 纳入的原始批次", ""]
    lines.extend(f"- {'单设备' if i['category'] == 'single' else '多设备'}：{link(i['directory'], i['directory'])}" for i in inputs)
    for kind, title in (("single", "单设备"), ("multi", "多设备")):
        lines += ["", f"## {title}", ""]
        if not categories[kind]["scenarios"]:
            lines.append("本报告未纳入此类别的场景，不计为通过。")
        for case in categories[kind]["scenarios"]:
            item = case["latest"]
            lines += [f"### {compact(item['scenario'])}", "",
                      f"当前结果：**{LABELS[item['status']]}**；平台：{compact(item['platform'])}；方向：{compact(item['direction'])}；尝试记录：{len(case['attempts'])}。",
                      f"角色／设备：{compact(item['devices'])}",
                      f"配置记录：{compact(item['configuration'])}（仅已采集值；Sha256 是定义标识，不是参数值；recorded=false 表示未采集）",
                      f"SDK 版本：{compact(item.get('sdkVersion'))}；时间：{compact(item.get('startedAt'))} → {compact(item.get('finishedAt'))}；耗时：{compact(item.get('durationSeconds'))} 秒。",
                      "", "| 步骤总数 | 通过 | 失败 | 跳过 | 阻塞 | 未完成 | 未执行 |", "|---:|---:|---:|---:|---:|---:|---:|",
                      "| " + " | ".join(str(item["stepCounts"][s]) for s in ("total",) + STATUSES) + " |", "",
                      f"{'设备会话收尾' if kind == 'multi' else '资源收尾'}：{compact(item['cleanup'])}",
                      *([f"已观测业务资源销毁/登出：{compact(item.get('businessCleanup'))}"] if kind == 'multi' else []), "",
                      "| 步骤 | 角色／API | 结果 | 耗时 ms |", "|---|---|---|---:|"]
            lines.extend(f"| {compact(step['name'])} | {compact(step.get('role') or step.get('api'))} | {LABELS[step['status']]} | {compact(step.get('durationMs'))} |" for step in item["steps"])
            for step in item["steps"]:
                if step["status"] not in ("passed", "skipped"):
                    lines += ["", f"失败／未完成步骤 `{compact(step['name'])}`：{compact(step.get('reason'))}",
                              f"预期：{compact(step.get('expected'))}", f"实际：{compact(step.get('actual'))}"]
            if item.get("requiredAssertions"):
                lines += ["", "核心断言：" + compact(item["requiredAssertions"])]
            lines += ["", "执行记录与证据：", ""]
            for attempt in case["attempts"]:
                lines.append(f"- `{attempt['runId']}` / {attempt['attempt']}：{LABELS[attempt['status']]}；" + " · ".join(link(p) for p in attempt["evidence"]))
                lines.extend(f"  - 异常：{compact(fault)}" for fault in attempt["faults"])
                if attempt.get("processEvidence"):
                    lines.append("  - 过程证据：" + " · ".join(link(p) for p in attempt["processEvidence"]))
    if faults:
        lines += ["", "## 执行故障", ""]
        lines.extend(f"- {link(fault['run'])}：{compact(fault['detail'])}" for fault in faults)
    lines += ["", "结构化汇总：[upgrade-report.json](upgrade-report.json)。输入列表可用于再次生成；生成时间不代表重新执行测试。", ""]
    output.mkdir(parents=True, exist_ok=True)
    (output / "upgrade-report.json").write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    (output / "upgrade-report.md").write_text("\n".join(lines), encoding="utf-8")
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--single", action="append", default=[], metavar="RUN_DIR", help="Single-device evidence directory; repeat oldest to newest")
    parser.add_argument("--multi", action="append", default=[], metavar="RUN_DIR", help="Multi-device evidence directory; repeat oldest to newest")
    parser.add_argument("--output", required=True, help="Git-ignored output directory")
    parser.add_argument("--version", help="Target label, not proof of the native version")
    args = parser.parse_args()
    if not args.single and not args.multi:
        parser.error("at least one --single or --multi input is required")
    try:
        report = build_report(args.single, args.multi, args.output, args.version)
    except (OSError, ValueError, KeyError, TypeError) as error:
        parser.exit(1, f"Upgrade report generation failed: {error}\n")
    print(f"Upgrade report: {Path(args.output).resolve() / 'upgrade-report.md'}")
    print(f"Structured results: {Path(args.output).resolve() / 'upgrade-report.json'}")
    for kind in ("single", "multi"):
        print(f"{kind}: {json.dumps(report['categories'][kind]['counts'], ensure_ascii=False)}")


if __name__ == "__main__":
    main()
