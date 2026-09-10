import importlib.util
from pathlib import Path
from types import SimpleNamespace

import pytest

PATH = Path(__file__).resolve().parents[2] / 'skills/im-flutter-run/scripts/clean_install.py'
spec = importlib.util.spec_from_file_location('clean_install', PATH)
subject = importlib.util.module_from_spec(spec)
spec.loader.exec_module(subject)


def exercise(tmp_path, outputs):
    apk = tmp_path / 'test.apk'
    apk.write_bytes(b'apk')
    calls = []

    def run(args, **kwargs):
        calls.append(args)
        assert kwargs['timeout'] == 120
        value = outputs.pop(0)
        if isinstance(value, tuple):
            return SimpleNamespace(returncode=value[0], stdout='', stderr=value[1])
        return SimpleNamespace(returncode=1 if value is None else 0, stdout=value or '')

    return apk, calls, run


def test_clean_install(tmp_path):
    apk, calls, run = exercise(tmp_path, ['im_flutter_test_a\nOK',
        'package:' + subject.PACKAGE, 'Success', '', '/storage/emulated/0', '',
        'Performing Streamed Install\nSuccess', 'package:' + subject.PACKAGE])
    subject.clean_install('adb', 'emulator-5554', 'im_flutter_test_a', apk, run)
    assert all(c[1:3] == ['-s', 'emulator-5554'] for c in calls)
    assert '/Android/data/' + subject.PACKAGE in calls[5][-1]


@pytest.mark.parametrize('outputs', [
    ['other_avd'],
    ['im_flutter_test_a', 'package:' + subject.PACKAGE, None],
    ['im_flutter_test_a', 'package:' + subject.PACKAGE, 'Failure'],
    ['im_flutter_test_a', '', '', '/'],
    ['im_flutter_test_a', '', '', '/sdcard; echo unsafe'],
    ['im_flutter_test_a', '', '', '/sdcard', None],
    ['im_flutter_test_a', '', '', '/sdcard', '', 'Failure'],
    ['im_flutter_test_a', 'unexpected output'],
])
def test_failure_stops(tmp_path, outputs):
    apk, calls, run = exercise(tmp_path, outputs)
    with pytest.raises(RuntimeError):
        subject.clean_install('adb', 'emulator-5554', 'im_flutter_test_a', apk, run)


def test_absent_package_skips_uninstall(tmp_path):
    apk, calls, run = exercise(tmp_path, ['im_flutter_test_a', '', '', '/sdcard', '',
        'Success', 'package:' + subject.PACKAGE])
    subject.clean_install('adb', 'emulator-5554', 'im_flutter_test_a', apk, run)
    assert not any('uninstall' in c for c in calls)


DENIED = (1, 'rm: private-path: Permission denied; token=private-value')


def recovery_prefix():
    return ['im_flutter_test_a', '', '', '/sdcard', DENIED]


def test_permission_denied_recovers_with_package_manager(tmp_path):
    apk, calls, run = exercise(tmp_path, recovery_prefix() + [
        'Success', 'package:' + subject.PACKAGE, 'Success', 'Success', '', '',
        'Success', 'package:' + subject.PACKAGE])
    subject.clean_install('adb', 'emulator-5554', 'im_flutter_test_a', apk, run)
    assert [c[3:] for c in calls[5:10]] == [
        ['install', str(apk)], ['shell', 'pm', 'list', 'packages', subject.PACKAGE],
        ['shell', 'pm', 'clear', subject.PACKAGE], ['uninstall', subject.PACKAGE],
        ['shell', 'pm', 'list', 'packages', subject.PACKAGE]]
    assert calls[10] == calls[4]  # Recheck cleanup before final installation.
    assert sum(c[3] == 'install' for c in calls) == 2


@pytest.mark.parametrize('recovery', [
    [None], ['Failure'], ['Success', ''],
    ['Success', 'package:' + subject.PACKAGE, 'Failed'],
    ['Success', 'package:' + subject.PACKAGE, 'Success', 'Failure'],
    ['Success', 'package:' + subject.PACKAGE, 'Success', 'Success', 'package:' + subject.PACKAGE],
    ['Success', 'package:' + subject.PACKAGE, 'Success', 'Success', '', DENIED],
])
def test_recovery_failure_never_retries_or_installs_final_apk(tmp_path, recovery):
    apk, calls, run = exercise(tmp_path, recovery_prefix() + recovery)
    with pytest.raises(RuntimeError):
        subject.clean_install('adb', 'emulator-5554', 'im_flutter_test_a', apk, run)
    assert sum(c[3] == 'install' for c in calls) == 1


def test_cleanup_error_identifies_step_without_raw_output(tmp_path):
    apk, calls, run = exercise(tmp_path, ['im_flutter_test_a', '', '', '/sdcard',
        (1, 'private-path token=private-value: I/O error')])
    with pytest.raises(RuntimeError, match='remove external data') as exc:
        subject.clean_install('adb', 'emulator-5554', 'im_flutter_test_a', apk, run)
    assert 'private' not in str(exc.value)
    assert not any(c[3] == 'install' for c in calls)
