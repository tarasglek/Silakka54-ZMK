# Mirrored Thumb Navigation Layers Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace the old asymmetric thumb/layer arrangement with mirrored thumb-accessed navigation layers that use the same visible direction cluster for arrows and Ctrl+Alt directional actions, include `Alt+F4` within that mirrored layout, and keep committed generated keymap SVGs in sync with the real config.

**Architecture:** Start by adding a reproducible keymap visualization path to `Makefile` using `keymap-drawer`, generating committed YAML/SVG artifacts that README can reference directly. Then rework the keymap so `[` and `=` enter a navigation layer, while `]` and `-` enter a desktop-move layer. Put the visible direction cluster on `, . / '` in both layers, place `Alt+F4` on the approved mirrored layer position instead of a dedicated combo, remove the old layer-3/layer-4 dependency and old Ctrl+Gui desktop-switching macros, then regenerate and compare the visualization artifacts as part of validation.

**Tech Stack:** ZMK device-tree keymap config, existing macros/behaviors, Markdown docs, GNU Make, `uvx`, `keymap-drawer`, git

---

### Task 1: Add reproducible keymap visualization targets to the Makefile

**Files:**
- Modify: `Makefile`
- Modify: `README.md`
- Create: `docs/generated/`
- Create: generated keymap files such as `docs/generated/silakka54.yaml` and `docs/generated/silakka54.svg`

**Step 1: Verify the current repo has no committed visualization workflow**

Run: `rg -n "keymap-drawer|uvx|docs/generated|\.svg|\.yaml" Makefile README.md docs`
Expected: no existing committed keymap-drawer generation path is present, or any existing one is incomplete.

**Step 2: Add the minimal Makefile targets**

Add Makefile targets that use `uvx --from keymap-drawer` to:
- parse `config/lily58.keymap` into a committed YAML artifact
- draw a committed SVG artifact from that YAML
- provide a single convenience target such as `make keymap-svg` or `make keymap-docs`

Use explicit output paths under `docs/generated/` so the generated assets are easy to diff and commit.

**Step 3: Reference the generated SVG from README**

Add a README section that embeds or links the committed generated SVG so the documented layout always points at the same reproducible artifact.

**Step 4: Generate and commit the baseline artifacts**

Run the new target, e.g. `make keymap-svg`
Expected: committed files like `docs/generated/silakka54.yaml` and `docs/generated/silakka54.svg` are created successfully.

**Step 5: Commit**

```bash
git add Makefile README.md docs/generated
git commit -m "build(docs): add generated keymap svg workflow"
```

### Task 2: Inventory the current relevant behaviors and save a before snapshot

**Files:**
- Read: `config/lily58.keymap`
- Read: `config/macros.dtsi`
- Read: `README.md`
- Read: `docs/vial-notes.md`
- Read: `docs/generated/silakka54.svg`

**Step 1: Write the failing expectation**

Record the target state in notes before editing:
- `[` and `=` should enter the navigation layer
- `]` and `-` should enter the desktop-move layer
- `, . / '` should be the visible direction cluster on both layers
- `;` and `Tab` on the navigation layer should both send Alt+Tab
- `Alt+F4` should exist inside the mirrored layer layout, not as a dedicated combo
- Ctrl+Gui desktop-switching macros should be removed
- layers 3/4 should be removed or no longer used for this functionality
- the generated SVG should visibly reflect the new layer layout after regeneration

**Step 2: Verify the current structure does not match**

Run: `rg -n "mt LALT LBKT|td1|kp MINUS|lt 3 EQUAL|lt 4 EQUAL|m0|m1|m3|m4|m5|m6|combo_.*altf4|LA\(F4\)|LC\(LGUI\(|LC\(LALT\(" config/lily58.keymap config/macros.dtsi`
Expected: current output shows the old asymmetric thumb behavior, any existing Alt+F4 combo wiring, old layer 3/4 usage, and existing macro definitions.

**Step 3: Inspect current docs for outdated references**

Run: `rg -n "layer 3|layer 4|M0|M1|M3|M4|M5|M6|Ctrl\+Gui|Ctrl\+Alt|Fn" README.md docs/vial-notes.md`
Expected: current docs still describe the old macro/layer model.

**Step 4: Save a before artifact for comparison**

Copy the generated visualization before changing the keymap, e.g.:
`cp docs/generated/silakka54.svg docs/generated/silakka54.before-mirror.svg`
Expected: a before snapshot exists for optional visual comparison during validation.

**Step 5: Commit planning docs if needed**

```bash
git add docs/plans/2026-03-29-right-thumb-modifier-mirror-design.md docs/plans/2026-03-29-right-thumb-modifier-mirror.md
git commit -m "docs(plan): define mirrored thumb navigation layers"
```

### Task 3: Remove obsolete macro/layer machinery

