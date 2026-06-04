---
name: im-contact-flow
description: |
  High-level contact flows (friendship, block list) built on the WebSocket client.
  Use to orchestrate multi-step contact scenarios across devices/topics using DeviceConnection and ContactTestFlow.
  基于 WebSocket 的联系人业务流（加好友/同意/删除、拉黑/取消拉黑等）。
---

# IM Contact Flow

- Prerequisites
  - Devices logged in on their topics; configure `topics.*` in `config.yaml`.
  - For user provisioning, see `im-rest-users`.
- Quick Use
  - Establish friends: `scripts/contact_flow.py establish-friends --initiator-device device_a --peer-device device_b --user-a A --user-b B`
  - Delete a friend: `scripts/contact_flow.py delete-friend --initiator-device device_a --friend-user-id B`
  - Block / Unblock: `scripts/contact_flow.py block --device device_a --user-id B`

## References
- `src/test_flow/model_test_flow.py` (ContactTestFlow)
- `src/tools/ws_client.py` (DeviceConnection)
- Assertions: `src/tools/assertions.py`
