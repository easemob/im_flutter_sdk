"""Offline regression for shared public-room listings."""
import importlib

import pytest

from src.tools import assertions


MODULE = 'tests.chatroom.test_chatroom_server_state'


def test_public_room_lookup_ignores_other_lane_and_checks_target(monkeypatch):
    module = importlib.import_module(MODULE)
    monkeypatch.setattr(module, 'create_chatroom_or_skip', lambda **kw: ('target', 'public-target'))
    deleted = []
    monkeypatch.setattr(module, 'safe_delete_chatroom', deleted.append)
    target = dict(roomId='target', owner='owner', name='public-target', maxUsers=0,
                  permissionType=-1, isAllMemberMuted=False, adminList=[], memberCount=0,
                  muteList=[], muteExpireTimestamp=-1, createTimestamp=0, memberList=[],
                  isInWhitelist=False, blockList=[], desc='', announcement='')

    class Device:
        def __init__(self, wrong_owner=False):
            self.pages = []
            self.wrong_owner = wrong_owner

        def call(self, manager, cmd, info):
            self.pages.append(info['pageNum'])
            if info['pageNum'] == 1:
                rooms = [dict(target, roomId='other', owner='other-lane')]
            else:
                rooms = [dict(target, owner='wrong' if self.wrong_owner else 'owner')]
            return dict(manager=manager, cmd=cmd, device='deviceA', sequence=1,
                        result=dict(count=1, list=rooms))

    device = Device()
    module.test_chatroom_fetch_public_chat_rooms_from_server_success(device, assertions, 'owner')
    assert device.pages == [1, 2]
    with pytest.raises(AssertionError, match='owner'):
        module.test_chatroom_fetch_public_chat_rooms_from_server_success(Device(True), assertions, 'owner')
    assert deleted == ['target', 'target']


def test_public_room_lookup_is_bounded_and_cleans_up(monkeypatch):
    module = importlib.import_module(MODULE)
    monkeypatch.setattr(module, 'create_chatroom_or_skip', lambda **kw: ('missing', 'public-target'))
    deleted = []
    monkeypatch.setattr(module, 'safe_delete_chatroom', deleted.append)
    calls = []

    class Device:
        def call(self, manager, cmd, info):
            calls.append(info['pageNum'])
            return dict(manager=manager, cmd=cmd, device='deviceA', result=dict(
                count=1, list=[dict(roomId='other')]))

    with pytest.raises(pytest.fail.Exception, match='missing'):
        module.test_chatroom_fetch_public_chat_rooms_from_server_success(Device(), assertions, 'owner')
    assert len(calls) <= 100
    assert deleted == ['missing']
