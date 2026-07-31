# IM API Tester (example)

A visual test harness for `im_flutter_sdk`. It lets a human tester — or an AI
agent — call SDK APIs with JSON parameters and inspect the results, for
verifying real data correctness after SDK upgrades.

## Page flow

```
Init page ──init ok──▶ Login page ──login ok──▶ Search page ──tap──▶ API call page
```

- **Init** (one-shot): edit the `EMOptions` JSON template and initialize. Cannot
  be redone without restarting the app.
- **Login**: password or token (toggle). Also hosts logout / re-login; later
  pages can navigate back here.
- **Search**: live, case-insensitive substring matching over API name and group.
- **API call**: pre-filled required-field JSON template → invoke → result JSON
  (copyable). Results are also written to the log.

The full API list is registered in `lib/registry/apis/` — add an `ApiEntry`
there to cover more APIs.

## Logs

Every event (API results, listener callbacks, lifecycle) is emitted as a
single-line JSON record:

```
[APITEST] {"ts":..., "seq":..., "source":"api.EMChatManager.sendMessage", "payload":{...}}
```

- **stdout**: prefixed with `[APITEST]`, easy to grep from `flutter run`.
- **file**: appended to `api_test.log` in the app documents directory; the
  absolute path is printed at startup (`source: "log.path"`). Prefer this
  channel on Android, where logcat may truncate long lines.
- **in-app**: a floating log ball appears after init (drag, open, clear, copy).

## Script mode (AI-friendly)

Run a whole scenario without touching the UI:

```
flutter run --dart-define=API_SCRIPT=/absolute/path/script.json
```

```json
{
  "init":  { "appKey": "your-appkey", "enableUserInfo": true },
  "login": { "userId": "user1", "password": "pass" },
  "steps": [
    { "api": "EMChatManager.sendMessage", "params": { "to": "user2", "chatType": 0, "direction": 0, "status": 0, "body": {"type": 0, "content": "hi"} } },
    { "api": "EMChatManager.downloadBigImage", "params": { "message": "$prev" }, "delayAfterMs": 1000 }
  ]
}
```

- `login` accepts `password` or `token`.
- A param string exactly equal to `"$prev"` is replaced by the previous step's
  `data`.
- Steps run sequentially; a failed step is counted and does not abort the run.
- Ends with `{"source":"script.done","payload":{"total":N,"failed":M}}`; the app
  keeps running so listeners keep logging.
- Without `API_SCRIPT`, the app behaves as the manual tester above.

## Coverage scope

Phase 1 covers the 4.22 additions plus prerequisites (init / login / logout /
sendMessage) — see `lib/registry/apis/`. Model-level additions (senderInfo, big
image fields, voice text, contact/group fields) are verified through API outputs
and event callbacks.
