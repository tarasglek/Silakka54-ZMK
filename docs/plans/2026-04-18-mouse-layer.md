# Mouse Layer on Hold-1/0 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Keep `1` and `0` as tap=digit, hold=`mouse layer`, and add `2` and `9` as tap=digit, hold=`scroll layer`, with mirrored controls on both halves. The mouse layer keeps `A/Z/X/C` + `S/D/F` on the left and `'`/`/`/`,`/`.` + `J/K/L` on the right for movement/buttons, while the scroll layer reuses the same physical movement clusters for scroll up/down/left/right and keeps the same button keys. Mouse movement should stay precise then ramp fast after about 300ms; scroll should stay at a constant speed.

**Architecture:** Keep the existing `1`/`0` layer-tap entry points for the mouse layer and add parallel `2`/`9` layer-tap entry points for a new scroll layer. Reuse the dedicated mirrored mouse layer for continuous movement and mouse-button press/release behavior. Add a separate mirrored scroll layer that uses ZMK scroll bindings on the same physical movement keys while keeping `S/D/F` and `J/K/L` as mouse buttons. Continue to tune the stock `&mmv` acceleration curve instead of adding a custom multi-stage mouse mode: override the default move magnitude to `1400`, keep `delay-ms = <0>`, and use `time-to-max-speed-ms = <300>` with `acceleration-exponent = <2>` so short holds stay more precise while longer holds ramp into a faster cursor speed. Keep scroll speed constant rather than ramped. Then update the human-facing docs, generated keymap docs, and Vial/QMK compatibility artifacts to match as closely as possible, explicitly syncing mouse timing changes into the Vial export notes.

**Tech Stack:** ZMK device-tree keymap config, ZMK pointing bindings, Markdown docs, Vial export JSON

**Current repo state:** The structural mouse-layer work is already partially landed in the current branch history (`34005c9`, `c14e84e`, `4724b61`, `0325998`): `1`/`0` already act as mouse-layer taps, the mirrored mouse bindings already exist, and mouse movement tuning plus README/Vial notes were already updated once. Treat this plan as the canonical follow-up for adding the parallel scroll layer on `2`/`9` and for re-validating/syncing the docs and export artifacts after that change.

---

## Execution checklist

- [x] Confirm existing ZMK mouse and scroll bindings and target mirrored mapping
- [x] Verify `1`/`0` mouse-layer hold-tap structure is present
- [x] Add `2`/`9` hold-tap entry points for the scroll layer
- [x] Add mirrored scroll bindings on `A/Z/X/C` and `'`/`/`/`,`/`.`
- [x] Keep `S/D/F` and `J/K/L` as mouse buttons on the scroll layer
- [x] Keep mouse timing tuned and scroll speed constant
- [x] Sync README wording with the mouse + scroll behavior
- [x] Sync `docs/vial-notes.md` with scroll-layer and export approximation limits
- [x] Sync mouse timing changes into the Vial export/docs notes every time `ZMK_POINTING_DEFAULT_MOVE_VAL` or `&mmv` tuning changes
- [x] Re-check `vial-export.vil` against the intended reachable behavior
- [x] Regenerate `docs/generated/silakka54.yaml` and `docs/generated/silakka54.svg`
- [x] Verify diff and run `make build`
- [x] Record any remaining manual hardware checks (manual on-device smoke test still pending)

### Task 1: Confirm the exact ZMK mouse and scroll bindings already available in this repo

**Files:**
- Read: `config/silakka54.keymap`
- Read: `config/macros.dtsi`

**Step 1: Inspect existing pointing references**

Run: `rg -n "mkp|mmv|msc|pointing|LCLK|MCLK|RCLK|MOVE_|SCRL_|WHEEL" config`
Expected: find any existing pointing- or scrolling-related bindings or confirm only the include is present.

**Step 2: Record the target mapping**

Confirm the intended layer mappings in notes:
- mouse layer
  - left hand: `A` up, `Z` down, `X` left, `C` right, `S/D/F` = left/middle/right button
  - right hand: `'` up, `/` down, `,` left, `.` right, `J/K/L` = left/middle/right button
- scroll layer
  - left hand: `A` scroll up, `Z` scroll down, `X` scroll left, `C` scroll right, `S/D/F` = left/middle/right button
  - right hand: `'` scroll up, `/` scroll down, `,` scroll left, `.` scroll right, `J/K/L` = left/middle/right button

### Task 2: Write the failing structural test for hold-on-`2`/`9`

**Files:**
- Modify: `config/silakka54.keymap`

**Step 1: Verify the old base bindings still exist**

Run: `rg -n "&kp N2|&kp N9" config/silakka54.keymap`
Expected: the base layer still contains plain `&kp N2` and `&kp N9` bindings.

**Step 2: Define the failing expectation**

