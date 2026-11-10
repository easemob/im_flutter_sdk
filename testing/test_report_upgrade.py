import csv
import json
import tempfile
import unittest
from pathlib import Path

from report_upgrade import build_report


class UpgradeReportTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.output = self.root / 'output'

    def tearDown(self):
        self.temp.cleanup()

    def write(self, path, value):
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(value), encoding='utf-8')

    def single(self, name='single', status='passed', done=True, config=6):
        directory = self.root / name
        self.write(directory / 'run.json', {
            'runId': name, 'script': 'script_negative.json', 'scriptKind': 'negative',
            'platform': 'android', 'device': 'emulator', 'initOptions': {'dataSyncType': config},
            'startedAt': '2026-11-09T10:00:00Z', 'finishedAt': '2026-11-09T10:00:02Z'})
        self.write(directory / 'steps.json', [
            {'id': 'invalid_cursor', 'api': 'fetchConversations', 'status': status,
             'expected': {'success': False, 'errorCode': 110}, 'actual': {'success': False, 'errorCode': 110}}])
        (directory / 'events.jsonl').write_text(json.dumps({
            'source': 'script.done', 'payload': {'total': 1, 'failed': int(status == 'failed'), 'blocked': 0}}) if done else '')
        return directory

    def multi(self, name='multi', verdict='是', finish=True, attempted=True):
        directory = self.root / name
        directory.mkdir()
        flow = directory / 'scene' / '1' / 'flow-report.json'
        self.write(flow, {'flow': 'scene', 'runId': name, 'steps': [
            {'name': 'invite', 'agent': 'alice', 'status': 'passed' if verdict == '是' else 'failed'}]})
        process = {'runId': name, 'selection': [{'caseName': 'scene', 'roles': {'alice': {'platform': 'android'}}}],
                   'operations': [], 'attempts': [], 'gaps': []}
        if attempted:
            process['operations'] = [{'stage': 'execute', 'result': {'status': 'success', 'data': {
                'caseName': 'scene', 'attempt': 1, 'report': {'path': str(flow)}, 'finish': {'alice': {'success': finish}}}}}]
        self.write(directory / 'process.json', process)
        with (directory / 'statistics.csv').open('w') as file:
            writer = csv.DictWriter(file, fieldnames=['轮次', '执行序号', '用例编号', '平台', '测试方向', '是否通过', '原因'])
            writer.writeheader()
            if attempted:
                writer.writerow({'轮次': name, '执行序号': '1', '用例编号': 'scene', '平台': 'android+ios',
                                 '测试方向': 'positive', '是否通过': verdict, '原因': ''})
        return directory

    def report(self, single=(), multi=()):
        return build_report(single, multi, self.output, '5.1.0')

    def test_expected_api_error_is_a_pass(self):
        report = self.report([self.single()])
        self.assertEqual(report['categories']['single']['counts']['passed'], 1)
        self.assertEqual(report['categories']['multi']['counts']['total'], 0)

    def test_no_completion_event_is_incomplete(self):
        report = self.report([self.single(done=False)])
        self.assertEqual(report['categories']['single']['counts']['incomplete'], 1)

    def test_prepare_failure_is_not_a_business_failure(self):
        directory = self.single(status='not-run', done=False)
        meta = json.loads((directory / 'run.json').read_text())
        meta['executionErrors'] = ['Device unavailable']
        self.write(directory / 'run.json', meta)
        report = self.report([directory])['categories']['single']
        self.assertEqual(report['counts']['not_run'], 1)
        self.assertEqual(report['counts']['failed'], 0)
        self.assertIn('Device unavailable', report['scenarios'][0]['latest']['faults'])

    def test_retries_keep_failures_without_inflating_total(self):
        report = self.report([self.single('first', 'failed'), self.single('retry')])['categories']['single']
        self.assertEqual(report['counts']['total'], 1)
        self.assertEqual(report['counts']['passed'], 1)
        self.assertEqual(report['attemptCount'], 2)
        self.assertEqual(report['scenarios'][0]['attempts'][0]['status'], 'failed')

    def test_different_configuration_is_a_separate_item(self):
        report = self.report([self.single('one', config=1), self.single('six', config=6)])
        self.assertEqual(report['categories']['single']['counts']['total'], 2)

    def test_duplicate_inputs_rejected(self):
        directory = self.single()
        with self.assertRaisesRegex(ValueError, 'Duplicate'):
            self.report([directory, directory])

    def test_completion_counts_must_reconcile(self):
        directory = self.single()
        (directory / 'events.jsonl').write_text(json.dumps({'source': 'script.done', 'payload': {'total': 2}}))
        report = self.report([directory])
        self.assertEqual(report['categories']['single']['counts']['incomplete'], 1)

    def test_multi_cleanup_failure_cannot_be_clean_pass(self):
        report = self.report(multi=[self.multi(finish=False)])['categories']['multi']
        self.assertEqual(report['counts']['incomplete'], 1)
        self.assertFalse(report['scenarios'][0]['latest']['cleanup']['alice']['success'])

    def test_selected_but_unstarted_scene_counted(self):
        report = self.report(multi=[self.multi(attempted=False)])
        self.assertEqual(report['categories']['multi']['counts']['not_run'], 1)

    def test_missing_raw_multi_evidence_cannot_pass(self):
        directory = self.multi()
        (directory / 'scene' / '1' / 'flow-report.json').unlink()
        report = self.report(multi=[directory])
        self.assertEqual(report['categories']['multi']['counts']['incomplete'], 1)

    def test_categories_and_links_are_separate(self):
        report = self.report([self.single('single space')], [self.multi(verdict='否')])
        self.assertEqual(report['categories']['single']['counts']['passed'], 1)
        self.assertEqual(report['categories']['multi']['counts']['failed'], 1)
        content = (self.output / 'upgrade-report.md').read_text()
        self.assertIn('single%20space/steps.json', content)
        self.assertIn('## 单设备', content)
        self.assertIn('## 多设备', content)

    def test_process_fault_warns_even_when_business_scenario_passes(self):
        directory = self.multi()
        process = json.loads((directory / 'process.json').read_text())
        process['operations'].append({'stage': 'cleanup', 'result': {'status': 'failure', 'errors': ['busy']}})
        self.write(directory / 'process.json', process)
        report = self.report(multi=[directory])
        self.assertEqual(report['categories']['multi']['counts']['passed'], 1)
        self.assertEqual(report['overallStatus'], 'abnormal')
        self.assertIn('本次汇总存在异常', (self.output / 'upgrade-report.md').read_text())


if __name__ == '__main__':
    unittest.main()
