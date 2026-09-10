#!/usr/bin/env python3
"""收集 pytest 的测试 nodeid 列表（每行一个），用于多 lane 按 case 分片。

用法: collect_cases.py <pytest 路径参数...>
输出: 每行一个 nodeid（如 tests/chatroom/test_x.py::test_y）
"""
import contextlib
import io
import sys

import pytest


class _Collector:
    def __init__(self) -> None:
        self.items: list[str] = []

    def pytest_collection_finish(self, session) -> None:
        self.items = [item.nodeid for item in session.items]


def main() -> None:
    collector = _Collector()
    buf = io.StringIO()
    # 抑制 pytest 的 collect-only 树形输出，只保留 nodeid
    with contextlib.redirect_stdout(buf), contextlib.redirect_stderr(buf):
        result = pytest.main(
            ["--collect-only", "-q", "-p", "no:cacheprovider"] + sys.argv[1:],
            plugins=[collector],
        )
    if result != 0:
        print(buf.getvalue(), file=sys.stderr)
        raise SystemExit(int(result))
    for nodeid in collector.items:
        print(nodeid)


if __name__ == "__main__":
    main()
