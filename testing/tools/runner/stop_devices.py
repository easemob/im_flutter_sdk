"""Stop only the App sessions authenticated by this run's device manifest."""
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import urllib.request


def stop(run):
    results = []
    opener = urllib.request.build_opener(urllib.request.ProxyHandler({}))
    for device in json.loads((run / 'devices.json').read_text()):
        result = {'role': device['role'], 'stopped': False}
        try:
            # A stale manifest cannot authenticate against a newly started App.
            request = urllib.request.Request(
                device['endpoint'] + '/v1/info',
                headers={'Authorization': 'Bearer ' + device['token']})
            with opener.open(request, timeout=5) as response:
                json.load(response)
            udid = device['udid']
            if device['platform'] == 'ios':
                args = ['xcrun', 'simctl', 'terminate', udid, 'com.example.example']
            else:
                args = ['adb', '-s', udid, 'shell', 'am', 'force-stop', 'com.example.example']
            subprocess.run(args, check=True, capture_output=True, timeout=15)
            result['stopped'] = True
            if device['platform'] == 'android':
                port = device['endpoint'].rsplit(':', 1)[1]
                subprocess.run(['adb', '-s', udid, 'forward', '--remove', 'tcp:' + port],
                               check=True, capture_output=True, timeout=10)
            pid_file = Path(device['log'] + '.pid')
            if pid_file.exists():
                pid = int(pid_file.read_text())
                command = subprocess.run(['ps', '-p', str(pid), '-o', 'command='],
                                         capture_output=True, text=True, timeout=5).stdout
                if udid in command and ('log stream' in command or 'logcat' in command):
                    os.kill(pid, signal.SIGTERM)
        except Exception as error:
            result['error'] = str(error)
        results.append(result)
    (run / 'cleanup.json').write_text(json.dumps(results, indent=2) + '\n')
    return 0 if all(r['stopped'] and 'error' not in r for r in results) else 1


if __name__ == '__main__':
    sys.exit(stop(Path(sys.argv[1])))
