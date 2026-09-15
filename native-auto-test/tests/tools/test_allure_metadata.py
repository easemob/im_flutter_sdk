"""Allure result contracts using isolated pytest processes without devices."""
import shutil
import json
import os
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
SOURCE = '''import pytest
import allure
@pytest.mark.parametrize("outcome", ["passed", "failed", pytest.param("skipped", marks=pytest.mark.skip(reason="deferred")), pytest.param("xfail", marks=pytest.mark.xfail(reason="known")), "runtime-skip"])
def test_sample(outcome):
    """源码说明：合成场景，非真实IM执行。"""
    with allure.step("真实记录的步骤"):
        allure.attach("evidence-preserved", "实际证据", allure.attachment_type.TEXT)
        if outcome == "runtime-skip": pytest.skip("runtime deferred")
        assert outcome not in ("failed", "xfail"), "intentional failure"
@pytest.fixture
def broken_setup(): raise RuntimeError("setup broken")
def test_setup_error(broken_setup): pass
@pytest.fixture
def broken_teardown():
    yield
    raise RuntimeError("teardown broken")
def test_teardown_error(broken_teardown): pass
def test_unmapped(): pass
'''


def prepare_suite(directory, *, enabled=True):
    directory.mkdir(parents=True, exist_ok=True)
    tests = directory / 'tests/chat'
    tests.mkdir(parents=True)
    (tests / 'test_sample.py').write_text(SOURCE)
    for module, name in [('group', 'test_contract'), ('chat', 'test_placeholder'), ('tools', 'test_tool')]:
        parent = directory / 'tests' / module
        parent.mkdir(exist_ok=True)
        (parent / (name + '.py')).write_text(f'def {name}(): pass\n')
    if enabled:
        (directory / 'conftest.py').write_text(
            'from src.tools import allure_metadata\n'
            'allure_metadata.CASE_PRIORITIES = {}\n'
            'pytest_plugins = ("src.tools.allure_metadata",)\n')
    priorities = {f'tests/chat/test_sample.py::test_sample[{name}]': priority
                  for name, priority in [('passed', 'P0'), ('failed', 'P1'), ('skipped', 'P2'),
                                         ('xfail', 'P0'), ('runtime-skip', 'P1')]}
    priorities.update({'tests/chat/test_sample.py::' + name: 'P0'
                       for name in ['test_setup_error', 'test_teardown_error']})
    if enabled:
        with (directory / 'conftest.py').open('a') as out:
            out.write(f'allure_metadata.CASE_PRIORITIES = {priorities!r}\n')
    return directory


def start_suite(directory, results, *args, source_root=ROOT):
    env = {**os.environ, 'PYTHONPATH': str(source_root), 'PYTEST_DISABLE_PLUGIN_AUTOLOAD': '1',
           'PYTEST_ADDOPTS': '', 'PYTEST_PLUGINS': ''}
    command = [sys.executable, '-m', 'pytest', '-q', '-p', 'allure_pytest.plugin', '-p', 'no:cacheprovider']
    if results is not None: command += ['--alluredir', str(results)]
    return subprocess.Popen(command + list(args or ('tests',)), cwd=directory, env=env,
                            text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)


def finish(process, expected=1):
    stdout, stderr = process.communicate(timeout=35)
    assert process.returncode == expected, stdout + stderr
    return stdout + stderr


def results_by_case(directory):
    rows = [json.loads(path.read_text()) for path in directory.glob('*-result.json')]
    return {(r['fullName'], tuple((p['name'], p['value']) for p in r.get('parameters', []))): r for r in rows}


def labels(result):
    grouped = {}
    for label in result['labels']: grouped.setdefault(label['name'], []).append(label['value'])
    return grouped


