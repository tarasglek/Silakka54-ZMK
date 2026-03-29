IMAGE ?= zmkfirmware/zmk-build-arm@sha256:edb1c953438c6f720ddb79c3762f3972013b7fbbaf4fff3592fc869983e7afc5
ARTIFACTS_DIR ?= artifacts
CACHE_DIR ?= .cache/zmk

DOCKER_RUN = docker run --rm \
	-v "$(CURDIR):/work" \
	-v "$(CURDIR)/$(CACHE_DIR)/zephyr:/root/.cache/zephyr" \
	-v "$(CURDIR)/$(CACHE_DIR)/ccache:/root/.cache/ccache" \
	-e CCACHE_DIR=/root/.cache/ccache \
	-w /work \
	$(IMAGE) \
	bash -lc

.PHONY: build build-left build-right build-reset west-setup clean

build: build-left build-right build-reset

west-setup: .west/.setup-complete

.west/.setup-complete:
	mkdir -p $(ARTIFACTS_DIR) $(CACHE_DIR)/zephyr $(CACHE_DIR)/ccache
	$(DOCKER_RUN) 'set -euo pipefail; \
		[ -d .west ] || west init -l config; \
		west update --fetch-opt=--filter=tree:0; \
		west zephyr-export; \
		touch /work/.west/.setup-complete'

build-left: west-setup
	mkdir -p $(ARTIFACTS_DIR)
	$(DOCKER_RUN) 'set -euo pipefail; \
		west build -s zmk/app -d build/lily58_left -b nice_nano -S studio-rpc-usb-uart -- -DZMK_CONFIG=/work/config -DSHIELD="lily58_left nice_view_adapter nice_view"; \
		cp build/lily58_left/zephyr/zmk.uf2 /work/$(ARTIFACTS_DIR)/lily58_left.uf2'

build-right: west-setup
	mkdir -p $(ARTIFACTS_DIR)
	$(DOCKER_RUN) 'set -euo pipefail; \
		west build -s zmk/app -d build/lily58_right -b nice_nano -- -DZMK_CONFIG=/work/config -DSHIELD="lily58_right nice_view_adapter nice_view"; \
		cp build/lily58_right/zephyr/zmk.uf2 /work/$(ARTIFACTS_DIR)/lily58_right.uf2'

build-reset: west-setup
	mkdir -p $(ARTIFACTS_DIR)
	$(DOCKER_RUN) 'set -euo pipefail; \
		west build -s zmk/app -d build/settings_reset -b nice_nano -- -DZMK_CONFIG=/work/config -DSHIELD="settings_reset"; \
		cp build/settings_reset/zephyr/zmk.uf2 /work/$(ARTIFACTS_DIR)/settings_reset.uf2'

clean:
	rm -rf build $(ARTIFACTS_DIR)
