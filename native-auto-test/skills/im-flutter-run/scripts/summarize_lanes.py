#!/usr/bin/env python3
"""Combine this run's pytest lane results without parsing terminal output."""
import argparse
from collections import Counter
import json
from pathlib import Path


OUTCOMES = ('passed', 'failed', 'error', 'skipped', 'xfailed', 'xpassed', 'unreported')


def counts_text(results):
    counts = Counter(results)
    return ', '.join(f'{counts[name]} {name}' for name in OUTCOMES)


def summarize(directory, lanes):
    selected = {}
    outcomes = {}
    issues = []
    unsuccessful = False
    print('=== Combined pytest summary (all lanes) ===')
    for lane in range(lanes):
        label = f'lane{lane}'
        try:
            nodeids = (directory / f'{label}.nodeids').read_text(encoding='utf-8').splitlines()
        except (OSError, UnicodeError):
            issues.append(f'{label}: selection manifest missing or unreadable')
            continue
        if any(not nodeid.strip() for nodeid in nodeids):
            issues.append(f'{label}: invalid selection manifest')
            continue
        for nodeid in nodeids:
            if nodeid in selected:
                issues.append(f'{label}: duplicate selected nodeid')
            else:
                selected[nodeid] = lane
        if not nodeids:
            print(f'[lane {lane}] 0 cases (empty shard)')
            continue

        lane_results = {}
        try:
            data = json.loads((directory / f'{label}.result.json').read_text(encoding='utf-8'))
            if (not isinstance(data, dict) or data.get('schema_version') != 1
                    or type(data.get('exitstatus')) is not int
                    or not isinstance(data.get('results'), dict)):
                raise ValueError
            results = data['results']
            if (not set(results).issubset(nodeids)
                    or any(not isinstance(value, str) or value not in OUTCOMES[:-1] for value in results.values())):
                raise ValueError
            lane_results = results
            if data['exitstatus'] != 0:
                unsuccessful = True
                print(f'[lane {lane}] pytest exit={data["exitstatus"]}')
        except (OSError, UnicodeError, ValueError):
            issues.append(f'{label}: pytest result missing or invalid')
        try:
            code = int((directory / f'{label}.exit').read_text(encoding='utf-8').strip())
            if code != 0:
                unsuccessful = True
                print(f'[lane {lane}] runner exit={code}')
        except (OSError, UnicodeError, ValueError):
            issues.append(f'{label}: runner exit code missing or invalid')

        print(f'[lane {lane}] {len(nodeids)} cases | '
              + counts_text(lane_results.get(nodeid, 'unreported') for nodeid in nodeids))
        for nodeid in nodeids:
            if selected[nodeid] == lane:
                outcomes[nodeid] = lane_results.get(nodeid, 'unreported')

    print(f'Total: {len(selected)} | ' + counts_text(outcomes.values()))
    failures = [nodeid for nodeid in selected if outcomes.get(nodeid) in ('failed', 'error')]
    if failures:
        print('Failed cases (all lanes):')
        for nodeid in failures:
            print(f'{outcomes[nodeid].upper()} {nodeid}')
    missing = [nodeid for nodeid in selected if outcomes.get(nodeid) == 'unreported']
    if missing:
        print('Unreported cases (run incomplete):')
        for nodeid in missing:
            print(f'UNREPORTED {nodeid}')
    for issue in issues:
        print(f'INCOMPLETE: {issue}')
    return int(bool(unsuccessful or failures or missing or issues))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('directory', type=Path)
    parser.add_argument('lanes', type=int)
    args = parser.parse_args()
    if args.lanes < 1:
        parser.error('lanes must be positive')
    return summarize(args.directory, args.lanes)


if __name__ == '__main__':
    raise SystemExit(main())
