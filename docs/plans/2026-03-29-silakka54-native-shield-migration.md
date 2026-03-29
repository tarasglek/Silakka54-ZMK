# Silakka54 Native Shield Migration Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace the current Lily58-compatibility keymap with a native Silakka54 shield/keymap so the layout has exactly 54 real positions and no Lily58 leftover dead keys.

**Architecture:** First, capture the official Silakka54 physical/matrix layout from the upstream QMK repo and baseline the current ZMK state. Then add a custom `silakka54` shield in this config repo (derived from the existing Lily58 wiring pattern), migrate build targets and keymap/docs to `silakka54_*`, and rewrite the keymap to native 54 positions (no `&none` placeholders). Finally, regenerate keymap artifacts and verify both local build and CI.

**Tech Stack:** ZMK shield/keymap DTS config, QMK reference layout (`Squalius-cephalus/silakka54`), GNU Make, keymap-drawer (`uvx`), GitHub Actions

---

## Checklist

- [ ] Baseline current repo and capture official Silakka54 reference matrix/layout
- [ ] Create native `silakka54` shield files in `config/boards/shields/`
- [ ] Migrate repo config/build paths from `lily58*` to `silakka54*` where appropriate
- [ ] Rewrite keymap to native 54-key positions (remove `&none` placeholders)
- [ ] Regenerate docs/artifacts and update README/vial notes
- [ ] Run iterative verification checks (Structure → Build → Docs)
- [ ] Push and verify CI is green

---

### Task 1: Baseline + reference capture

**Files:**
- Read: `config/lily58.keymap`
- Read: `Makefile`
- Read: `build.yaml`
- Read: `README.md`
- Read: `docs/vial-notes.md`
- Read (reference checkout): `/home/taras/.cache/checkouts/github.com/Squalius-cephalus/silakka54/firmware/keyboard.json`
- Read (reference checkout): `/home/taras/.cache/checkouts/github.com/Squalius-cephalus/silakka54/firmware/keymaps/vial/keymap.c`

**Step 1: Verify current legacy state exists**

Run: `rg -n "lily58|&none|lily58_left|lily58_right" config Makefile build.yaml README.md docs`
Expected: multiple matches proving current config still uses Lily58 compatibility and dead-key placeholders.

**Step 2: Capture official Silakka54 shape reference**

Run: `rg -n '"matrix"|"layout"|LAYOUT\(' /home/taras/.cache/checkouts/github.com/Squalius-cephalus/silakka54/firmware/keyboard.json /home/taras/.cache/checkouts/github.com/Squalius-cephalus/silakka54/firmware/keymaps/vial/keymap.c`
Expected: reference shows a 54-key LAYOUT and no Lily58-specific dead slots.

**Step 3: Record migration assumptions in notes section of this plan**

Add a short note block in this plan with:
- expected key count = 54
- no `&none` in final base layer
- build shield names expected to become `silakka54_left` / `silakka54_right`

---

#### Task 1 notes (captured)

- Expected total key positions in native layout: **54**
- Final native base layer must contain **no `&none` bindings**
- Build shield names should migrate to: **`silakka54_left` / `silakka54_right`**

### Task 2: Create native Silakka54 shield definitions

**Files:**
- Create: `config/boards/shields/silakka54/Kconfig.shield`
- Create: `config/boards/shields/silakka54/Kconfig.defconfig`
- Create: `config/boards/shields/silakka54/silakka54_left.overlay`
- Create: `config/boards/shields/silakka54/silakka54_right.overlay`
- Create: `config/boards/shields/silakka54/silakka54.dtsi`
- Read (reference pattern): `zmk/app/boards/shields/lily58/*` (from west workspace)

**Step 1: Inspect upstream lily58 shield as implementation template**

Run: `find zmk/app/boards/shields/lily58 -maxdepth 2 -type f | sort`
Expected: list of lily58 shield files to mirror structurally.

**Step 2: Add minimal native silakka54 shield files**

Implement files with the same style as lily58, but sized/wired for official Silakka54 54-key physical layout.

**Step 3: Verify shield files are discoverable by ZMK**

Run: `find config/boards/shields/silakka54 -maxdepth 2 -type f | sort`
Expected: all required shield files present.

Run: `rg -n "silakka54_(left|right)|compatible|chosen|kscan" config/boards/shields/silakka54`
Expected: valid identifiers and expected shield bindings appear.

---

### Task 3: Migrate build/config naming to silakka54

**Files:**
- Create: `config/silakka54.conf` (or rename from `config/lily58.conf`)
- Create: `config/silakka54.keymap` (or rename from `config/lily58.keymap`)
- Create: `config/silakka54_left.conf` (or rename from `config/lily58_left.conf`)
- Create: `config/silakka54_left.overlay` (if still needed for logging)
- Modify: `Makefile`
- Modify: `build.yaml`
- Modify: `README.md`

