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
