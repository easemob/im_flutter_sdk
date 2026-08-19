# im_flutter_sdk project setup
# Usage: make setup

EXAMPLE_DIR := im_flutter_sdk/example
IOS_DIR     := $(EXAMPLE_DIR)/ios
CONFIG_SRC  := $(EXAMPLE_DIR)/templates/config.example.json
CONFIG_DST  := $(EXAMPLE_DIR)/scripts/config.json
PODSPEC     := im_flutter_sdk_ios/ios/im_flutter_sdk_ios.podspec
PODFILE     := $(IOS_DIR)/Podfile
PODLOCK     := $(IOS_DIR)/Podfile.lock

.DEFAULT_GOAL := help

.PHONY: help setup config deps pods clean

help: ## Show this help
	@echo "im_flutter_sdk - project setup"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-10s %s\n", $$1, $$2}'

setup: config deps pods ## Run all setup steps
	@echo ""
	@echo "Setup complete. Next: cd $(EXAMPLE_DIR) && flutter run -d <device>"

config: ## Copy config template if not exists
	@if [ ! -f "$(CONFIG_DST)" ]; then \
		mkdir -p $(dir $(CONFIG_DST)); \
		cp "$(CONFIG_SRC)" "$(CONFIG_DST)"; \
		echo "Created: $(CONFIG_DST)"; \
		echo "Edit it with your appKey / credentials"; \
	else \
		echo "Skip: $(CONFIG_DST) already exists"; \
	fi

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
