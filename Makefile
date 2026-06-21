QS_BIN := $(shell command -v qs 2>/dev/null || command -v quickshell 2>/dev/null || echo quickshell)
QS_DIR := $(shell pwd)/quickshell

.PHONY: calibrate shell setup test

calibrate:
	@echo "Running calibration"
	@$(QS_BIN) -p $(QS_DIR)/calibrate.qml

shell:
	@echo "Starting shell"
	@$(QS_BIN)

test:
	@echo "Running save-offset unit tests"
	@cd $(QS_DIR) && python3 -m pytest test_save_offset.py -v 2>/dev/null || python3 test_save_offset.py -v

setup:
	@echo "Running setup"
	@chmod +x setup.sh
	@./setup.sh
