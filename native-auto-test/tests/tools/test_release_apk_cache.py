"""Offline cache contract tests; only the HTTP/download boundary is replaced."""
import copy
import hashlib
import importlib.util
import json
import multiprocessing
import subprocess
import time
from pathlib import Path
import pytest

SCRIPT = Path(__file__).resolve().parents[2] / 'skills/im-flutter-run/scripts/release_apk_cache.py'
BODY = b'release apk fixture'

@pytest.fixture
def cache():
    assert SCRIPT.exists(), 'release cache helper is not implemented'
    spec = importlib.util.spec_from_file_location('release_apk_cache', SCRIPT)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module

@pytest.fixture
def remote():
    return {'id': 10, 'tag_name': 'v1', 'assets': [{
        'id': 20, 'name': 'app-release.apk', 'state': 'uploaded',
        'updated_at': '2026-01-01T00:00:00Z', 'size': len(BODY),
        'digest': 'sha256:' + hashlib.sha256(BODY).hexdigest(),
        'browser_download_url': 'https://github.com/owner/repo/releases/download/v1/app-release.apk',
    }]}

@pytest.fixture
def harness(cache, remote, tmp_path, monkeypatch):
    calls = []
    monkeypatch.setattr(cache, 'fetch_release', lambda repo: copy.deepcopy(remote))
    def download(url, path):
        calls.append(url)
        path.write_bytes(BODY)
    monkeypatch.setattr(cache, 'download_apk', download)
    def obtain(**kwargs):
        return cache.obtain('owner/repo', tmp_path, **kwargs)
    return obtain, calls

def test_download_then_hit(cache, harness):
    obtain, calls = harness
    path = obtain()
    assert path.read_bytes() == BODY
    assert obtain() == path
    assert calls == ['https://github.com/owner/repo/releases/download/v1/app-release.apk']

@pytest.mark.parametrize('field,value', [('id', 21), ('updated_at', '2026-02-01T00:00:00Z')])
def test_attachment_changes_download_again(harness, remote, field, value):
    obtain, calls = harness
    old = obtain()
    remote['assets'][0][field] = value
    assert obtain() != old
    assert len(calls) == 2
    assert old.read_bytes() == BODY

def test_new_release_downloads(harness, remote):
    obtain, calls = harness
    obtain()
    remote['id'] = 11
    obtain()
    assert len(calls) == 2

@pytest.mark.parametrize('damage', ['missing', 'empty', 'same-size', 'metadata', 'pointer'])
def test_damaged_cache_redownloads(harness, damage):
    obtain, calls = harness
    path = obtain()
    if damage == 'missing':
        path.unlink()
    elif damage == 'metadata':
        path.with_name('metadata.json').write_text('{bad')
    elif damage == 'pointer':
        path.parent.parent.joinpath('current').write_text('../invalid')
    else:
        path.write_bytes(b'' if damage == 'empty' else b'x' * len(BODY))
    assert obtain().read_bytes() == BODY
    assert len(calls) == 2

def test_refresh_downloads_even_when_valid(harness):
    obtain, calls = harness
    old = obtain()
    assert obtain(refresh=True) == old
    assert len(calls) == 2

def test_query_failure_never_falls_back(cache, harness, monkeypatch):
    obtain, calls = harness
    old = obtain()
    def fail(repo):
        raise cache.CacheError('GitHub query failed')
    monkeypatch.setattr(cache, 'fetch_release', fail)
    with pytest.raises(cache.CacheError):
        obtain()
    assert old.read_bytes() == BODY
    assert len(calls) == 1

@pytest.mark.parametrize('mode', ['exception', 'truncated', 'digest'])
def test_failed_refresh_preserves_old(cache, harness, monkeypatch, mode):
    obtain, calls = harness
    old = obtain()
    def bad(url, path):
        path.write_bytes(b'x' * (len(BODY) if mode == 'digest' else 1))
        if mode == 'exception':
            raise cache.CacheError('download interrupted')
    monkeypatch.setattr(cache, 'download_apk', bad)
    with pytest.raises(cache.CacheError):
        obtain(refresh=True)
    assert old.read_bytes() == BODY
    assert not list(old.parents[2].glob('.download-*'))

