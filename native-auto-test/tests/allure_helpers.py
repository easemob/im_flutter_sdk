"""Shared Allure helpers for native-auto-test cases."""
from __future__ import annotations

from contextlib import nullcontext


def _allure_step(name: str):
    """Return an Allure step when available, otherwise a no-op context manager."""
    try:
        import allure

        return allure.step(name)
    except ImportError:
        return nullcontext()
