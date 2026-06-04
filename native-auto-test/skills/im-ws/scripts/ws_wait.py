#!/usr/bin/env python3
from __future__ import annotations
import argparse
import json
import sys
from pathlib import Path


def find_repo_root(start: Path) -> Path:
    cur = start.resolve()
    for _ in range(6):
        if (cur / 'pyproject.toml').exists() and (cur / 'src').exists():
            return cur
        if cur.parent == cur:
            break
        cur = cur.parent
    return start.resolve()


def main() -> int:
    ap = argparse.ArgumentParser(description='Wait for a first matching WS message on a topic/device')
    ap.add_argument('--device', help='Device key from config.yaml topics.*')
    ap.add_argument('--topic', help='Override topic (rare); prefer --device')
    ap.add_argument('--cmd', dest='match_cmd', help='Match messages with this cmd (response)')
    ap.add_argument('--event', dest='match_event_type', help='Match type=event messages with this eventType')
    ap.add_argument('--timeout', type=float, default=10.0)

    args = ap.parse_args()

    root = find_repo_root(Path(__file__).parent)
    sys.path.insert(0, str(root))

    from src.tools.ws_client import MessageListener  # type: ignore

    listener = MessageListener(topic=args.topic, device=args.device)
    listener.start()
    msg = listener.receive_message(match_cmd=args.match_cmd, match_event_type=args.match_event_type, timeout=args.timeout)
    listener.stop()

    if msg is None:
        print('{}')
        return 1
    print(json.dumps(msg, ensure_ascii=False, indent=2))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