def test_real_allure_preserves_outcomes_identity_evidence_and_static_skip(tmp_path):
    enhanced = prepare_suite(tmp_path / 'enhanced')
    baseline = prepare_suite(tmp_path / 'baseline', enabled=False)
    results, original = tmp_path / 'results', tmp_path / 'original'
    finish(start_suite(enhanced, results))
    finish(start_suite(baseline, original))
    actual, before = results_by_case(results), results_by_case(original)
    assert len(actual) == len(before) == 11
    assert actual.keys() == before.keys()
    assert {r['status'] for r in actual.values()} == {'passed', 'failed', 'skipped', 'broken'}
    for key, result in actual.items():
        for field in ['status', 'fullName', 'historyId', 'parameters', 'description', 'descriptionHtml']:
            assert result.get(field) == before[key].get(field), (key, field)
        assert result.get('statusDetails', {}).get('message') == before[key].get('statusDetails', {}).get('message')
        assert [s['name'] for s in result.get('steps', [])] == [s['name'] for s in before[key].get('steps', [])]
        for step in result.get('steps', []):
            for attachment in step.get('attachments', []):
                assert (results / attachment['source']).read_text() == 'evidence-preserved'
        label = labels(result)
        for name in ['parentSuite', 'suite', 'subSuite', 'epic', 'feature', 'story', 'package']:
            assert label.get(name) == labels(before[key]).get(name), (key, name)
        if result['fullName'].endswith('#test_sample'):
            value = result['parameters'][0]['value'].strip("'")
            expected = {'passed': ('P0', 'blocker'), 'failed': ('P1', 'critical'),
                        'skipped': ('P2', 'normal'), 'xfail': ('P0', 'blocker'),
                        'runtime-skip': ('P1', 'critical')}[value]
            assert label['priority'] == [expected[0]] and label['severity'] == [expected[1]]
            assert result['name'] == f'[{expected[0]}] ' + before[key]['name']
        elif any(result['fullName'].endswith('#' + n) for n in ['test_setup_error', 'test_teardown_error']):
            assert label['priority'] == ['P0'] and result['name'].startswith('[P0]')
        else:
            assert 'priority' not in label and 'severity' not in label
            assert result['name'] == before[key]['name']


def test_no_allure_does_not_require_reporting_documents(tmp_path):
    directory = prepare_suite(tmp_path / 'suite')
    finish(start_suite(directory, None, 'tests/tools'), expected=0)


def test_two_processes_keep_all_parameter_results(tmp_path):
    directory = prepare_suite(tmp_path / 'suite')
    results = tmp_path / 'results'
    p0 = start_suite(directory, results, 'tests/chat/test_sample.py::test_sample[passed]', 'tests/chat/test_sample.py::test_sample[skipped]')
    p1 = start_suite(directory, results, 'tests/chat/test_sample.py::test_sample[failed]', 'tests/chat/test_sample.py::test_sample[xfail]')
    finish(p0, expected=0)
    finish(p1, expected=1)
    actual = list(results_by_case(results).values())
    assert len(actual) == len(list(results.glob('*-result.json'))) == 4
    assert len({r['uuid'] for r in actual}) == len({r['historyId'] for r in actual}) == 4
    assert sorted(labels(r)['priority'][0] for r in actual) == ['P0', 'P0', 'P1', 'P2']


def test_repository_registration_and_priority_work_from_another_root(tmp_path):
    # Copy the real registration, but use a synthetic case: deleted business
    # skips must not be required for device-free reporting regression coverage.
    clone = tmp_path / 'clone'
    tests = clone / 'tests'
    tests.mkdir(parents=True)
    shutil.copy2(ROOT / 'tests/conftest.py', tests / 'conftest.py')
    (clone / 'conftest.py').write_text(
        'from pathlib import Path\nfrom src.tools import allure_metadata\n'
        'allure_metadata.ROOT = Path(__file__).parent\n')
    test = tests / 'chat/test_chat_typed_message_pin_flows.py'
    test.parent.mkdir()
    test.write_text('import pytest\n@pytest.mark.skip(reason="synthetic no-device case")\n'
                    '@pytest.mark.parametrize("p", ["sender-location-payload0"])\n'
                    'def test_chat_typed_message_pin_and_cross_user_unpin(p): pass\n')
    node = str(test) + '::test_chat_typed_message_pin_and_cross_user_unpin[sender-location-payload0]'
    results = tmp_path / 'results'
    finish(start_suite(tmp_path, results, '--rootdir', str(tmp_path), node), expected=0)
    result = next(iter(results_by_case(results).values()))
    assert result['status'] == 'skipped'
    assert labels(result)['priority'] == ['P1']
    assert result['name'] == '[P1] test_chat_typed_message_pin_and_cross_user_unpin[sender-location-payload0]'


