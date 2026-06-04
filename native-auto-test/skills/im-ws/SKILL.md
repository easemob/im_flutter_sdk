---
name: im-ws
description: |
  WebSocket request/response and event listening for the Flutter IM SDK demo used by this repo.
  Use when Codex needs to send a {manager, cmd, info} request, wait for the matching response,
  or listen for type=event callbacks on configured topics from config.yaml.
  适用于通过本仓库以 WebSocket 方式调用 Flutter SDK：发送请求、等待响应或接收事件。
---

# IM WebSocket

- Prerequisites
  - Python 3.9+, dependencies installed: `pip install -r requirements.txt`
  - Configure WS in `config.yaml`: `websocket.base_url`, `websocket.default_topic`, optional `topics.*` for multi-device.
- Quick Use
  - Request/Response: `scripts/ws_call.py --manager ContactManager --cmd addContact --info-json '{"userId":"u2"}'`
  - Request + wait event: `scripts/ws_call.py --manager ContactManager --cmd addContact --info-json '{"userId":"u2"}' --wait-event CONTACT_INVITED`
  - Listen for first matching message: `scripts/ws_wait.py --event CONTACT_INVITED`
- Debug flags
  - `WS_DEBUG=1` dump inbound messages; `WS_RELAX=1` loosens event matching (accept any event when filtering by event type).

## When to Use
- Need to quickly exercise a single SDK API over WS.
- Wait for a specific `eventType` after a call (e.g., invitation accepted).
- Inspect push messages on a topic or a named `device` from `config.yaml`.

## Test Authoring Conventions (Chat)
- Minimum ignores: For sync responses, only ignore `sequence`; do not ignore `result`/`error` (nor nested `result.cursor`).
- No self-proof: Never set expected `result` to the actual response; assert meaningful keys.
- No gates: Do not guard with `if evt is not None`; failing to receive the expected event fails the test.
- Lock to a single real response when stable: After discovering with `WS_DEBUG/WS_RELAX`, freeze the exact expected payload and remove any branches/prints. Current locked cases:
  - `ChatManager.getMessage` with invalid `msgId` → `result = None`.
  - `ChatManager.fetchHistoryMessages` with invalid `conversationId` → `result = {"code": 205, "description": "Invalid parameter"}`.
- Pin errors: For nonexistent or not-established conversations, `pinConversation` asserts `error code=107, description="Invalid conversation"` and stops further steps.

## References
- Protocol and helpers: `src/tools/ws_client.py`
- Project README: README.md