@pytest.mark.parametrize('change', ['missing', 'duplicate', 'size', 'digest', 'latest', 'foreign', 'state'])
def test_invalid_metadata_fails_before_download(cache, harness, remote, change):
    obtain, calls = harness
    asset = remote['assets'][0]
    if change == 'missing': remote['assets'] = []
    elif change == 'duplicate': remote['assets'].append(copy.deepcopy(asset))
    elif change == 'size': asset['size'] = 0
    elif change == 'digest': asset['digest'] = 'sha256:bad'
    elif change == 'latest': asset['browser_download_url'] = 'https://github.com/owner/repo/releases/latest/download/app-release.apk'
    elif change == 'foreign': asset['browser_download_url'] = 'https://evil.example/app-release.apk'
    elif change == 'state': asset['state'] = 'new'
    with pytest.raises(cache.CacheError): obtain()
    assert calls == []

def test_absent_digest_allowed(harness, remote):
    remote['assets'][0]['digest'] = None
    obtain, calls = harness
    assert obtain().read_bytes() == BODY
    obtain()
    assert len(calls) == 1

@pytest.mark.parametrize('repo', ['../repo', 'owner/../repo', 'owner', '/repo', 'owner/repo/'])
def test_invalid_repo(cache, tmp_path, repo):
    with pytest.raises(cache.CacheError): cache.obtain(repo, tmp_path)


def test_repo_isolation(cache, harness, remote, tmp_path):
    obtain, calls = harness
    old = obtain()
    remote['assets'][0]['browser_download_url'] = 'https://github.com/other/repo/releases/download/v1/app-release.apk'
    new = cache.obtain('other/repo', tmp_path)
    assert new != old
    assert new.read_bytes() == old.read_bytes() == BODY
    assert len(calls) == 2


def test_changed_size_and_digest_keep_existing_generation(cache, harness, remote, monkeypatch):
    obtain, calls = harness
    old = obtain()
    body = b'another larger release'
    remote['assets'][0]['size'] = len(body)
    remote['assets'][0]['digest'] = 'sha256:' + hashlib.sha256(body).hexdigest()
    monkeypatch.setattr(cache, 'download_apk', lambda url, path: path.write_bytes(body))
    new = obtain()
    assert new != old
    assert new.read_bytes() == body
    assert old.read_bytes() == BODY


def test_refresh_without_remote_digest_publishes_new_content(cache, harness, remote, monkeypatch):
    remote['assets'][0]['digest'] = None
    obtain, _ = harness
    old = obtain()
    body = b'y' * len(BODY)
    monkeypatch.setattr(cache, 'download_apk', lambda url, path: path.write_bytes(body))
    new = obtain(refresh=True)
    assert new != old
    assert new.read_bytes() == body
    assert old.read_bytes() == BODY
    assert obtain() == new


def test_publish_failure_keeps_old(cache, harness, remote, monkeypatch):
    obtain, _ = harness
    old = obtain()
    remote['assets'][0]['id'] += 1
    original = Path.rename
    def fail_publish(self, target):
        if self.name == 'generation': raise OSError('disk failure')
        return original(self, target)
    monkeypatch.setattr(Path, 'rename', fail_publish)
    with pytest.raises(OSError): obtain()
    assert old.read_bytes() == BODY


@pytest.mark.parametrize('returncode,body', [(22, b''), (28, b''), (0, b'{invalid')])
def test_query_http_or_json_failure(cache, monkeypatch, returncode, body):
    def request(args, **kwargs):
        assert args[-1] == 'https://api.github.com/repos/owner/repo/releases/latest'
        assert args[args.index('--max-time') + 1] == '60'
        return subprocess.CompletedProcess(args, returncode, stdout=body)
    monkeypatch.setattr(cache.subprocess, 'run', request)
    with pytest.raises(cache.CacheError): cache.fetch_release('owner/repo')


def test_download_timeout_contract(cache, monkeypatch, tmp_path):
    def request(args, **kwargs):
        assert args[args.index('--max-time') + 1] == '600'
        assert args[args.index('--proto-redir') + 1] == '=https'
        return subprocess.CompletedProcess(args, 28)
    monkeypatch.setattr(cache.subprocess, 'run', request)
    with pytest.raises(cache.CacheError): cache.download_apk('https://github.com/file', tmp_path / 'apk')


