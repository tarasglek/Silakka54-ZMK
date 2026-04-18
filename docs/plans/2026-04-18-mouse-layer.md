# Mouse Layer on Hold-1/0 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Make both `1` and `0` act as tap=digit, hold=`mouse layer`, with `A/Z/X/C` as mouse movement and `S/D/F` as holdable mouse buttons.

**Architecture:** Add a dedicated mouse layer in the ZMK keymap and replace the base-layer `1` and `0` bindings with layer-tap behavior. Use ZMK pointing bindings for continuous movement and button press/release behavior, then update both the human-facing docs and the Vial/QMK compatibility artifacts to match as closely as possible.

**Tech Stack:** ZMK device-tree keymap config, ZMK pointing bindings, Markdown docs, Vial export JSON

---

### Task 1: Confirm the exact ZMK mouse bindings already available in this repo

**Files:**
- Read: `config/silakka54.keymap`
- Read: `config/macros.dtsi`

**Step 1: Inspect existing pointing references**

Run: `rg -n "mkp|mmv|msc|pointing|LCLK|MCLK|RCLK" config`
Expected: find any existing pointing-related bindings or confirm only the include is present.

**Step 2: Record the target mapping**

Confirm the intended mouse layer mapping in notes:
- `A` up
- `Z` down
- `X` left
- `C` right
- `S` left button
- `D` middle button
- `F` right button

### Task 2: Write the failing structural test for hold-on-`1`/`0`

**Files:**
- Modify: `config/silakka54.keymap`

**Step 1: Verify the old base binding still exists**

Run: `rg -n "&kp N1" config/silakka54.keymap`
Expected: the base layer still contains a plain `&kp N1` binding.

**Step 2: Define the failing expectation**

The target state is:
- base-layer `1` is no longer plain `&kp N1`
- base-layer `0` is no longer plain `&kp N0`
- base-layer `1` becomes a layer-tap to the mouse layer
- base-layer `0` becomes a layer-tap to the mouse layer
- a new mouse layer exists with the requested mappings

### Task 3: Implement the new mouse layer entry keys

**Files:**
- Modify: `config/silakka54.keymap`

**Step 1: Write the minimal implementation**

Replace the base-layer `1` and `0` bindings with layer-tap behavior so:
- tap `1` -> `1`
- hold `1` -> mouse layer
- tap `0` -> `0`
- hold `0` -> mouse layer

Reuse an existing hold-tap behavior if appropriate, or add the smallest new helper behavior needed.

**Step 2: Verify the structural change**

Run: `rg -n "N1|N0|layer_mouse|mouse" config/silakka54.keymap`
Expected: the plain base `&kp N1` and `&kp N0` are gone or replaced at those positions, and the new mouse layer is present.

### Task 4: Implement the mouse layer mappings

**Files:**
- Modify: `config/silakka54.keymap`

**Step 1: Add continuous movement bindings**

Map:
- `A` -> mouse up
- `Z` -> mouse down
- `X` -> mouse left
- `C` -> mouse right

Use ZMK mouse movement bindings that repeat while held.

**Step 2: Add mouse button bindings**

Map:
- `S` -> left button
- `D` -> middle button
- `F` -> right button

Use bindings with press/release semantics so key hold maps to mouse-button hold.

**Step 3: Verify the final mapping exists**

Run a targeted search after implementation, for example:
`rg -n "layer_mouse|A|S|D|F|Z|X|C|mkp|mmv" config/silakka54.keymap`
Expected: all requested mappings are visible on the new layer.

### Task 5: Update README and Vial notes

**Files:**
- Modify: `README.md`
- Modify: `docs/vial-notes.md`

**Step 1: Add the new layer description to README**

Document:
- `1` and `0` tap/hold behavior
- the mouse layer purpose
- the `A/Z/X/C` movement cluster
- the `S/D/F` button cluster

**Step 2: Update Vial/QMK compatibility notes**

Document in `docs/vial-notes.md`:
- how the new ZMK mouse layer is represented in `vial-export.vil`
- whether the hold-on-`1` layer-tap can be represented directly
- whether mouse movement and mouse button hold behavior are fully representable in the export
- any ZMK-only behavior that must remain approximate or transparent in Vial

**Step 3: Verify docs match implementation**

Run: `rg -n "mouse layer|A/Z/X/C|S/D/F|tap.*1|hold.*mouse|Vial|QMK|vial-export" README.md docs/vial-notes.md`
Expected: README and Vial notes reflect the new behavior and any export caveats.

### Task 6: Update the Vial export artifact

**Files:**
- Modify: `vial-export.vil`

**Step 1: Inspect the current Vial representation**

Run: `rg -n "KC_1|LALT_T\(KC_LBRACKET\)|LT|MO\(|TD\(|KC_MS_|MS_|BTN" vial-export.vil`
Expected: locate the existing base-layer `1` slot and any currently represented layer-tap, mouse, or button behaviors.

**Step 2: Patch the export to mirror the new reachable behavior as closely as possible**

Update `vial-export.vil` so it reflects:
- base `1` and `0` as layer-taps to the mouse layer if supported by the export model
- the mouse layer positions for `A/Z/X/C` and `S/D/F`
- any required Vial macro, tap-dance, or transparent fallback for behaviors that do not have a trustworthy native export equivalent

Prefer a conservative export:
- represent only behavior the Vial/QMK artifact can honestly express
- leave unsupported ZMK-only behavior transparent or documented as approximate

**Step 3: Verify the export changed in the expected places**

Run: `rg -n "KC_1|LT|MO\(|KC_MS_|MS_|BTN|QMK|Vial" vial-export.vil docs/vial-notes.md`
Expected: the export and notes show the new mouse-layer-related changes or explicitly document limitations.

### Task 7: Verify the change before claiming completion

**Files:**
- Modify: `config/silakka54.keymap`
- Modify: `README.md`
- Modify: `docs/vial-notes.md`
- Modify: `vial-export.vil`
- Create: `docs/plans/2026-04-18-mouse-layer-design.md`
- Create: `docs/plans/2026-04-18-mouse-layer.md`

**Step 1: Check the diff**

Run: `git diff -- config/silakka54.keymap README.md docs/vial-notes.md vial-export.vil docs/plans/2026-04-18-mouse-layer-design.md docs/plans/2026-04-18-mouse-layer.md`
Expected: diff only shows the approved mouse-layer, Vial export, and docs changes.

**Step 2: Run build verification**

Run: `make build`
Expected: the firmware builds successfully.

**Step 3: Sanity-check key behavior on device**

Confirm manually:
- tap `1` types `1`
- hold `1` enables mouse layer while held
- hold `0` enables mouse layer while held
- `A/Z/X/C` repeat movement while held
- `S/D/F` hold and release mouse buttons correctly

**Step 4: Sanity-check the Vial artifact**

Confirm manually or by inspection:
- the `1`/`0` positions and mouse layer positions are updated in `vial-export.vil`
- any unsupported behavior is called out in `docs/vial-notes.md`
- no unrelated Vial layers/macros were changed accidentally

**Step 5: Commit**

```bash
git add config/silakka54.keymap README.md docs/vial-notes.md vial-export.vil docs/plans/2026-04-18-mouse-layer-design.md docs/plans/2026-04-18-mouse-layer.md
git commit -m "feat(keymap): add hold-1/0 mouse layer"
```
