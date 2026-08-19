from __future__ import annotations

from contextlib import nullcontext


def _allure_step(name: str):
    """Return an Allure business-step context without coupling tests to Allure."""
    try:
        import allure

        return allure.step(name)
    except ImportError:
        return nullcontext()
