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
    ap = argparse.ArgumentParser(description='Contact flows over WS')
    sub = ap.add_subparsers(dest='cmd', required=True)

    p1 = sub.add_parser('establish-friends')
    p1.add_argument('--initiator-device', required=True)
    p1.add_argument('--peer-device', required=True)
    p1.add_argument('--user-a', required=True)
    p1.add_argument('--user-b', required=True)
    p1.add_argument('--reason', default='flow')

    p2 = sub.add_parser('delete-friend')
    p2.add_argument('--initiator-device', required=True)
    p2.add_argument('--friend-user-id', required=True)
    p2.add_argument('--keep-conversation', action='store_true', default=True)

    p3 = sub.add_parser('get-contacts')
    p3.add_argument('--device', required=True)

    p4 = sub.add_parser('get-block-list')
    p4.add_argument('--device', required=True)

    p5 = sub.add_parser('block')
    p5.add_argument('--device', required=True)
    p5.add_argument('--user-id', required=True)

    p6 = sub.add_parser('unblock')
    p6.add_argument('--device', required=True)
    p6.add_argument('--user-id', required=True)

    args = ap.parse_args()

    root = find_repo_root(Path(__file__).parent)
    sys.path.insert(0, str(root))

    import src.tools.assertions as assert_api  # type: ignore
    from src.tools.ws_client import DeviceConnection  # type: ignore
    from src.test_flow.model_test_flow import ContactTestFlow  # type: ignore

    if args.cmd == 'establish-friends':
        a = DeviceConnection(device=args.initiator_device)
        b = DeviceConnection(device=args.peer_device)
        a.start(); b.start()
        try:
            flow = ContactTestFlow(assert_api)
            a.drain_events(); b.drain_events()
            flow.establish_friends(a, b, args.user_a, args.user_b, reason=args.reason)
            print('ok')
        finally:
            a.stop(); b.stop()
        return 0

    if args.cmd == 'delete-friend':
        a = DeviceConnection(device=args.initiator_device)
        a.start()
        try:
            flow = ContactTestFlow(assert_api)
            a.drain_events()
            flow.delete_friend(a, args.friend_user_id, keep_conversation=args.keep_conversation)
            print('ok')
        finally:
            a.stop()
        return 0

    if args.cmd == 'get-contacts':
        d = DeviceConnection(device=args.device)
        try:
            resp = ContactTestFlow(assert_api).get_all_contacts_from_server(d)
            print(json.dumps(resp, ensure_ascii=False, indent=2))
        finally:
            d.stop()
        return 0

    if args.cmd == 'get-block-list':
        d = DeviceConnection(device=args.device)
        try:
            resp = ContactTestFlow(assert_api).get_block_list(d)
            print(json.dumps(resp, ensure_ascii=False, indent=2))
        finally:
            d.stop()
        return 0

    if args.cmd == 'block':
        d = DeviceConnection(device=args.device)
        d.start()
        try:
            ContactTestFlow(assert_api).add_to_block_list(d, args.user_id)
            print('ok')
        finally:
            d.stop()
        return 0

    if args.cmd == 'unblock':
        d = DeviceConnection(device=args.device)
        try:
            resp = ContactTestFlow(assert_api).remove_from_block_list(d, args.user_id)
            print(json.dumps(resp, ensure_ascii=False, indent=2))
        finally:
            d.stop()
        return 0

    print('unknown command', file=sys.stderr)
    return 1


if __name__ == '__main__':
    raise SystemExit(main())
