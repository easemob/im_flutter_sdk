"""Exact-nodeid lane selection; leave pytest's argument parsing and output intact."""
import os
from pathlib import Path

import pytest


@pytest.hookimpl(trylast=True)
def pytest_collection_modifyitems(config, items):
    path = os.environ.get("IM_FLUTTER_LANE_NODEIDS")
    if not path:
        return
    selected = set(Path(path).read_text().splitlines())
    kept = [item for item in items if item.nodeid in selected]
    removed = [item for item in items if item.nodeid not in selected]
    items[:] = kept
    if removed:
        config.hook.pytest_deselected(items=removed)