**Files:**
- Modify: `config/macros.dtsi`
- Modify: `config/lily58.keymap`

**Step 1: Write the failing structural expectation**

Define what must disappear:
- Ctrl+Gui desktop-switching macros
- old dedicated Ctrl+Alt directional macro placements on layers 3/4
- dependence on layer 3/4 for thumb-accessed macro behavior

**Step 2: Verify obsolete definitions still exist**

Run: `rg -n "Win_Move_Desktop_Left|Win_Move_Desktop_Right|m0|m1|m3|m4|m5|m6|layer_3|layer_4" config/macros.dtsi config/lily58.keymap`
Expected: matches are found, proving cleanup is still needed.

**Step 3: Write the minimal cleanup**

- Remove the Ctrl+Gui desktop-switching macros from `config/macros.dtsi`
- Remove or neutralize the old layer 3 and layer 4 payload from `config/lily58.keymap`
- Remove the dedicated Alt+F4 combo path
- Keep only behaviors still needed by the new design and by screenshot handling

**Step 4: Verify cleanup**

Run: `rg -n "Win_Move_Desktop_Left|Win_Move_Desktop_Right|layer_3|layer_4|m0|m1|m3|m4|m5|m6|combo_.*altf4" config/macros.dtsi config/lily58.keymap`
Expected: obsolete Ctrl+Gui macros are gone, the dedicated Alt+F4 combo is gone, and layer 3/4 references are removed or clearly no longer part of active behavior.

**Step 5: Commit**

```bash
git add config/macros.dtsi config/lily58.keymap
git commit -m "refactor(keymap): remove old thumb macro layers"
```

### Task 4: Implement mirrored thumb-accessed layers and direction cluster

**Files:**
- Modify: `config/lily58.keymap`

**Step 1: Write the failing structural verification**

Before editing, define the final keymap expectations:
- base layer thumb bindings for `[` and `=` should enter the same navigation layer
- base layer thumb bindings for `]` and `-` should enter the same desktop-move layer
- the `, . / '` positions on the navigation layer should send arrows
- `;` and `Tab` on the navigation layer should both send Alt+Tab
- the same positions on the desktop-move layer should send Ctrl+Alt Left/Down/Right/Up
- the approved mirrored layer position should send `Alt+F4`

**Step 2: Verify the old structure is still present**

Run: `uv run python - <<'PY'
from pathlib import Path
text = Path('config/lily58.keymap').read_text()
assert '&mt LALT LBKT' in text
assert '&td1' in text
assert '&kp MINUS' in text or '&lt 3 EQUAL' in text
print('old thumb structure confirmed')
PY`
Expected: script prints `old thumb structure confirmed`.

**Step 3: Write the minimal implementation**

Update `config/lily58.keymap` so that:
- `[` and `=` both access the navigation layer
- `]` and `-` both access the desktop-move layer
- `, . / '` on the navigation layer send Left/Down/Right/Up
- `;` and `Tab` on the navigation layer send Alt+Tab
- the approved mirrored layer slot sends `LA(F4)`
- `, . / '` on the desktop-move layer send Ctrl+Alt Left/Down/Right/Up
- unrelated base typing behavior is left unchanged unless required by the new layer mechanism

If new helper behaviors are needed to keep the tap output and hold-layer behavior clear, add the smallest possible new behavior blocks.

**Step 4: Verify the new structure**

Run targeted grep once the implementation is chosen, for example:
`rg -n "LBKT|RBKT|MINUS|EQUAL|COMMA|DOT|SLASH|SQT|LEFT|RIGHT|UP|DOWN|LA\(|LC\(LALT|layer_|combo_.*altf4" config/lily58.keymap`
Expected: the new mirrored layer entry points, the mirrored `Alt+F4` mapping, and both directional layer mappings are visible, with no Alt+F4 combo remaining.

**Step 5: Commit**

```bash
git add config/lily58.keymap
git commit -m "feat(keymap): mirror thumb navigation layers"
```

### Task 5: Regenerate visual artifacts and update documentation

**Files:**
- Modify: `README.md`
- Modify: `docs/vial-notes.md`
- Modify: `docs/generated/silakka54.yaml`
- Modify: `docs/generated/silakka54.svg`

**Step 1: Write the failing doc expectation**

Required doc updates:
- explain mirrored thumb layer roles
- explain the shared `, . / '` direction cluster
- explain `;` and `Tab` as navigation-layer Alt+Tab keys
- explain where `Alt+F4` lives in the mirrored layer layout
- remove references to layer 3/4 macro access, removed desktop-switching macros, and the old dedicated Alt+F4 combo
- regenerate and commit the YAML/SVG artifacts after the keymap changes

**Step 2: Verify docs still describe the old model**

