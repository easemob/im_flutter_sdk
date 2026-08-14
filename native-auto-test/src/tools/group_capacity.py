"""Group 常规建群容量场景的进程内配置。"""
from __future__ import annotations


DEFAULT_GROUP_CREATE_MAX_COUNT = 200
_group_create_max_count = DEFAULT_GROUP_CREATE_MAX_COUNT


def configure_group_create_max_count(value: int) -> None:
    """选择本次 pytest 进程中常规建群使用的最大成员数。"""
    if value <= 0:
        raise ValueError("group create max count must be positive")

    global _group_create_max_count
    _group_create_max_count = value


def get_group_create_max_count() -> int:
    """返回当前场景的常规建群容量。"""
    return _group_create_max_count


def reset_group_create_max_count() -> None:
    """恢复默认容量，避免同一解释器中的后续 pytest 运行串场。"""
    global _group_create_max_count
    _group_create_max_count = DEFAULT_GROUP_CREATE_MAX_COUNT
