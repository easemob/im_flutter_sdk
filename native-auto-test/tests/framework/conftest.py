from __future__ import annotations

import pytest


@pytest.fixture(scope="session", autouse=True)
def global_login_logout():
    """Framework 单测不连接真实 Runner。"""
    yield
