import json

import pytest

from src.tools import allure_evidence as evidence
from src.tools.response_match import assert_response_matches, ne


def test_redaction_does_not_mutate():
    actual = {'token': 'private', 'body': {'thumbnailSecret': 'private'},
              'url': 'https://x/a?token=private&ok=1'}
    output = evidence.pretty(actual)
    assert 'private' not in output
    assert actual['token'] == 'private'


def test_comparison_failed_step_and_safe_html(monkeypatch):
    import allure
    attached = []
    monkeypatch.setattr(allure, 'attach', lambda body, name, attachment_type: attached.append((name, body)))
    with pytest.raises(AssertionError) as caught:
        assert_response_matches({'result': {'remark': '<script>x</script>', 'token': 'private'}},
                                {'result': {'remark': ne('<script>x</script>'), 'token': 'other'}})
    assert 'private' not in str(caught.value)
    overview = next(body for name, body in attached if name.startswith('00'))
    assert '<script>' not in overview and '&lt;script&gt;' in overview
    assert 'private' not in overview
    rows = json.loads(next(body for name, body in attached if name.startswith('03')))
    assert {r['path'] for r in rows} == {'result.remark', 'result.token'}


def test_observers_preserve_values_and_exceptions(monkeypatch):
    attached = []
    monkeypatch.setattr(evidence, 'attach', lambda name, value: attached.append((name, value)))
    response = {'result': None}
    assert evidence.observe_call('A', 'M', 'cmd', {}, lambda: response, {}) is response
    assert evidence.observe_event('A', {'timeout': 0.1}, lambda: None) is None
    def fail():
        raise ValueError('private detail')
    with pytest.raises(ValueError):
        evidence.observe_call('A', 'M', 'cmd', {}, fail, {})
    assert any('调用异常' in name for name, _ in attached)
    assert 'private detail' not in repr(attached)


def test_missing_extra_type_and_length():
    with pytest.raises(AssertionError) as caught:
        assert_response_matches({'a': 1, 'extra': 2, 'list': [1]},
                                {'a': '1', 'missing': None, 'list': []})
    for path in ('a', 'extra', 'missing', 'list'):
        assert f'"path": "{path}"' in str(caught.value)


def test_step_context_resets_after_exception_and_keeps_unknown_keys(monkeypatch):
    from contextlib import contextmanager
    from src.tools.allure_steps import business_step, report_phase, action_title, event_title
    names = []

    @contextmanager
    def record(title):
        names.append(title)
        yield

    monkeypatch.setattr(evidence, 'step', record)
    with report_phase('call'):
        with pytest.raises(ValueError):
            with business_step('用户 A 操作失败'):
                raise ValueError('same exception')
        with business_step('用户 B 继续校验'):
            pass
    with report_phase('call'):
        with business_step('下一条用例'):
            pass
    assert names == ['步骤 1：用户 A 操作失败', '步骤 2：用户 B 继续校验', '步骤 1：下一条用例']
    assert action_title('deviceC', 'FutureManager', 'unknownMethod') == '用户 C 调用 FutureManager.unknownMethod'
    assert event_title('deviceD', {'match_event_type': 'futureEvent'}) == '用户 D 等待futureEvent 回调'


@pytest.mark.parametrize('route', ['api', 'api_device', 'call_and_wait', 'device_channel'])
def test_public_api_reporting_preserves_call_arguments_and_identity(monkeypatch, route):
    import importlib.util
    from pathlib import Path
    from types import SimpleNamespace
    path = Path(__file__).resolve().parents[1] / 'conftest.py'
    spec = importlib.util.spec_from_file_location('reporting_fixture_contract', path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    monkeypatch.setattr(module, 'get_topic', lambda _: 'topic-a')
    response = {'result': True}
    returned = (response, None) if route == 'call_and_wait' else response
    seen = []

    def invoke(*args, **kwargs):
        seen.append((args, kwargs))
        return returned

    monkeypatch.setattr(module, 'ws_request', invoke)
    monkeypatch.setattr(module, 'ws_request_and_wait_event', invoke)
    info = {'groupId': 'g1'}
    if route == 'device_channel':
        api = module._DeviceChannelWrapper(SimpleNamespace(topic='topic-a', call=invoke), 'deviceA')
    elif route == 'api_device':
        api = module._make_api('deviceA')
    else:
        api = module.api.__wrapped__('topic-a', 'deviceA')
    if route == 'call_and_wait':
        actual = api.call_and_wait_event('GroupManager', 'createGroup', info,
                                        event_type='onGroupInvitationReceived', event_timeout=0.1, sequence=12)
    else:
        actual = api.call('GroupManager', 'createGroup', info, sequence=12)
    assert actual is returned and len(seen) == 1
    args, kwargs = seen[0]
    assert kwargs['sequence'] == 12
    if route == 'device_channel':
        assert args == ('GroupManager', 'createGroup', info) and args[2] is info
    else:
        assert kwargs['info'] is info and kwargs['device'] == 'deviceA' and kwargs['topic'] == 'topic-a'
        if route == 'call_and_wait':
            assert kwargs['event_timeout'] == 0.1 and kwargs['event_type'] == 'onGroupInvitationReceived'
