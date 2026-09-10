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
