#!/usr/bin/env python3
"""Online-validated GitHub Release APK cache (macOS/Linux, stdlib + curl)."""
import argparse
from contextlib import contextmanager
import fcntl
import hashlib
import json
import os
from datetime import datetime, timezone
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import time
from urllib.parse import quote
import uuid


class CacheError(Exception):
    """Safe, user-facing error; never include HTTP bodies or signed URLs."""


def log(message):
    print(f'==> {message}', file=sys.stderr)


def curl_environment():
    return {key: value for key, value in os.environ.items()
            if key not in ('GH_TOKEN', 'GITHUB_TOKEN')}


def parse_http_response(raw):
    # curl --include may include a proxy CONNECT response before the API response.
    status, headers = None, {}
    while raw.startswith(b'HTTP/'):
        block, separator, rest = raw.partition(b'\r\n\r\n')
        if not separator:
            raise CacheError('GitHub returned malformed HTTP headers')
        lines = block.split(b'\r\n')
        match = re.match(rb'HTTP/\S+ (\d{3})(?: |$)', lines[0])
        if not match:
            raise CacheError('GitHub returned malformed HTTP status')
        status = int(match[1])
        headers = {}
        for line in lines[1:]:
            name, colon, value = line.partition(b':')
            if colon:
                headers[name.decode('ascii', errors='ignore').lower()] = value.strip().decode('ascii', errors='ignore')
        raw = rest
    if status is None:
        raise CacheError('GitHub returned malformed HTTP response (invalid JSON or missing headers)')
    return status, headers, raw


def fetch_release(repo):
    token = os.environ.get('GH_TOKEN') or os.environ.get('GITHUB_TOKEN') or ''
    if any(ord(char) < 32 or ord(char) == 127 for char in token):
        raise CacheError('GitHub token contains control characters; re-enter it without line breaks')
    log('GitHub API auth: ' + ('token' if token else 'anonymous'))
    args = [
        'curl', '-q', '-s', '--include', '--max-time', '60', '--proto', '=https',
        '-H', 'Accept: application/vnd.github+json',
        '-H', 'X-GitHub-Api-Version: 2022-11-28',
    ]
    if token:
        args += ['--header', '@-']
    args.append(f'https://api.github.com/repos/{repo}/releases/latest')
    result = subprocess.run(args, capture_output=True, env=curl_environment(),
                            input=('Authorization: Bearer ' + token + '\n').encode() if token else None)
    if result.returncode:
        kind = {5: 'proxy DNS', 6: 'DNS', 7: 'connection', 28: 'timeout',
                35: 'TLS handshake', 60: 'TLS certificate'}.get(result.returncode, 'transport')
        raise CacheError(f'GitHub query failed: {kind} (curl exit {result.returncode}); no stale-cache fallback')
    status, headers, body = parse_http_response(result.stdout)
    if status != 200:
        limited = status == 429 or (status == 403 and (
            headers.get('x-ratelimit-remaining') == '0' or b'rate limit' in body.lower()))
        kind = 'authentication failed; check token validity/expiration' if status == 401 else (
            'rate limit; retry after reset' if limited else 'HTTP request failed; check access/repository')
        details = []
        for name, label in [('x-ratelimit-remaining', 'remaining'), ('x-ratelimit-reset', 'reset'), ('retry-after', 'retry-after')]:
            value = headers.get(name, '')
            if re.fullmatch(r'[0-9]{1,12}', value):
                details.append(f'{label}={value}')
                if label == 'reset':
                    try:
                        details.append('reset-UTC=' + datetime.fromtimestamp(int(value), timezone.utc).isoformat())
                    except (ValueError, OverflowError, OSError):
                        pass
        raise CacheError(f'GitHub HTTP {status}: {kind}; ' + ' '.join(details) + '; no stale-cache fallback')
    try:
        return json.loads(body)
    except (ValueError, UnicodeError):
        raise CacheError('GitHub returned invalid JSON') from None


def download_apk(url, path):
    result = subprocess.run([
        'curl', '-q', '-fL', '--progress-bar', '--max-time', '600',
        '--proto', '=https', '--proto-redir', '=https', '-o', str(path), url,
    ], stdout=sys.stderr, env=curl_environment())
    if result.returncode:
        raise CacheError('APK download failed; no stale-cache fallback')


