IMAGE ?= zmkfirmware/zmk-build-arm@sha256:edb1c953438c6f720ddb79c3762f3972013b7fbbaf4fff3592fc869983e7afc5
ARTIFACTS_DIR ?= artifacts
CACHE_DIR ?= .cache/zmk
DEPS_STAMP ?= $(CACHE_DIR)/deps.stamp
KEYMAP_DOCS_DIR ?= docs/generated
KEYMAP_FILE ?= config/silakka54.keymap
KEYMAP_YAML ?= $(KEYMAP_DOCS_DIR)/silakka54.yaml
KEYMAP_SVG ?= $(KEYMAP_DOCS_DIR)/silakka54.svg

DOCKER_RUN = docker run --rm \
	-v "$(CURDIR):/work" \
	-v "$(CURDIR)/$(CACHE_DIR)/zephyr:/root/.cache/zephyr" \
	-v "$(CURDIR)/$(CACHE_DIR)/ccache:/root/.cache/ccache" \
	-e CCACHE_DIR=/root/.cache/ccache \
	-w /work \
	$(IMAGE) \
	bash -lc

.PHONY: build build-left build-right build-reset deps clean keymap-yaml keymap-svg keymap-docs

build: build-left build-right build-reset

deps: $(DEPS_STAMP)

$(DEPS_STAMP):
	mkdir -p $(ARTIFACTS_DIR) $(CACHE_DIR)/zephyr $(CACHE_DIR)/ccache
	$(DOCKER_RUN) 'set -euo pipefail; \
		git config --global --add safe.directory "*" || true; \
		[ -d .west ] || west init -l config; \
		west update --fetch-opt=--filter=tree:0; \
		if west help 2>/dev/null | grep -q "zephyr-export"; then west zephyr-export; fi'
	mkdir -p $(dir $(DEPS_STAMP))
	touch $(DEPS_STAMP)

build-left: $(DEPS_STAMP)
	mkdir -p $(ARTIFACTS_DIR)
	$(DOCKER_RUN) 'set -euo pipefail; \
		git config --global --add safe.directory "*" || true; \
		[ -d .west ] || west init -l config; \
		if west help 2>/dev/null | grep -q "zephyr-export"; then west zephyr-export; fi; \
		west build -s zmk/app -d build/silakka54_left -b nice_nano -S studio-rpc-usb-uart -- -DZMK_CONFIG=/work/config -DSHIELD="silakka54_left nice_view_adapter nice_view"; \
		cp build/silakka54_left/zephyr/zmk.uf2 /work/$(ARTIFACTS_DIR)/silakka54_left.uf2'

build-right: $(DEPS_STAMP)
	mkdir -p $(ARTIFACTS_DIR)
	$(DOCKER_RUN) 'set -euo pipefail; \
		git config --global --add safe.directory "*" || true; \
		[ -d .west ] || west init -l config; \
		if west help 2>/dev/null | grep -q "zephyr-export"; then west zephyr-export; fi; \
		west build -s zmk/app -d build/silakka54_right -b nice_nano -- -DZMK_CONFIG=/work/config -DSHIELD="silakka54_right nice_view_adapter nice_view"; \
		cp build/silakka54_right/zephyr/zmk.uf2 /work/$(ARTIFACTS_DIR)/silakka54_right.uf2'

build-reset: $(DEPS_STAMP)
	mkdir -p $(ARTIFACTS_DIR)
	$(DOCKER_RUN) 'set -euo pipefail; \
		git config --global --add safe.directory "*" || true; \
		[ -d .west ] || west init -l config; \
		if west help 2>/dev/null | grep -q "zephyr-export"; then west zephyr-export; fi; \
		west build -s zmk/app -d build/settings_reset -b nice_nano -- -DZMK_CONFIG=/work/config -DSHIELD="settings_reset"; \
		cp build/settings_reset/zephyr/zmk.uf2 /work/$(ARTIFACTS_DIR)/settings_reset.uf2'

keymap-yaml:
	mkdir -p $(KEYMAP_DOCS_DIR)
	uvx --from keymap-drawer keymap parse -z $(KEYMAP_FILE) > $(KEYMAP_YAML)

keymap-svg: keymap-yaml
	uvx --from keymap-drawer keymap draw $(KEYMAP_YAML) > $(KEYMAP_SVG)

keymap-docs: keymap-svg

clean:
	rm -rf build $(ARTIFACTS_DIR)
