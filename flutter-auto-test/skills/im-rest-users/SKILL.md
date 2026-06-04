---
name: im-rest-users
description: |
  Manage temporary test users via REST (create/delete). Reads base_url and auth token from config.yaml
  or env REST_AUTH_TOKEN. Use to provision accounts for presence/contact tests.
  通过 REST 创建/删除测试账号；用于用例准备与清理。
---

# IM REST Users

- Prerequisites
  - Configure `rest_api.base_url` and `rest_api.auth_token` in `config.yaml`, or set `REST_AUTH_TOKEN` env.
- Quick Use
  - Create users: `scripts/create_users.py --user u1 u2` (default password `1`)
  - Create from JSON: `scripts/create_users.py --from-file users.json`  # JSON array of {"username","password"}
  - Delete a user: `scripts/delete_user.py --username u1`

## References
- `src/rest_api/user_api.py`
- Project README: README.md
