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
    # fallback: two levels up
    return start.resolve().parents[3] if len(start.resolve().parents) >= 3 else start.resolve()


def load_info(args: argparse.Namespace) -> dict:
    if args.info_json and args.info_file:
        raise SystemExit('--info-json and --info-file are mutually exclusive')
    if args.info_json:
        return json.loads(args.info_json)
    if args.info_file:
        p = Path(args.info_file)
        return json.loads(p.read_text(encoding='utf-8'))
    return {}


def main() -> int:
    ap = argparse.ArgumentParser(description='Send a WS request and optionally wait for an event.')
    ap.add_argument('--manager', required=True, help='Manager name, e.g., ContactManager')
    ap.add_argument('--cmd', required=True, help='Command name, e.g., addContact')
    ap.add_argument('--info-json', help='Inline JSON for info')
    ap.add_argument('--info-file', help='Path to a JSON file for info')
    ap.add_argument('--device', help='Device key from config.yaml topics.*')
    ap.add_argument('--topic', help='Override topic (rare); prefer --device')
    ap.add_argument('--id', dest='request_id', help='Request id')
    ap.add_argument('--sequence', type=int, help='Request sequence')
    ap.add_argument('--type', dest='type_', type=int, help='Optional type field')
    ap.add_argument('--obj-id', dest='obj_id', type=int, help='Optional objId field')
    ap.add_argument('--wait-event', help='eventType to wait for after response')
    ap.add_argument('--event-timeout', type=float, default=10.0, help='seconds to wait for event')

    args = ap.parse_args()
    info = load_info(args)

    root = find_repo_root(Path(__file__).parent)
    sys.path.insert(0, str(root))

    from src.tools import ws_client  # type: ignore

    if args.wait_event:
        resp, evt = ws_client.request_and_wait_for_event(
            manager=args.manager,
            cmd=args.cmd,
            info=info,
            event_type=args.wait_event,
            event_timeout=args.event_timeout,
            request_id=args.request_id,
            sequence=args.sequence,
            device=args.device,
            topic=args.topic,
            type_=args.type_,
            obj_id=args.obj_id,
        )
        out = {'response': resp, 'event': evt}
    else:
        resp = ws_client.request(
            manager=args.manager,
            cmd=args.cmd,
            info=info,
            request_id=args.request_id,
            sequence=args.sequence,
            device=args.device,
            topic=args.topic,
            type_=args.type_,
            obj_id=args.obj_id,
        )
        out = resp

    print(json.dumps(out, ensure_ascii=False, indent=2))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