def test_code_only_copy_needs_no_statistics_documents(tmp_path):
    clone = tmp_path / 'clone'
    tools = clone / 'src/tools'
    tools.mkdir(parents=True)
    for name in ['allure_metadata.py', 'case_priorities.py', 'allure_steps.py', 'allure_evidence.py']:
        shutil.copy2(ROOT / 'src/tools' / name, tools / name)
    (clone / 'conftest.py').write_text('pytest_plugins = ("src.tools.allure_metadata",)\n')
    test = clone / 'tests/chat/test_chat_typed_message_pin_flows.py'
    test.parent.mkdir(parents=True)
    test.write_text('import pytest\n@pytest.mark.skip(reason="no devices")\n'
                    '@pytest.mark.parametrize("p", ["sender-location-payload0"])\n'
                    'def test_chat_typed_message_pin_and_cross_user_unpin(p): pass\n')
    results = tmp_path / 'results'
    finish(start_suite(clone, results, source_root=clone), expected=0)
    result = next(iter(results_by_case(results).values()))
    assert result['status'] == 'skipped'
    assert result['name'] == '[P1] test_chat_typed_message_pin_and_cross_user_unpin[sender-location-payload0]'
    assert not (clone / 'docs').exists()


STEP_SOURCE = '''import pytest
from src.tools.allure_evidence import observe_call, observe_event
from src.tools.allure_steps import business_step
from src.tools.response_match import assert_response_matches

@pytest.fixture
def actors():
    observe_call("deviceA", "Client", "login", {"password":"private-sentinel"}, lambda: {"result": True}, {})
    yield
    observe_call("deviceA", "Client", "logout", {}, lambda: {"result": True}, {})

def test_flow(actors):
    observe_call("deviceA", "GroupManager", "createGroup", {"members":["user-b"]}, lambda: {"result":{"groupId":"g1"}}, {})
    event = {"device":"deviceB", "type":"event", "eventType":"onGroupInvitationReceived", "data":{"groupId":"g1"}}
    actual = observe_event("deviceB", {"match_event_type":"onGroupInvitationReceived"}, lambda: event)
    assert_response_matches(actual, event)
    with business_step("用户 B 接受邀请并校验操作结果"):
        response = observe_call("deviceB", "GroupManager", "acceptInvitationFromGroup", {}, lambda: {"result":True}, {})
        assert_response_matches(response, {"result":True})

def test_no_event(actors):
    assert observe_event("deviceB", {"match_event_type":"onGroupInvitationReceived"}, lambda: None) is None

def test_failed_assertion(actors):
    assert_response_matches({"device":"deviceA", "result":False}, {"device":"deviceA", "result":True})
    observe_call("deviceA", "GroupManager", "destroyGroup", {}, lambda: {}, {})
'''


def test_test_body_has_real_numbered_actions_and_failed_expectations(tmp_path):
    directory = prepare_suite(tmp_path / 'suite')
    (directory / 'tests/chat/test_steps.py').write_text(STEP_SOURCE)
    results = tmp_path / 'results'
    finish(start_suite(directory, results, 'tests/chat/test_steps.py'))
    rows = {r['fullName'].split('#')[-1]: r for r in results_by_case(results).values()}
    flow = rows['test_flow']
    assert flow['status'] == 'passed'
    assert [s['name'] for s in flow['steps']] == [
        '步骤 1：用户 A 创建群组',
        '步骤 2：用户 B 等待群邀请回调',
        '步骤 3：校验用户 B 的群邀请回调是否符合预期',
        '步骤 4：用户 B 接受邀请并校验操作结果',
    ]
    assert [s['name'] for s in flow['steps'][3]['steps']] == [
        '用户 B 接受入群邀请', '校验响应是否符合预期']
    assert rows['test_no_event']['steps'][0]['name'].startswith('步骤 1：')
    assert rows['test_no_event']['status'] == 'passed'
    assert rows['test_failed_assertion']['status'] == 'failed'
    assert len(rows['test_failed_assertion']['steps']) == 1
    assert rows['test_failed_assertion']['steps'][0]['status'] == 'failed'
    assert any(a['name'].startswith('03 字段差异') for a in rows['test_failed_assertion']['steps'][0]['attachments'])
    containers = [json.loads(p.read_text()) for p in results.glob('*-container.json')]
    setups = [b for c in containers for b in c.get('befores', []) if b['name'] == 'actors']
    cleanups = [b for c in containers for b in c.get('afters', [])
                if b['name'].startswith('actors') and b.get('steps')]
    assert len(setups) == len(cleanups) == 3
    assert all(b['steps'][0]['name'] == '前置：用户 A 登录 IM' for b in setups)
    assert all(b['steps'][0]['name'] == '清理：用户 A 退出 IM 登录' for b in cleanups)
    assert all('private-sentinel' not in p.read_text() for p in results.glob('*-attachment.*'))
