
# Simple task runner for repo-local skills
# Usage: make <target> [VAR=VALUE ...]

PY ?= python3
SKILL_CREATOR ?= $(HOME)/.codex/skills/.system/skill-creator
ADB ?= adb
WS_HOST ?= 127.0.0.1
WS_PORT ?= 4000
WS_PATH ?= /iov/websocket/dual
WS_STATE_DIR ?= $(CURDIR)/.local

.PHONY: help ws-bridge-up ws-bridge-down test-local ws-bridge-local ws-bridge-reverse \
        ws-call ws-wait create-users delete-user \
        contact-establish contact-delete contact-block contact-unblock \
        skills-validate test test-allure test-html test-chat-strict test-chat-discover clean

help:
	@echo "Available targets:"
	@echo "  ws-bridge-up       Start relay, configure emulator reverse, write local env"
	@echo "  ws-bridge-down     Remove reverse and stop the managed local relay"
	@echo "  test-local         Run pytest with generated local WS env [ARGS]"
	@echo "  ws-bridge-local    Start local topic relay [WS_HOST, WS_PORT, WS_PATH]"
	@echo "  ws-bridge-reverse  Reverse WS_PORT for online Android emulators [ADB]"
	@echo "  ws-call            MANAGER, CMD [, INFO, DEVICE, TOPIC, EVENT, EVENT_TIMEOUT]"
	@echo "  ws-wait            [DEVICE, TOPIC] (one of CMD or EVENT)"
	@echo "  create-users       USERS='u1 u2' or FROM_FILE=users.json [PASSWORD=1]"
	@echo "  delete-user        USERNAME=u1"
	@echo "  contact-establish  INITIATOR_DEVICE=... PEER_DEVICE=... USER_A=... USER_B=... [REASON=flow]"
	@echo "  contact-delete     INITIATOR_DEVICE=... FRIEND_USER_ID=... [KEEP_CONVERSATION=1]"
	@echo "  contact-block      DEVICE=... USER_ID=..."
	@echo "  contact-unblock    DEVICE=... USER_ID=..."
	@echo "  skills-validate    Validate skill folders under skills/"
	@echo "  test               Run pytest (pass ARGS=... to forward extra args)"
	@echo "  test-allure        Run pytest with --alluredir=out/allure-results"
	@echo "  test-html          Run pytest with HTML report to out/report.html"

# --- Local WebSocket relay ---
ws-bridge-up:
	PY="$(PY)" ADB="$(ADB)" WS_HOST="$(WS_HOST)" WS_PORT="$(WS_PORT)" \
	  WS_PATH="$(WS_PATH)" WS_STATE_DIR="$(WS_STATE_DIR)" \
	  bash scripts/ws_bridge_local.sh up

ws-bridge-down:
	PY="$(PY)" ADB="$(ADB)" WS_HOST="$(WS_HOST)" WS_PORT="$(WS_PORT)" \
	  WS_PATH="$(WS_PATH)" WS_STATE_DIR="$(WS_STATE_DIR)" \
	  bash scripts/ws_bridge_local.sh down

test-local:
	@test -f "$(WS_STATE_DIR)/ws-bridge.env" || { \
	  echo "本地 WebSocket 环境不存在，请先执行 make ws-bridge-up"; exit 2; \
	}
	@PY="$(PY)" WS_HOST="$(WS_HOST)" WS_PORT="$(WS_PORT)" \
	  WS_PATH="$(WS_PATH)" WS_STATE_DIR="$(WS_STATE_DIR)" \
	  bash scripts/ws_bridge_local.sh check
	@set -a; . "$(WS_STATE_DIR)/ws-bridge.env"; set +a; \
	  $(PY) -m pytest $(ARGS)

ws-bridge-local:
	$(PY) -m src.tools.ws_relay_server \
	  --host "$(WS_HOST)" --port "$(WS_PORT)" --path "$(WS_PATH)"

ws-bridge-reverse:
	ADB="$(ADB)" WS_PORT="$(WS_PORT)" bash scripts/adb_reverse_ws_bridge.sh

# --- WebSocket calls ---
ws-call:
	@[ -n "$(MANAGER)" ] || { echo "MANAGER is required"; exit 2; }
	@[ -n "$(CMD)" ] || { echo "CMD is required"; exit 2; }
	$(PY) skills/im-ws/scripts/ws_call.py \
	  --manager "$(MANAGER)" --cmd "$(CMD)" \
	  $(if $(INFO),--info-json '$(INFO)') \
	  $(if $(DEVICE),--device "$(DEVICE)") \
	  $(if $(TOPIC),--topic "$(TOPIC)") \
	  $(if $(ID),--id "$(ID)") \
	  $(if $(SEQUENCE),--sequence $(SEQUENCE)) \
	  $(if $(TYPE),--type $(TYPE)) \
	  $(if $(OBJ_ID),--obj-id $(OBJ_ID)) \
	  $(if $(EVENT),--wait-event "$(EVENT)") \
	  $(if $(EVENT_TIMEOUT),--event-timeout $(EVENT_TIMEOUT))

