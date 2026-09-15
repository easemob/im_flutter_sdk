"""好友基线不能掩盖目标关系残留或第三方好友变化。"""
from types import SimpleNamespace

import pytest

from src import Cmd
from src.tools.response_match import compare_response
from tests.contact import test_contact_offline_friendship as cases


def device_with(contacts):
    return SimpleNamespace(call=lambda *args, **kwargs: {
        'manager': 'ContactManager', 'cmd': Cmd.getAllContactsFromServer.value,
        'device': 'deviceA', 'result': contacts,
    })


def assert_response(actual, *, expected, ignore_keys):
    ok, diffs = compare_response(actual, expected, ignore_keys=ignore_keys)
    assert ok, diffs


@pytest.mark.parametrize('expected, actual, passes', [
    ([], ['c'], True),
    (['b'], ['b', 'c'], True),
    (['b'], ['c', 'b'], True),
    ([], ['b', 'c'], False),
    ([], [], False),
    ([], ['c', 'd'], False),
    ([], ['c', 'c'], False),
    (['b'], ['c'], False),
])
def test_full_list_preserves_baseline_and_checks_peer(expected, actual, passes):
    baseline = cases._contact_baseline(device_with(['c']), device_name='deviceA', peer='b')
    def verify():
        cases._assert_contacts(
            device_with(actual), SimpleNamespace(assert_response_matches=assert_response),
            device_name='deviceA', baseline=baseline, expected=expected,
        )
    if passes:
        verify()
    else:
        with pytest.raises(AssertionError):
            verify()
    assert baseline == ['c']


@pytest.mark.parametrize('contacts', [['b', 'c'], None, {'error': 1}, [123]])
def test_invalid_or_unclean_baseline_fails(contacts):
    with pytest.raises(AssertionError):
        cases._contact_baseline(device_with(contacts), device_name='deviceA', peer='b')
