# im_flutter_sdk project setup
# Usage: make setup

EXAMPLE_DIR := im_flutter_sdk/example
IOS_DIR     := $(EXAMPLE_DIR)/ios
ENV_TOOL    := $(EXAMPLE_DIR)/tool/env_tool.dart
CONFIG_SRC  := $(EXAMPLE_DIR)/templates/config.example.json
CONFIG_DST  := $(EXAMPLE_DIR)/scripts/config.json
PODSPEC     := im_flutter_sdk_ios/ios/im_flutter_sdk_ios.podspec
PODFILE     := $(IOS_DIR)/Podfile
PODLOCK     := $(IOS_DIR)/Podfile.lock

.DEFAULT_GOAL := help

.PHONY: help setup config env-gettoken auto-report local-deps deps pods clean

help: ## Show this help
	@echo "im_flutter_sdk - project setup"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-10s %s\n", $$1, $$2}'

setup: config deps pods ## Run all setup steps
	@echo ""
	@echo "Setup complete. Next: $(EXAMPLE_DIR): make env-gettoken (after editing config.local.json), then flutter run -d <device>"

config: ## Create local env files (config.local.json + placeholder lib/env.dart) and legacy scripts/config.json if missing
	dart run $(ENV_TOOL) ensure
	@if [ ! -f "$(CONFIG_DST)" ]; then \
		mkdir -p $(dir $(CONFIG_DST)); \
		cp "$(CONFIG_SRC)" "$(CONFIG_DST)"; \
		echo "Created: $(CONFIG_DST)"; \
		echo "Edit it with your appKey / credentials (AutoMode legacy config)"; \
	else \
		echo "Skip: $(CONFIG_DST) already exists"; \
	fi

env-gettoken: ## Fetch tokens from example/config.local.json and write example/lib/env.dart
	dart run $(ENV_TOOL) gettoken

auto-report: ## Run 1.16.0 auto mode and write a local report: make auto-report [DEVICE=127.0.0.1:5555] [SCRIPT=testing/single/cases/script_1.16.0_apis_negative.json]
	dart run testing/single/auto_report.dart --platform ohos $(if $(DEVICE),--device $(DEVICE),) $(if $(SCRIPT),--script $(SCRIPT),)

local-deps: ## Create gitignored pubspec_overrides.yaml files for local SDK packages
	bash tool/use_local_packages.sh

deps: local-deps ## flutter pub get with local SDK packages
	@echo "Running flutter pub get..."
	cd $(EXAMPLE_DIR) && flutter pub get
	@echo "Done: dependencies resolved"

pods: deps ## pod install (only when needed)
	@if [ ! -f "$(PODLOCK)" ] || [ ! -d "$(IOS_DIR)/Pods" ] \
	  || [ "$(PODFILE)" -nt "$(PODLOCK)" ] \
	  || [ "$(PODSPEC)" -nt "$(PODLOCK)" ]; then \
		echo "Running pod install..."; \
		cd $(IOS_DIR) && pod install; \
		echo "Done: pods installed"; \
	else \
		echo "Skip: pods are up to date"; \
	fi

clean: ## Remove build artifacts + Pods
	cd $(EXAMPLE_DIR) && flutter clean
	rm -rf $(IOS_DIR)/Pods $(IOS_DIR)/Podfile.lock
	@echo "Done: cleaned"
