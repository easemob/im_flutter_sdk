#!/usr/bin/env python3
from __future__ import annotations
import argparse
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
    ap = argparse.ArgumentParser(description='Delete a test user via REST')
    ap.add_argument('--username', required=True)
    args = ap.parse_args()

    root = find_repo_root(Path(__file__).parent)
    sys.path.insert(0, str(root))

    from src.rest_api.user_api import delete_user  # type: ignore

    try:
        delete_user(args.username)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        return 1
    print('ok')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
