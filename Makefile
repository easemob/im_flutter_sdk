# im_flutter_sdk project setup
# Usage: make setup

EXAMPLE_DIR := im_flutter_sdk/example
IOS_DIR     := $(EXAMPLE_DIR)/ios
ENV_TOOL    := $(EXAMPLE_DIR)/tool/env_tool.dart
PODSPEC     := im_flutter_sdk_ios/ios/im_flutter_sdk_ios.podspec
PODFILE     := $(IOS_DIR)/Podfile
PODLOCK     := $(IOS_DIR)/Podfile.lock

.DEFAULT_GOAL := help

.PHONY: help setup config env-gettoken env-use auto-report deps pods clean

help: ## Show this help
	@echo "im_flutter_sdk - project setup"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-10s %s\n", $$1, $$2}'

setup: config deps pods ## Run all setup steps
	@echo ""
	@echo "Setup complete. Next: cd $(EXAMPLE_DIR) && flutter run -d <device>"

config: ## Create local config and placeholder env.dart if missing
	dart run $(ENV_TOOL) ensure

env-gettoken: ## Fetch user tokens for all clusters and activate the default cluster
	dart run $(ENV_TOOL) gettoken

env-use: ## Activate an existing cluster: make env-use CLUSTER=ebs
	@test -n "$(CLUSTER)" || (echo "Usage: make env-use CLUSTER=<name>" && exit 2)
	dart run $(ENV_TOOL) use "$(CLUSTER)"

auto-report: ## Run 5.0.0 auto mode and write a local report: make auto-report PLATFORM=android [DEVICE=...]
	@test "$(PLATFORM)" = "android" || test "$(PLATFORM)" = "ios" || (echo "Usage: make auto-report PLATFORM=<android|ios> [DEVICE=<id>]" && exit 2)
	dart run tool/auto_report.dart --platform "$(PLATFORM)" $(if $(DEVICE),--device "$(DEVICE)",)

deps: ## flutter pub get
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
