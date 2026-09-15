"""Exercise the real media-combine case with device boundaries replaced."""
from types import SimpleNamespace

import pytest

from tests.chat import test_chat_s423_message_callback_and_combine as cases


@pytest.mark.parametrize('missing', [None, 'local', 'sent', 'parsed'])
def test_media_combine_supplies_thumbnail_and_checks_each_stage(monkeypatch, missing):
    local = '' if missing == 'local' else '/device-a/current-image.jpg'
    remote = '' if missing == 'sent' else 'https://example.invalid/video-thumbnail'
    parsed_remote = '' if missing == 'parsed' else remote
    sends = []
    downloads = []

    def send(*args, type_key, payload):
        sends.append((type_key, payload))
        if type_key == 'image':
            message = {'msgId': 'image-id', 'body': {'type': 1, 'localPath': local}}
        elif type_key == 'video':
            assert payload.get('thumbnailLocalPath') == local and local
            message = {'msgId': 'video-id', 'body': {'type': 2, 'thumbnailRemotePath': remote}}
        else:
            assert payload['msgIds'] == ['image-id', 'video-id']
            message = {'msgId': 'combine-id', 'body': {'type': 8}}
        return {}, message, message

    def parse(*args, **kwargs):
        return {'result': [
            {'msgId': 'image-id', 'body': {'type': 1}},
            {'msgId': 'video-id', 'body': {'type': 2, 'thumbnailRemotePath': parsed_remote}},
        ]}

    monkeypatch.setattr(cases, '_send_with_type', send)
    monkeypatch.setattr(cases, 'timing_pause', lambda *a, **kw: None)
    monkeypatch.setattr(cases, '_assert_combine_thumbnail_download_completed',
                        lambda *a, message, **kw: downloads.append(message))
    device_b = SimpleNamespace(call=parse)
    assertions = SimpleNamespace(assert_response_matches=lambda *a, **kw: None)

    def run():
        cases.test_combine_forward_media_inner_attachment_download(
            object(), device_b, assertions, 'a', 'b')

    if missing:
        expected = {'local': '图片本地路径', 'sent': '发送成功.*缩略图远端地址',
                    'parsed': '合并解析.*缩略图远端地址'}[missing]
        with pytest.raises(AssertionError, match=expected):
            run()
        assert not downloads
        assert len(sends) == {'local': 1, 'sent': 2, 'parsed': 3}[missing]
    else:
        run()
        assert len(downloads) == 1
        assert downloads[0]['msgId'] == 'video-id'
        assert downloads[0]['body']['thumbnailRemotePath'] == remote
