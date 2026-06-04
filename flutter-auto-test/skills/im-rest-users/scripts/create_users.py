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
    ap = argparse.ArgumentParser(description='Create test users via REST')
    g = ap.add_mutually_exclusive_group(required=True)
    g.add_argument('--user', nargs='+', help='usernames to create (password defaults to 1 or --password)')
    g.add_argument('--from-file', help='JSON file: an array of {"username","password"}')
    ap.add_argument('--password', default='1', help='default password for --user')
    args = ap.parse_args()

    root = find_repo_root(Path(__file__).parent)
    sys.path.insert(0, str(root))

    from src.rest_api.user_api import create_users  # type: ignore

    users: list[dict[str, str]]
    if args.from_file:
        p = Path(args.from_file)
        users = json.loads(p.read_text(encoding='utf-8'))
    else:
        users = [{"username": u, "password": args.password} for u in args.user]

    try:
        result = create_users(users)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        return 1
    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