def identity_for(repo, release):
    try:
        tag = release['tag_name']
        assets = [a for a in release['assets'] if a['name'] == 'app-release.apk']
        if len(assets) != 1:
            raise ValueError()
        asset = assets[0]
        if asset['state'] != 'uploaded':
            raise ValueError()
        for number in (release['id'], asset['id'], asset['size']):
            if type(number) is not int or number <= 0:
                raise ValueError()
        if not isinstance(tag, str) or not tag or any(ord(c) < 32 for c in tag):
            raise ValueError()
        updated = asset['updated_at']
        if not isinstance(updated, str) or not re.fullmatch(r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z', updated):
            raise ValueError()
        digest = asset.get('digest')
        if digest is not None and (not isinstance(digest, str) or not re.fullmatch(r'sha256:[0-9a-f]{64}', digest)):
            raise ValueError()
        url = asset['browser_download_url']
        expected = f'https://github.com/{repo}/releases/download/{quote(tag, safe="")}/app-release.apk'
        # GitHub owner/repository spelling is case insensitive, tag spelling is not.
        prefix = f'https://github.com/{repo}/releases/download/'
        if not isinstance(url, str) or url[:len(prefix)].lower() != prefix.lower() or url[len(prefix):] != expected[len(prefix):]:
            raise ValueError()
        identity = dict(repo=repo, release_id=release['id'], asset_id=asset['id'],
                        updated_at=updated, size=asset['size'], digest=digest)
        return identity, tag, url
    except (KeyError, TypeError, ValueError):
        raise CacheError('Invalid Release metadata or missing/ambiguous uploaded app-release.apk') from None


def sha256(path):
    with path.open('rb') as stream:
        digest = hashlib.sha256()
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(block)
        return digest.hexdigest()


def valid_generation(directory, identity):
    try:
        apk = directory / 'app-release.apk'
        meta = json.loads((directory / 'metadata.json').read_text())
        if not apk.is_file() or apk.is_symlink() or not isinstance(meta, dict):
            return False
        if meta.get('schema') != 1 or meta.get('identity') != identity or meta.get('size') != identity['size']:
            return False
        if apk.stat().st_size != identity['size']:
            return False
        digest = sha256(apk)
        return (meta.get('sha256') == digest == directory.name
                and (identity['digest'] is None or identity['digest'] == 'sha256:' + digest))
    except (OSError, ValueError, TypeError):
        return False


@contextmanager
def repository_lock(path, timeout=60):
    with path.open('a') as stream:
        deadline = time.monotonic() + timeout
        while True:
            try:
                fcntl.flock(stream, fcntl.LOCK_EX | fcntl.LOCK_NB)
                break
            except BlockingIOError:
                if time.monotonic() >= deadline:
                    raise CacheError('APK cache lock timed out') from None
                time.sleep(0.1)
        try:
            yield
        finally:
            fcntl.flock(stream, fcntl.LOCK_UN)


def obtain(repo, cache_dir, refresh=False):
    if not re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9-]*/[A-Za-z0-9_][A-Za-z0-9_.-]*', repo):
        raise CacheError('Invalid repo; expected OWNER/REPO')
    repo = repo.lower()
    log(f'查询 latest Release: {repo}')
    identity, tag, url = identity_for(repo, fetch_release(repo))
    key = hashlib.sha256(json.dumps(identity, sort_keys=True).encode()).hexdigest()
    root = Path(cache_dir).resolve() / repo
    root.mkdir(parents=True, exist_ok=True)
    label = f'{repo} tag={tag} asset={identity["asset_id"]}'
    with repository_lock(root / '.lock'):
        versions = root / key
        versions.mkdir(exist_ok=True)
        if not refresh:
            try:
                current = (versions / 'current').read_text().strip()
            except (OSError, UnicodeError):
                current = ''
            if re.fullmatch(r'[0-9a-f]{64}', current) and valid_generation(versions / current, identity):
                apk = versions / current / 'app-release.apk'
                log(f'APK 缓存命中: {label} {apk}')
                return apk
        reason = '强制刷新' if refresh else '缓存缺失、附件变化或校验失败'
        log(f'下载 APK ({reason}): {label}')
        with tempfile.TemporaryDirectory(prefix='.download-', dir=root) as temporary:
            stage = Path(temporary) / 'generation'
            stage.mkdir()
            apk = stage / 'app-release.apk'
            download_apk(url, apk)
            if not apk.is_file() or apk.stat().st_size != identity['size']:
                raise CacheError('APK size validation failed')
            digest = sha256(apk)
            if identity['digest'] is not None and identity['digest'] != 'sha256:' + digest:
                raise CacheError('APK SHA-256 validation failed')
            meta = dict(schema=1, identity=identity, tag=tag, download_url=url,
                        size=identity['size'], sha256=digest)
            (stage / 'metadata.json').write_text(json.dumps(meta, indent=2) + '\n')
            destination = versions / digest
            if not valid_generation(destination, identity):
                if destination.exists():
                    # Quarantine only a damaged generation; never modify a valid one.
                    destination.rename(Path(temporary) / ('damaged-' + uuid.uuid4().hex))
                stage.rename(destination)
            # Publish selection last: a failed refresh must not select an older generation.
            pointer = Path(temporary) / 'current'
            pointer.write_text(digest + '\n')
            pointer.replace(versions / 'current')
            result = destination / 'app-release.apk'
            log(f'APK 缓存就绪: {label} {result}')
            return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', required=True)
    parser.add_argument('--cache-dir', required=True, type=Path)
    parser.add_argument('--refresh', action='store_true')
    args = parser.parse_args()
    try:
        print(obtain(args.repo, args.cache_dir, args.refresh))
    except (CacheError, OSError) as exc:
        message = str(exc) if isinstance(exc, CacheError) else f'local I/O or tool error ({type(exc).__name__})'
        print(f'error: {message}', file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
