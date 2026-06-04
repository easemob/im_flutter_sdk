
# Simple task runner for repo-local skills
# Usage: make <target> [VAR=VALUE ...]

PY ?= python3
SKILL_CREATOR ?= $(HOME)/.codex/skills/.system/skill-creator

.PHONY: help ws-call ws-wait create-users delete-user \
        contact-establish contact-delete contact-block contact-unblock \
        skills-validate test test-allure test-html test-chat-strict test-chat-discover clean

help:
	@echo "Available targets:"
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