def test_concurrent_obtain_downloads_once(cache, remote, tmp_path, monkeypatch):
    ctx = multiprocessing.get_context('fork')
    downloads = tmp_path / 'downloads'
    monkeypatch.setattr(cache, 'fetch_release', lambda repo: remote)
    def download(url, path):
        with downloads.open('a') as stream: stream.write('download\n')
        time.sleep(0.2)
        path.write_bytes(BODY)
    monkeypatch.setattr(cache, 'download_apk', download)
    def worker():
        assert cache.obtain('owner/repo', tmp_path).read_bytes() == BODY
    workers = [ctx.Process(target=worker) for _ in range(3)]
    for worker_process in workers: worker_process.start()
    for worker_process in workers:
        worker_process.join(5)
        assert worker_process.exitcode == 0
    assert downloads.read_text().splitlines() == ['download']


@pytest.mark.parametrize('gh,github,selected', [('first-secret', 'second-secret', 'first-secret'), ('', 'second-secret', 'second-secret'), ('', '', '')])
def test_api_auth_priority_and_safe_transport(cache, monkeypatch, remote, gh, github, selected):
    monkeypatch.setenv('GH_TOKEN', gh)
    monkeypatch.setenv('GITHUB_TOKEN', github)
    def request(args, **kwargs):
        assert 'first-secret' not in str(args) and 'second-secret' not in str(args)
        assert 'GH_TOKEN' not in kwargs['env'] and 'GITHUB_TOKEN' not in kwargs['env']
        if selected:
            assert kwargs['input'] == ('Authorization: Bearer ' + selected + '\n').encode()
            assert args[args.index('--header') + 1] == '@-'
        else:
            assert not kwargs.get('input')
        return subprocess.CompletedProcess(args, 0, stdout=b'HTTP/1.1 200 Connection established\r\n\r\nHTTP/2 200\r\ncontent-type: application/json\r\n\r\n' + json.dumps(remote).encode())
    monkeypatch.setattr(cache.subprocess, 'run', request)
    assert cache.fetch_release('owner/repo')['id'] == 10


@pytest.mark.parametrize('status,headers,body,expected', [
    (401, '', 'secret-token', 'authentication'),
    (403, 'x-ratelimit-remaining: 0\r\nx-ratelimit-reset: 1788947556\r\n', 'secret-token', 'rate limit'),
    (429, 'retry-after: 60\r\n', 'secret-token', 'rate limit'),
    (404, '', 'secret-token', 'HTTP 404'),
    (200, '', 'not json secret-token', 'invalid JSON'),
])
def test_http_diagnostics_do_not_expose_body(cache, monkeypatch, status, headers, body, expected):
    monkeypatch.setenv('GH_TOKEN', 'secret-token')
    response = f'HTTP/2 {status}\r\n{headers}\r\n{body}'.encode()
    monkeypatch.setattr(cache.subprocess, 'run', lambda *a, **k: subprocess.CompletedProcess(a, 0, stdout=response))
    with pytest.raises(cache.CacheError) as error:
        cache.fetch_release('owner/repo')
    text = str(error.value)
    assert expected in text
    assert 'secret-token' not in text
    if status == 403:
        assert 'remaining=0' in text and '1788947556' in text
    if status == 429:
        assert 'retry-after=60' in text


def test_reject_header_injection_before_request(cache, monkeypatch):
    monkeypatch.setenv('GH_TOKEN', 'secret\r\nInjected: value')
    def unexpected(*a, **k): pytest.fail('must reject before HTTP')
    monkeypatch.setattr(cache.subprocess, 'run', unexpected)
    with pytest.raises(cache.CacheError, match='control'):
        cache.fetch_release('owner/repo')


def test_download_does_not_inherit_tokens(cache, monkeypatch, tmp_path):
    monkeypatch.setenv('GH_TOKEN', 'secret-token')
    monkeypatch.setenv('GITHUB_TOKEN', 'other-token')
    def request(args, **kwargs):
        assert 'GH_TOKEN' not in kwargs['env'] and 'GITHUB_TOKEN' not in kwargs['env']
        assert '--header' not in args and not kwargs.get('input')
        return subprocess.CompletedProcess(args, 0)
    monkeypatch.setattr(cache.subprocess, 'run', request)
    cache.download_apk('https://github.com/file', tmp_path / 'apk')


def test_lock_timeout(cache, tmp_path):
    lock = tmp_path / '.lock'
    with cache.repository_lock(lock):
        with pytest.raises(cache.CacheError, match='lock timed out'):
            with cache.repository_lock(lock, timeout=0): pass
