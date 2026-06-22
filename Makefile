QS_BIN := $(shell command -v qs 2>/dev/null || command -v quickshell 2>/dev/null || echo quickshell)
QS_DIR := $(shell pwd)/quickshell

.PHONY: default help calibrate shell shader test test-bash test-py bridge-release setup

default: help

help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@echo "  help           Show this help (default)"
	@echo "  calibrate      Run screen calibration"
	@echo "  shell          Start navishell"
	@echo "  shader         Compile GLSL shaders in quickshell/.config/quickshell/shaders"
	@echo "  test           Run all tests (bash + python)"
	@echo "  test-bash      Run telemetry pipe unit tests (bash)"
	@echo "  test-py        Run save-offset unit tests (pytest)"
	@echo "  bridge-release Build lookas-bridge in release mode"
	@echo "  setup          Run full setup script"

shader:
	@echo "Compiling shaders"
	@for f in $(QS_DIR)/.config/quickshell/shaders/*.frag; do \
		qsb --qt6 "$$f" -o "$${f%.frag}.frag.qsb"; \
	done

calibrate:
	@echo "Running calibration"
	@$(QS_BIN) -p $(QS_DIR)/calibrate.qml

bridge-release:
	@echo "Building lookas-bridge in release mode"
	@cd $(QS_DIR)/lookas-bridge && cargo build --release

shell:
	@echo "Starting shell"
	@$(QS_BIN)

test: test-bash test-py

test-bash:
	@echo "Running telemetry pipe tests"
	@bash tests/telemetry_test.sh

test-py:
	@echo "Running save-offset unit tests"
	@cd $(QS_DIR) && python3 -m pytest test_save_offset.py -v 2>/dev/null || python3 test_save_offset.py -v

setup:
	@echo "Running setup"
	@chmod +x setup.sh
	@./setup.sh
