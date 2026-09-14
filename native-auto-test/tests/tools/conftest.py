"""Device-free tooling tests use an empty timing config, never local credentials."""
import pytest

from src.tools import config


@pytest.fixture(autouse=True)
def isolated_case_timing(monkeypatch):
    monkeypatch.setattr(config, "get_case_timing_config", lambda: {})