Run: `rg -n "layer 3|layer 4|M0|M1|M3|M4|M5|M6|Ctrl\+Gui|Ctrl\+Alt|\[ \+ 4|Fn" README.md docs/vial-notes.md`
Expected: find outdated references that need rewriting.

**Step 3: Regenerate the keymap artifacts**

Run: `make keymap-svg`
Expected: `docs/generated/silakka54.yaml` and `docs/generated/silakka54.svg` are refreshed to match the edited keymap.

**Step 4: Write the minimal documentation changes**

Update docs so they describe:
- `[` and `=` entering the navigation layer
- `]` and `-` entering the desktop-move layer
- `, . / '` as the visible direction cluster
- `;` and `Tab` as navigation-layer Alt+Tab keys
- `Alt+F4` as part of the mirrored layer layout
- screenshot behavior remaining separate
- removed macro-layer complexity
- README referencing the generated SVG artifact

**Step 5: Verify docs and generated artifacts match implementation**

Run: `rg -n "navigation layer|desktop-move layer|Alt\+F4|\[ \+ 4|LALT \+ 4 -> F4|Ctrl\+Alt|layer 3|layer 4|Ctrl\+Gui|docs/generated/silakka54.svg" README.md docs/vial-notes.md && git diff -- docs/generated/silakka54.yaml docs/generated/silakka54.svg`
Expected: new model is documented, README points at the generated SVG, obsolete combo/layer wording is gone, and the generated artifacts reflect the keymap change.

**Step 6: Commit**

```bash
git add README.md docs/vial-notes.md docs/generated/silakka54.yaml docs/generated/silakka54.svg
git commit -m "docs(keymap): update mirrored navigation visuals"
```

### Task 6: Validate, compare before/after visuals, push, and fix CI until green

**Files:**
- Modify as needed: `Makefile`
- Modify as needed: `config/lily58.keymap`
- Modify as needed: `config/macros.dtsi`
- Modify as needed: `README.md`
- Modify as needed: `docs/vial-notes.md`
- Modify as needed: `docs/generated/silakka54.yaml`
- Modify as needed: `docs/generated/silakka54.svg`

**Step 1: Run final local verification**

Run: `git diff --check && git diff -- Makefile config/lily58.keymap config/macros.dtsi README.md docs/vial-notes.md docs/generated/silakka54.yaml docs/generated/silakka54.svg docs/plans/2026-03-29-right-thumb-modifier-mirror-design.md docs/plans/2026-03-29-right-thumb-modifier-mirror.md`
Expected: no whitespace issues and diff contains only the approved mirrored-layer and visualization changes, including the integrated `Alt+F4` behavior.

**Step 2: Compare before/after visualizations**

Run: `git diff --no-index -- docs/generated/silakka54.before-mirror.svg docs/generated/silakka54.svg || true`
Expected: the SVG diff clearly shows the mirrored layer changes. If text diff is too noisy, inspect both files or open them in a visual diff tool before proceeding.

**Step 3: Verify the build and doc generation paths still work**

Run:
- `make -n build`
- `make -n keymap-svg`
Expected: both dry-runs succeed.

If local builds are available, also run:
- `make build`
- `make keymap-svg`
Expected: firmware artifacts build successfully and the keymap docs regenerate cleanly.

**Step 4: Push**

Run: `git push`
Expected: remote updates successfully.

**Step 5: Poll CI**

Run: `gh run list --limit 5`
Expected: identify the run for the pushed commit.

**Step 6: Fix until green if needed**

Run:
- `gh run view <run-id> --log-failed`
- apply minimal fix
- regenerate docs if relevant with `make keymap-svg`
- `git add ...`
- `git commit -m "fix(ci): address mirrored navigation layer issue"`
- `git push`

Expected: repeat until the relevant workflow passes.

### Task 7 (deferred): Plan-only repo-wide naming migration (`lily58*` -> `silakka54*`)

**Status:** Deferred. Do **not** execute as part of this implementation pass.

**Goal:** Capture the required work to rename tracked filename conventions from `lily58*` to `silakka54*` in a dedicated migration, with explicit compatibility verification.

**Files (future migration scope):**
- Potentially rename tracked files currently matching `config/lily58*`
- Update references in `Makefile`, `build.yaml`, workflow/docs, and generated artifacts
- Validate ZMK build behavior for shield/config filename assumptions before committing

**Required pre-work before execution:**
1. Confirm whether ZMK expects shield-specific filenames (`lily58_left.*`) for overlay/conf discovery.
2. Define compatibility strategy (full shield rename vs retained shield names with Silakka-branded docs/artifacts).
3. Add explicit verification commands (`make -n build`, `make build`, CI workflow pass) for whichever strategy is chosen.

**Execution rule:**
- This task must be implemented via a separate approved plan/update and should not be performed ad hoc during mirrored-layer changes.