The target state is:
- base-layer `2` is no longer plain `&kp N2`
- base-layer `9` is no longer plain `&kp N9`
- base-layer `2` becomes a layer-tap to the scroll layer
- base-layer `9` becomes a layer-tap to the scroll layer
- a scroll layer exists with the requested mirrored left/right mappings
- the scroll layer keeps `S/D/F` and `J/K/L` as mouse buttons

### Task 3: Implement the new scroll layer entry keys

**Files:**
- Modify: `config/silakka54.keymap`

**Step 1: Write the minimal implementation**

Replace the base-layer `2` and `9` bindings with layer-tap behavior so:
- tap `2` -> `2`
- hold `2` -> scroll layer
- tap `9` -> `9`
- hold `9` -> scroll layer

Reuse the existing hold-tap behavior if appropriate, or add the smallest new helper behavior needed.

**Step 2: Verify the structural change**

Run: `rg -n "N2|N9|layer_scroll|scroll" config/silakka54.keymap`
Expected: the plain base `&kp N2` and `&kp N9` are gone or replaced at those positions, and the new scroll layer is present.

### Task 4: Implement the scroll layer mappings and speed behavior

**Files:**
- Modify: `config/silakka54.keymap`

**Step 1: Add mirrored continuous scroll bindings**

Map left-hand scroll movement:
- `A` -> scroll up
- `Z` -> scroll down
- `X` -> scroll left
- `C` -> scroll right

Map right-hand scroll movement:
- `'` -> scroll up
- `/` -> scroll down
- `,` -> scroll left
- `.` -> scroll right

Use ZMK scroll bindings that repeat while held.

**Step 2: Keep button bindings on the scroll layer**

Map:
- `S/D/F` -> left/middle/right button
- `J/K/L` -> left/middle/right button

Use the same press/release semantics as the mouse layer.

**Step 3: Keep scroll speed constant while preserving the tuned mouse ramp**

Do not add the mouse delayed-turbo ramp to scroll. Preserve the existing tuned mouse `&mmv` settings, but configure scroll behavior so it remains constant-speed.

**Step 4: Verify the scroll layer and speed intent are present**

Run: `rg -n "layer_scroll|msc|SCRL|WHEEL|LCLK|MCLK|RCLK|ZMK_POINTING_DEFAULT_MOVE_VAL|time-to-max-speed-ms|acceleration-exponent|delay-ms" config/silakka54.keymap`
Expected: the keymap shows the new scroll layer, mirrored scroll bindings, preserved button mappings, and the tuned mouse `&mmv` block.

### Task 5: Re-verify the mouse layer mappings remain correct

**Files:**
- Read/verify: `config/silakka54.keymap`

**Step 1: Re-check the mouse movement bindings**

Confirm left-hand movement:
- `A` -> mouse up
- `Z` -> mouse down
- `X` -> mouse left
- `C` -> mouse right

Confirm right-hand movement:
- `'` -> mouse up
- `/` -> mouse down
- `,` -> mouse left
- `.` -> mouse right

**Step 2: Re-check the mouse button bindings**

Confirm:
- `S/D/F` -> left/middle/right button
- `J/K/L` -> left/middle/right button

**Step 3: Verify the final mouse + scroll mapping exists**

Run a targeted search after implementation, for example:
`rg -n "layer_mouse|layer_scroll|mkp|mmv|msc|MOVE_UP|MOVE_DOWN|MOVE_LEFT|MOVE_RIGHT|SCRL|WHEEL|LCLK|MCLK|RCLK" config/silakka54.keymap`
Expected: all requested mirrored mouse and scroll mappings are visible on the new layers.

### Task 6: Update README and Vial notes

**Files:**
- Modify: `README.md`
- Modify: `docs/vial-notes.md`

**Step 1: Add the new layer description to README**

Document:
- `1` and `0` tap/hold behavior for the mouse layer
- `2` and `9` tap/hold behavior for the scroll layer
- the mouse layer purpose
- the scroll layer purpose
- the left-hand `A/Z/X/C` movement/scroll cluster and `S/D/F` button cluster
- the right-hand `'`/`/`/`,`/`.` movement/scroll cluster and `J/K/L` button cluster
- that mouse movement starts precise and ramps to a faster top speed after roughly 300ms
- that scroll remains constant-speed

**Step 2: Update Vial/QMK compatibility notes**

Document in `docs/vial-notes.md`:
- how the mirrored ZMK mouse and scroll layers are represented in `vial-export.vil`
- whether the hold-on-`1`/`0` and hold-on-`2`/`9` layer-taps can be represented directly
- whether mouse movement acceleration/timing, constant-speed scrolling, and mouse button hold behavior are fully representable in the export
- that mouse timing/tuning changes must stay synchronized in the Vial export/docs notes whenever `ZMK_POINTING_DEFAULT_MOVE_VAL` or `&mmv` values change
- any ZMK-only behavior that must remain approximate or transparent in Vial

**Step 3: Verify docs match implementation**

