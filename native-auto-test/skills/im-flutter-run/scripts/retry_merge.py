#!/usr/bin/env python3
"""Merge one pytest attempt's per-nodeid outcomes into a cumulative result file.

Used by run.sh's in-place retry loop. Each attempt writes a lane result JSON
(schema_version 1, via scripts/pytest_lane.py). This helper merges that attempt into
a cumulative file so the cumulative always reflects each case's *last* execution
(later attempts override earlier ones). It also writes the still-failing (failed/error)
nodeids to ``--failures-out`` — the exact set to rerun next.

Missing or invalid inputs are tolerated: a missing attempt leaves the cumulative
unchanged (those cases stay failing and are retried again / counted as final failures).
The cumulative is written in the same schema summarize_lanes.py expects.
"""
import argparse
import json
from pathlib import Path

FAILED = ('failed', 'error')


def load_results(path):
    try:
        data = json.loads(Path(path).read_text(encoding='utf-8'))
    except (OSError, UnicodeError, ValueError):
        return {}
    if isinstance(data, dict) and isinstance(data.get('results'), dict):
        return dict(data['results'])
    return {}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--cumulative', required=True, help='cumulative result JSON (created/updated)')
    parser.add_argument('--attempt', required=True, help="this attempt's result JSON (may be absent)")
    parser.add_argument('--failures-out', help='write still-failing nodeids here (one per line)')
    args = parser.parse_args()

    results = load_results(args.cumulative)
    results.update(load_results(args.attempt))  # last execution wins

    failing = [nodeid for nodeid, outcome in results.items() if outcome in FAILED]
    Path(args.cumulative).write_text(json.dumps({
        'schema_version': 1,
        'exitstatus': 1 if failing else 0,
        'results': results,
    }), encoding='utf-8')
    if args.failures_out:
        Path(args.failures_out).write_text(''.join(f'{nodeid}\n' for nodeid in failing), encoding='utf-8')


if __name__ == '__main__':
    main()
