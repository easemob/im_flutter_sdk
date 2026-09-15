#!/usr/bin/env python3
"""Mark cases that failed once but passed on retry as flaky in the Allure results.

After the in-place retry loop, out/allure-results contains one result file per
attempt (same historyId across a case's attempts, written by allure-pytest). This
helper groups results by historyId and, for any case whose latest attempt passed but
an earlier attempt failed/broke, marks the latest (surviving) result as flaky:
  - statusDetails.flaky = true  -> Allure shows the flaky "bomb" marker
  - adds a `reran-passed` tag    -> filterable/searchable in the report
  - records a short note in statusDetails.message

Only the latest passing result is touched, so the report's headline status stays
"passed" while making unstable business cases easy to locate. Cases that never failed
(single result) and cases that never recovered (latest still failed) are left as-is.
Missing/invalid files are skipped; the report generation is unaffected.
"""
import argparse
import glob
import json
import os
from pathlib import Path

FAILED = ('failed', 'broken')
NOTE = '重跑通过：首次失败，重试后通过（疑似不稳定用例）'


def load(path):
    try:
        return json.loads(Path(path).read_text(encoding='utf-8'))
    except (OSError, UnicodeError, ValueError):
        return None


def mark(results_dir):
    groups = {}
    for path in glob.glob(os.path.join(results_dir, '*-result.json')):
        data = load(path)
        if not isinstance(data, dict):
            continue
        key = data.get('historyId') or data.get('testCaseId') or data.get('fullName') or path
        groups.setdefault(key, []).append((data.get('stop') or data.get('start') or 0, path, data))

    marked = 0
    for items in groups.values():
        if len(items) < 2:
            continue
        items.sort(key=lambda item: item[0])
        earlier_statuses = [data.get('status') for _, _, data in items[:-1]]
        _, latest_path, latest = items[-1]
        if latest.get('status') != 'passed':
            continue
        if not any(status in FAILED for status in earlier_statuses):
            continue
        details = latest.get('statusDetails')
        if not isinstance(details, dict):
            details = {}
            latest['statusDetails'] = details
        details['flaky'] = True
        if not details.get('message'):
            details['message'] = NOTE
        labels = latest.setdefault('labels', [])
        if not any(isinstance(l, dict) and l.get('name') == 'tag' and l.get('value') == 'reran-passed' for l in labels):
            labels.append({'name': 'tag', 'value': 'reran-passed'})
        try:
            Path(latest_path).write_text(json.dumps(latest), encoding='utf-8')
            marked += 1
        except OSError:
            pass
    return marked


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('results_dir', help='Allure results directory (out/allure-results)')
    args = parser.parse_args()
    if not os.path.isdir(args.results_dir):
        return
    marked = mark(args.results_dir)
    print(f'==> Flaky-marked {marked} case(s) that passed only after retry (tag: reran-passed)')


if __name__ == '__main__':
    main()