Run: `rg -n "mouse layer|scroll layer|A/Z/X/C|S/D/F|J/K/L|300ms|precise|fast|constant|tap.*1|tap.*0|tap.*2|tap.*9|hold.*mouse|hold.*scroll|Vial|QMK|vial-export" README.md docs/vial-notes.md`
Expected: README and Vial notes reflect the mirrored mouse+scroll behavior, the 300ms mouse acceleration ramp, the constant scroll behavior, and any export caveats.

### Task 7: Update the Vial export artifact

**Files:**
- Modify: `vial-export.vil`

**Step 1: Inspect the current Vial representation**

Run: `rg -n "KC_1|LALT_T\(KC_LBRACKET\)|LT|MO\(|TD\(|KC_MS_|MS_|BTN" vial-export.vil`
Expected: locate the existing base-layer `1` slot and any currently represented layer-tap, mouse, or button behaviors.

**Step 2: Patch the export to mirror the new reachable behavior as closely as possible**

Update `vial-export.vil` so it reflects:
- base `1` and `0` as layer-taps to the mouse layer if supported by the export model
- base `2` and `9` as layer-taps to the scroll layer if supported by the export model
- the mouse layer positions for both left and right mirrored clusters
- the scroll layer positions for both left and right mirrored clusters
- any required Vial macro, tap-dance, or transparent fallback for behaviors that do not have a trustworthy native export equivalent

Do not try to encode ZMK-specific mouse acceleration timing in the Vial export unless the model can represent it honestly; document the limitation instead. Likewise, if constant-speed scroll behavior cannot be represented faithfully, document that limitation rather than faking parity. If a commit changes `ZMK_POINTING_DEFAULT_MOVE_VAL` or any `&mmv` timing field, the same commit must also update `docs/vial-notes.md` so the export/documentation stays in sync with the ZMK source of truth.

Prefer a conservative export:
- represent only behavior the Vial/QMK artifact can honestly express
- leave unsupported ZMK-only behavior transparent or documented as approximate

**Step 3: Verify the export changed in the expected places**

Run: `rg -n "KC_1|KC_2|KC_9|LT|MO\(|KC_MS_|MS_|BTN|WH_|WHEEL|QMK|Vial" vial-export.vil docs/vial-notes.md`
Expected: the export and notes show the mirrored mouse- and scroll-layer-related changes or explicitly document limitations, including synced notes about mouse timing.

### Task 8: Verify the change before claiming completion

**Files:**
- Modify: `config/silakka54.keymap`
- Modify: `README.md`
- Modify: `docs/vial-notes.md`
- Modify: `vial-export.vil`
- Modify: `docs/generated/silakka54.yaml`
- Modify: `docs/generated/silakka54.svg`
- Create: `docs/plans/2026-04-18-mouse-layer-design.md`
- Create: `docs/plans/2026-04-18-mouse-layer.md`

**Step 1: Check the diff**

Run: `git diff -- config/silakka54.keymap README.md docs/vial-notes.md vial-export.vil docs/generated/silakka54.yaml docs/generated/silakka54.svg docs/plans/2026-04-18-mouse-layer-design.md docs/plans/2026-04-18-mouse-layer.md`
Expected: diff only shows the approved mirrored mouse-layer, Vial export, generated docs, and notes changes.

**Step 2: Run build verification**

Run: `make build`
Expected: the firmware builds successfully.

**Step 3: Sanity-check key behavior on device**

Confirm manually:
- tap `1` types `1`
- tap `0` types `0`
- tap `2` types `2`
- tap `9` types `9`
- hold `1` enables mouse layer while held
- hold `0` enables mouse layer while held
- hold `2` enables scroll layer while held
- hold `9` enables scroll layer while held
- `A/Z/X/C` and `'`/`/`/`,`/`.` on the mouse layer start with precise movement and ramp to a faster top speed after about 300ms
- `A/Z/X/C` and `'`/`/`/`,`/`.` on the scroll layer scroll continuously at constant speed
- `S/D/F` hold and release mouse buttons correctly on both layers
- `J/K/L` hold and release mouse buttons correctly on both layers

**Step 4: Sanity-check the Vial artifact**

Confirm manually or by inspection:
- the `1`/`0` mouse-layer positions and `2`/`9` scroll-layer positions are updated in `vial-export.vil`
- mirrored mouse and scroll layer positions are updated as far as the format can honestly represent them
- mouse timing sync notes and any unsupported behavior are called out in `docs/vial-notes.md`
- no unrelated Vial layers/macros were changed accidentally

**Step 5: Commit**

```bash
git add config/silakka54.keymap README.md docs/vial-notes.md vial-export.vil docs/generated/silakka54.yaml docs/generated/silakka54.svg docs/plans/2026-04-18-mouse-layer-design.md docs/plans/2026-04-18-mouse-layer.md
git commit -m "feat(keymap): add mirrored scroll layer"
```