**Step 1: Introduce silakka54 config filenames and references**

- update `Makefile` `KEYMAP_FILE` to `config/silakka54.keymap`
- update build shields from `lily58_*` to `silakka54_*`
- update artifact names to `silakka54_left.uf2` / `silakka54_right.uf2`

**Step 2: Update build matrix**

Run: `rg -n "lily58_|silakka54_" Makefile build.yaml`
Expected: `silakka54_*` is used for active build targets.

**Step 3: Keep compatibility only where strictly required**

If any name must remain `lily58*` due to ZMK resolver constraints, explicitly document why in `README.md`.

---

### Task 4: Rewrite keymap to 54 true positions

**Files:**
- Modify: `config/silakka54.keymap`
- Read (reference): `/home/taras/.cache/checkouts/github.com/Squalius-cephalus/silakka54/firmware/keymaps/vial/keymap.c`

**Step 1: Write failing structural expectation**

Run: `rg -n "&none" config/silakka54.keymap`
Expected: initially finds legacy placeholders.

**Step 2: Rewrite all layer bindings to native 54-position order**

- map key order to official Silakka54 physical positions
- preserve current mirrored-nav behavior and existing macro semantics unless explicitly changing behavior
- remove Lily58-only phantom slots from all layers

**Step 3: Verify keymap is now native shape**

Run: `rg -n "&none" config/silakka54.keymap`
Expected: no matches.

Run: `uvx --from keymap-drawer keymap parse -z config/silakka54.keymap >/tmp/silakka54.native.yaml`
Expected: parser succeeds without binding-count mismatch errors.

---

### Task 5: Docs and generated artifacts sync

**Files:**
- Modify: `Makefile`
- Modify: `README.md`
- Modify: `docs/vial-notes.md`
- Modify: `docs/generated/silakka54.yaml`
- Modify: `docs/generated/silakka54.svg`

**Step 1: Regenerate artifacts using native keymap path**

Run: `make keymap-svg`
Expected: generated YAML/SVG reflect native Silakka54 layout.

**Step 2: Remove stale Lily58/dead-key wording in docs**

Run: `rg -n "Lily58|dead keys|&none|lily58_left|lily58_right" README.md docs/vial-notes.md`
Expected: no stale claims remain (except explicit historical notes, if any).

**Step 3: Validate docs reference the right artifacts**

Run: `rg -n "docs/generated/silakka54.svg|silakka54" README.md docs/vial-notes.md Makefile`
Expected: canonical links and commands point at Silakka54 assets.

---

### Task 6: Iterative verification checks (3 passes)

**Files:**
- Verify all modified files from Tasks 2–5

#### Iterative Check 1 — Structure

Run:
- `git diff --check`
- `rg -n "lily58|&none" config Makefile build.yaml README.md docs | head -n 200`

Expected:
- no whitespace/errors
- no unintended Lily58 leftovers in active config paths
- no dead-key placeholders in native keymap

#### Iterative Check 2 — Build

Run:
- `make -n build`
- `make build`

Expected:
- dry-run uses `silakka54_*` shields
- full build emits UF2s successfully

#### Iterative Check 3 — Docs/Artifacts

Run:
- `make keymap-svg`
- `git diff -- docs/generated/silakka54.yaml docs/generated/silakka54.svg`
- `rg -n "Silakka54|silakka54" README.md docs/vial-notes.md`

Expected:
- artifacts regenerate cleanly
- docs describe native Silakka54 layout accurately

---

### Task 7: Commit sequence (small, reviewable)

**Step 1: Commit shield creation**

```bash
git add config/boards/shields/silakka54
git commit -m "feat(shield): add native silakka54 shield definitions"
```

**Step 2: Commit build/config migration**

```bash
git add Makefile build.yaml config/silakka54* config/lily58* README.md
git commit -m "refactor(build): switch targets from lily58 to silakka54"
```

**Step 3: Commit keymap + docs/artifacts**

```bash
git add config/silakka54.keymap docs/vial-notes.md docs/generated/silakka54.yaml docs/generated/silakka54.svg
git commit -m "feat(keymap): migrate to native 54-key silakka54 layout"
```

---

### Task 8: Push and CI verification

**Step 1: Push**

Run: `git push`
Expected: remote branch updated.

**Step 2: Watch CI and fix until green**

Run:
- `gh run list --limit 5`
- `gh run view <run-id> --log-failed` (if failed)

Expected: build workflow succeeds with native silakka54 shield and keymap.
