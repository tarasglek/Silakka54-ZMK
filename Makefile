IMAGE ?= zmkfirmware/zmk-build-arm:stable
ARTIFACTS_DIR ?= artifacts

.PHONY: build build-left build-right build-reset clean

build: build-left build-right build-reset
