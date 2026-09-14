"""Public semantic timing API: real resolver, isolated environment configuration."""
import pytest

from src.tools import case_timing as timing, config


def configure(monkeypatch, value):
    monkeypatch.setattr(config, 'get_case_timing_config', lambda: value)


def test_uniform_precedence(monkeypatch):
    options = {'timeout': {'event': 12, 'default': 40,
                           'contact': {'event': 8, 'default': 30}}}
    configure(monkeypatch, options)
    assert timing.seconds('timeout.event', module='contact') == 8
    del options['timeout']['contact']['event']
    assert timing.seconds('timeout.event', module='contact') == 12
    del options['timeout']['event']
    assert timing.seconds('timeout.event', module='contact') == 30
    del options['timeout']['contact']
    assert timing.seconds('timeout.event', module='contact') == 40
    del options['timeout']['default']
    assert timing.seconds('timeout.event', module='contact') == 10


def test_step_scalar_and_module_scalar(monkeypatch):
    configure(monkeypatch, {'step': 2})
    assert timing.seconds('step.interval', module='group') == 2
    configure(monkeypatch, {'step': {'group': 4, 'default': 2}})
    assert timing.seconds('step.interval', module='group') == 4
    assert timing.seconds('step.interval', module='contact') == 2


def test_semantic_offline_overrides_across_modules(monkeypatch):
    configure(monkeypatch, {'settle': {'offline': 7, 'group': {'offline': 9}},
                            'drain': {'offline': 0.7}})
    assert timing.seconds('settle.offline', module='group') == 9
    assert timing.seconds('settle.offline', module='contact') == 7
    for module in ('group', 'contact', 'chat'):
        assert timing.seconds('drain.offline', module=module) == .7


def test_drain_override_cannot_change_positive_message_confirmation(monkeypatch):
    configure(monkeypatch, {'drain': {'default': 0}})
    assert timing.seconds('timeout.event', module='chat') == 10
    assert timing.seconds('drain.offline', module='chat') == 0


def test_modules_are_isolated_and_special_settles_are_independent(monkeypatch):
    configure(monkeypatch, {'timeout': {'contact': {'event': 18}},
                            'settle': {'normal': 7, 'slow': 20}})
    assert timing.seconds('timeout.event', module='contact') == 18
    assert timing.seconds('timeout.event', module='group') == 10
    assert timing.seconds('settle.parent_message', module='group') == 5
    assert timing.seconds('settle.thumbnail_completion', module='chat') == 30


def test_schema_errors_do_not_echo_unknown_keys_or_values(monkeypatch):
    configure(monkeypatch, {'settle': {'PRIVATE_VALUE': 'SECRET'}})
    with pytest.raises(ValueError) as error:
        timing.seconds('step.interval', module='chat')
    assert 'PRIVATE_VALUE' not in str(error.value)
    assert 'SECRET' not in str(error.value)


def test_old_environment_no_longer_changes_semantics(monkeypatch):
    monkeypatch.setenv('CHAT_FRIEND_SETTLE_SECONDS', '999')
    assert timing.seconds('settle.slow', module='chat') == 15


@pytest.mark.parametrize('options', [
    {'typo': {}}, {'timeout': {'evnet': 2}},
    {'timeout': {'contact': {'evnet': 2}}},
    {'timeout': {'contcat': 2}}, {'timeout': []},
    {'settle': {'chat_friend_settle': 12}},
    {'step': True}, {'timeout': {'default': 0}},
    {'drain': {'generic': float('nan')}},
    {'timeout': {'group': {'event': -1}}},
    {'settle': {'normal': None}}, {'poll': {'default': 0}},
])
def test_full_timing_schema_is_validated_even_for_unused_branch(monkeypatch, options):
    configure(monkeypatch, options)
    with pytest.raises(ValueError, match='app.case_timing'):
        timing.seconds('step.interval', module='chat')


@pytest.mark.parametrize('module', ['typo', '', None])
def test_module_must_be_explicit_and_registered(module):
    with pytest.raises(ValueError, match='module'):
        timing.seconds('timeout.event', module=module)


def test_module_argument_is_required():
    with pytest.raises(TypeError):
        timing.seconds('timeout.event')


def test_old_call_site_key_rejected():
    with pytest.raises(ValueError, match='key'):
        timing.seconds('timeout.contact_contact_offline_friendship_establish_friendship_receive_message_timeout', module='contact')


def test_runtime_read_zero_pause_and_numeric_string(monkeypatch):
    options = {'step': '2.5'}
    configure(monkeypatch, options)
    sleeps = []
    monkeypatch.setattr(timing.time, 'sleep', sleeps.append)
    timing.pause(module='chat')
    options['step'] = 0
    timing.pause(module='chat')
    assert sleeps == [2.5]