ws-wait:
	@if [ -z "$(CMD)" ] && [ -z "$(EVENT)" ]; then echo "One of CMD or EVENT is required"; exit 2; fi
	$(PY) skills/im-ws/scripts/ws_wait.py \
	  $(if $(DEVICE),--device "$(DEVICE)") \
	  $(if $(TOPIC),--topic "$(TOPIC)") \
	  $(if $(CMD),--cmd "$(CMD)") \
	  $(if $(EVENT),--event "$(EVENT)") \
	  $(if $(TIMEOUT),--timeout $(TIMEOUT))

# --- REST user provisioning ---
create-users:
	@if [ -n "$(USERS)" ]; then \
	  $(PY) skills/im-rest-users/scripts/create_users.py --user $(USERS) $(if $(PASSWORD),--password $(PASSWORD)); \
	elif [ -n "$(FROM_FILE)" ]; then \
	  $(PY) skills/im-rest-users/scripts/create_users.py --from-file $(FROM_FILE); \
	else \
	  echo "USERS='u1 u2' or FROM_FILE=users.json is required"; exit 2; \
	fi

delete-user:
	@[ -n "$(USERNAME)" ] || { echo "USERNAME is required"; exit 2; }
	$(PY) skills/im-rest-users/scripts/delete_user.py --username $(USERNAME)

# --- Contact flows ---
contact-establish:
	@[ -n "$(INITIATOR_DEVICE)" ] || { echo "INITIATOR_DEVICE is required"; exit 2; }
	@[ -n "$(PEER_DEVICE)" ] || { echo "PEER_DEVICE is required"; exit 2; }
	@[ -n "$(USER_A)" ] || { echo "USER_A is required"; exit 2; }
	@[ -n "$(USER_B)" ] || { echo "USER_B is required"; exit 2; }
	$(PY) skills/im-contact-flow/scripts/contact_flow.py establish-friends \
	  --initiator-device $(INITIATOR_DEVICE) --peer-device $(PEER_DEVICE) \
	  --user-a $(USER_A) --user-b $(USER_B) $(if $(REASON),--reason "$(REASON)")

contact-delete:
	@[ -n "$(INITIATOR_DEVICE)" ] || { echo "INITIATOR_DEVICE is required"; exit 2; }
	@[ -n "$(FRIEND_USER_ID)" ] || { echo "FRIEND_USER_ID is required"; exit 2; }
	$(PY) skills/im-contact-flow/scripts/contact_flow.py delete-friend \
	  --initiator-device $(INITIATOR_DEVICE) --friend-user-id $(FRIEND_USER_ID) \
	  $(if $(KEEP_CONVERSATION),--keep-conversation)

contact-block:
	@[ -n "$(DEVICE)" ] || { echo "DEVICE is required"; exit 2; }
	@[ -n "$(USER_ID)" ] || { echo "USER_ID is required"; exit 2; }
	$(PY) skills/im-contact-flow/scripts/contact_flow.py block --device $(DEVICE) --user-id $(USER_ID)

contact-unblock:
	@[ -n "$(DEVICE)" ] || { echo "DEVICE is required"; exit 2; }
	@[ -n "$(USER_ID)" ] || { echo "USER_ID is required"; exit 2; }
	$(PY) skills/im-contact-flow/scripts/contact_flow.py unblock --device $(DEVICE) --user-id $(USER_ID)

# --- Validate skills ---
skills-validate:
	$(PY) $(SKILL_CREATOR)/scripts/quick_validate.py skills/im-ws
	$(PY) $(SKILL_CREATOR)/scripts/quick_validate.py skills/im-rest-users
	$(PY) $(SKILL_CREATOR)/scripts/quick_validate.py skills/im-contact-flow

# --- Tests ---
test:
	$(PY) -m pytest $(ARGS)

test-allure:
	mkdir -p out/allure-results
	$(PY) -m pytest --alluredir=out/allure-results $(ARGS)

test-html:
	mkdir -p out
	$(PY) -m pytest --html=out/report.html --self-contained-html $(ARGS)

# --- Chat test presets ---
test-chat-strict:
	@echo "[Strict] chat suite (CASES_DISCOVER=0)"
	CASES_DISCOVER=0 WS_DEBUG=0 $(PY) -m pytest -q tests/chat -s $(ARGS)

test-chat-discover:
	@echo "[Discover] chat suite (CASES_DISCOVER=1, WS_DEBUG=1)"
	CASES_DISCOVER=1 WS_DEBUG=1 $(PY) -m pytest -q tests/chat -s $(ARGS)

clean:
	rm -rf out
