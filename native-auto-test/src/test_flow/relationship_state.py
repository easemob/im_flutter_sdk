"""Scoped relationship preparation for existing session users."""
from copy import deepcopy
import time

from src import Cmd
from src.tools.case_timing import seconds
from src.tools.response_match import _Matcher, compare_response
from src.test_flow.friendship_setup import ensure_friendship
from src.test_flow.offline_test_flow import restore_user_login


class ExactItems(_Matcher):
    """Compare unordered lists including duplicates and complete item fields."""
    def __init__(self, expected):
        super().__init__('eq', self._equal, deepcopy(expected))

    @staticmethod
    def _equal(actual, expected):
        if not isinstance(actual, list) or len(actual) != len(expected):
            return False
        remaining = list(actual)
        for item in expected:
            for index, candidate in enumerate(remaining):
                if compare_response(candidate, item, ignore_keys={'updatedAt'})[0]:
                    remaining.pop(index)
                    break
            else:
                return False
        return True

    def describe(self):
        return f'完整无序列表（保留重复项校验）: {self._threshold!r}'


class RelationshipState:
    def __init__(self, device_a, device_b, assert_api, user_a, user_b):
        self.devices = (device_a, device_b)
        self.users = (user_a, user_b)
        self.api = assert_api
        self.contacts = [self.read_ids(i) for i in range(2)]
        self.blocks = [self.read_ids(i, Cmd.getBlockListFromServer.value) for i in range(2)]
        self.remarks = [self.read_remark(i) if self.users[1-i] in self.contacts[i] else None
                        for i in range(2)]
        self.records = None

    def call(self, side, cmd, info=None, expected=None):
        response = self.devices[side].call('ContactManager', cmd, info=info or {})
        self.api.assert_response_matches(
            response, expected={'manager': 'ContactManager', 'cmd': cmd,
                                'device': ('deviceA', 'deviceB')[side], 'result': expected},
            ignore_keys={'sequence'},
        )
        return response['result']

    def read_ids(self, side, cmd=Cmd.getAllContactsFromServer.value):
        return list(self.call(side, cmd, expected=_Matcher(
            'type', lambda x, _: isinstance(x, list) and all(type(v) is str for v in x), 'list[str]')))

    def read_remark(self, side):
        result = self.call(side, Cmd.getContact.value, {'userId': self.users[1-side]}, expected=_Matcher(
            'contact', lambda x, uid: isinstance(x, dict) and x.get('userId') == uid
            and isinstance(x.get('remark', ''), str), self.users[1-side]))
        return result.get('remark', '')

    def ids(self, side, *, friends):
        others = [uid for uid in self.contacts[side] if uid != self.users[1-side]]
        return ExactItems(others + ([self.users[1-side]] if friends else []))

    def block_ids(self, side, *, blocked):
        others = [uid for uid in self.blocks[side] if uid != self.users[1-side]]
        return ExactItems(others + ([self.users[1-side]] if blocked else []))

    def unblock(self):
        for side in range(2):
            peer = self.users[1-side]
            if peer in self.read_ids(side, Cmd.getBlockListFromServer.value):
                self.call(side, Cmd.removeUserFromBlockList.value, {'userId': peer}, expected=peer)

    def clear_pending(self):
        # Decline is idempotent on this SDK; consume both directions, then drain callbacks.
        for side in range(2):
            peer = self.users[1-side]
            self.call(side, Cmd.declineInvitation.value, {'userId': peer}, expected=peer)
        self.drain()

    def ensure_absent(self):
        self.unblock()
        for side in range(2):
            peer = self.users[1-side]
            if peer in self.read_ids(side):
                self.call(side, Cmd.deleteContact.value,
                          {'userId': peer, 'keepConversation': True}, expected=peer)
        self.wait_relation(False)
        self.drain()

    def ensure_present(self):
        self.unblock()
        ensure_friendship(*self.devices, self.api, *self.users)

    def wait_relation(self, present):
        deadline = time.monotonic() + seconds('timeout.friend_ready', module='chat')
        while time.monotonic() < deadline:
            lists = [self.read_ids(i) for i in range(2)]
            if all((self.users[1-i] in lists[i]) == present for i in range(2)):
                return
            time.sleep(seconds('poll.server_state', module='chat'))
        raise AssertionError(f'好友前置未达到双端目标状态：friends={present}')

    def drain(self):
        for device in self.devices:
            device.drain_events(timeout=seconds('drain.offline', module='contact'))

    def capture_records(self):
        self.records = deepcopy(self.call(0, Cmd.fetchAllContacts.value, expected=_Matcher(
            'contacts', lambda x, _: isinstance(x, list)
            and all(isinstance(v, dict) and isinstance(v.get('userId'), str) for v in x), 'contacts')))
        assert ExactItems(self.contacts[0]).check([v['userId'] for v in self.records]), '好友对象与 ID 基线不一致'

    def expected_records(self, remark):
        assert self.records is not None
        records = deepcopy(self.records)
        for item in records:
            if item['userId'] == self.users[1]:
                item['remark'] = remark
        return ExactItems(records)

    def assert_pages(self, remark, *, page_size=20):
        cursor, seen, items = '', set(), []
        deadline = time.monotonic() + seconds('timeout.friend_ready', module='chat')
        while time.monotonic() < deadline:
            response = self.devices[0].call('ContactManager', Cmd.fetchContacts.value,
                                           info={'cursor': cursor, 'pageSize': page_size})
            result = response.get('result')
            list_shape = _Matcher('contacts', lambda x, _: isinstance(x, list)
                                 and all(isinstance(v, dict) and isinstance(v.get('userId'), str) for v in x), 'contacts')
            expected = list_shape if isinstance(result, list) else {
                'list': list_shape, 'cursor': _Matcher('type', lambda x, _: x is None or type(x) is str, 'str | None')}
            self.api.assert_response_matches(
                response, expected={'manager': 'ContactManager', 'cmd': Cmd.fetchContacts.value,
                                    'device': 'deviceA', 'result': expected}, ignore_keys={'sequence'})
            items.extend(result if isinstance(result, list) else result['list'])
            cursor = '' if isinstance(result, list) else (result['cursor'] or '')
            if not cursor:
                assert self.expected_records(remark).check(items), '分页好友列表与基线不一致'
                return
            assert cursor not in seen, '分页 cursor 未前进'
            seen.add(cursor)
        raise AssertionError('好友分页未在限定时间内结束')

    def restore(self):
        # The fixture finalizer reports failures rather than silently claiming cleanup succeeded.
        for device, user in zip(self.devices, self.users):
            restore_user_login(device, user_id=user, module='contact')
        self.unblock()
        if any(self.users[1-i] in self.contacts[i] for i in range(2)):
            self.ensure_present()
            for side, remark in enumerate(self.remarks):
                if remark is not None:
                    self.call(side, Cmd.setContactRemark.value,
                              {'userId': self.users[1-side], 'remark': remark})
        else:
            self.clear_pending()
            self.ensure_absent()
        for side in range(2):
            peer = self.users[1-side]
            if peer in self.blocks[side]:
                self.call(side, Cmd.addUserToBlockList.value, {'userId': peer}, expected=peer)
        deadline = time.monotonic() + seconds('timeout.friend_ready', module='chat')
        while time.monotonic() < deadline:
            restored = all(
                ExactItems(self.contacts[i]).check(self.read_ids(i))
                and ExactItems(self.blocks[i]).check(self.read_ids(i, Cmd.getBlockListFromServer.value))
                and (self.remarks[i] is None or self.read_remark(i) == self.remarks[i])
                for i in range(2)
            )
            if restored:
                self.drain()
                return
            time.sleep(seconds('poll.server_state', module='chat'))
        raise AssertionError('清理后好友/黑名单/备注 result 未恢复到原基线')
