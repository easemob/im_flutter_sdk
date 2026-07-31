from src.orchestrator import ResourceRegistry


def test_resource_registry_cleans_in_reverse_order_after_case_failure():
    calls: list[str] = []
    registry = ResourceRegistry()
    registry.register(
        kind="account",
        resource_id="user-a",
        cleanup=lambda: calls.append("account"),
    )
    registry.register(
        kind="group",
        resource_id="group-1",
        cleanup=lambda: calls.append("group"),
    )

    try:
        raise AssertionError("simulated case failure")
    except AssertionError:
        results = registry.cleanup_all()

    assert calls == ["group", "account"]
    assert [result.success for result in results] == [True, True]


def test_resource_registry_continues_after_cleanup_failure():
    calls: list[str] = []
    registry = ResourceRegistry()
    registry.register(
        kind="account",
        resource_id="user-a",
        cleanup=lambda: calls.append("account"),
    )

    def fail_group_cleanup():
        calls.append("group")
        raise RuntimeError("delete failed")

    registry.register(
        kind="group",
        resource_id="group-1",
        cleanup=fail_group_cleanup,
    )

    results = registry.cleanup_all()

    assert calls == ["group", "account"]
    assert results[0].success is False
    assert results[0].error == "delete failed"
    assert results[1].success is True
