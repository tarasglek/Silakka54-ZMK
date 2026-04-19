# Mouse Layer on Hold-1/0 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Make both `1` and `0` act as tap=digit, hold=`mouse layer`, with mirrored mouse controls on both halves: `A/Z/X/C` + `S/D/F` on the left and `'`/`/`/`,`/`.` + `J/K/L` on the right, and tune mouse movement to start precise and ramp to fast mode after about 300ms.

**Architecture:** Keep the existing `1`/`0` layer-tap entry points and expand the dedicated mouse layer so it exposes the same movement/button behavior on both halves. Use ZMK pointing bindings for continuous movement and button press/release behavior, and tune the stock `&mmv` acceleration curve instead of adding a custom multi-stage mouse mode: override the default move magnitude to `1400`, keep `delay-ms = <0>`, and use `time-to-max-speed-ms = <300>` with `acceleration-exponent = <2>` so short holds stay more precise while longer holds ramp into a faster cursor speed. Then update the human-facing docs, generated keymap docs, and Vial/QMK compatibility artifacts to match as closely as possible.

**Tech Stack:** ZMK device-tree keymap config, ZMK pointing bindings, Markdown docs, Vial export JSON

**Current repo state:** The structural mouse-layer work is already partially landed in the current branch history (`34005c9`, `c14e84e`): `1`/`0` already act as mouse-layer taps, the mirrored mouse bindings already exist, and the README/Vial artifacts were already updated once. Treat this plan as the canonical follow-up for the movement-tuning pass and for re-validating/syncing the docs and export artifacts after that tuning work. In practice, Tasks 2, 3, 5, 6, and 7 are mostly structural re-verification against the already-landed layout, while Task 4 is the main new implementation delta.

---

## Execution checklist

- [x] Confirm existing ZMK pointing bindings and target mirrored mapping
- [x] Verify `1`/`0` hold-tap structure is present
- [x] Add mouse movement tuning (`ZMK_POINTING_DEFAULT_MOVE_VAL=1400`, `&mmv` 300ms ramp)
- [x] Re-verify mirrored mouse layer mappings
- [x] Sync README wording with the tuned mouse behavior
- [x] Sync `docs/vial-notes.md` with Vial/QMK approximation limits
- [x] Re-check `vial-export.vil` against the intended reachable behavior
- [x] Regenerate `docs/generated/silakka54.yaml` and `docs/generated/silakka54.svg`
- [x] Verify diff and run `make build`
- [ ] Record any remaining manual hardware checks

### Task 1: Confirm the exact ZMK mouse bindings already available in this repo

**Files:**
- Read: `config/silakka54.keymap`
- Read: `config/macros.dtsi`

**Step 1: Inspect existing pointing references**

Run: `rg -n "mkp|mmv|msc|pointing|LCLK|MCLK|RCLK" config`
Expected: find any existing pointing-related bindings or confirm only the include is present.

**Step 2: Record the target mapping**

Confirm the intended mouse layer mapping in notes:
- left hand:
  - `A` up
  - `Z` down
  - `X` left
  - `C` right
  - `S` left button
  - `D` middle button
  - `F` right button
- right hand:
  - `'` up
  - `/` down
  - `,` left
  - `.` right
  - `J` left button
  - `K` middle button
  - `L` right button

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
- a mouse layer exists with the requested mirrored left/right mappings

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

### Task 4: Tune the mouse movement curve for precise-then-fast behavior

**Files:**
- Modify: `config/silakka54.keymap`

**Step 1: Override the default max movement value before including ZMK pointing defines**

Set the mouse-move default magnitude to `1400` so the eventual top speed is meaningfully faster than the ZMK default of `600`.

**Step 2: Configure `&mmv` for a 300ms delayed-turbo ramp**

Add or update an `&mmv` node so it uses:
- `time-to-max-speed-ms = <300>`
- `acceleration-exponent = <2>`
- `delay-ms = <0>`

This should make short holds feel more precise while longer holds ramp into a faster movement mode.

**Step 3: Verify the tuning is present**

Run: `rg -n "ZMK_POINTING_DEFAULT_MOVE_VAL|time-to-max-speed-ms|acceleration-exponent|delay-ms|&mmv" config/silakka54.keymap`
Expected: the keymap shows the `1400` move value override and the `&mmv` tuning block with the 300ms ramp.

### Task 5: Implement the mouse layer mappings

**Files:**
- Modify: `config/silakka54.keymap`

**Step 1: Add continuous movement bindings**

Map left-hand movement:
- `A` -> mouse up
- `Z` -> mouse down
- `X` -> mouse left
- `C` -> mouse right

Map right-hand movement:
- `'` -> mouse up
- `/` -> mouse down
- `,` -> mouse left
- `.` -> mouse right

Use ZMK mouse movement bindings that repeat while held.

**Step 2: Add mouse button bindings**

Map left-hand buttons:
- `S` -> left button
- `D` -> middle button
- `F` -> right button

Map right-hand buttons:
- `J` -> left button
- `K` -> middle button
- `L` -> right button

Use bindings with press/release semantics so key hold maps to mouse-button hold.

**Step 3: Verify the final mapping exists**

Run a targeted search after implementation, for example:
`rg -n "layer_mouse|mkp|mmv|MOVE_UP|MOVE_DOWN|MOVE_LEFT|MOVE_RIGHT|LCLK|MCLK|RCLK" config/silakka54.keymap`
Expected: all requested mirrored mappings are visible on the new layer.

### Task 6: Update README and Vial notes

**Files:**
- Modify: `README.md`
- Modify: `docs/vial-notes.md`

**Step 1: Add the new layer description to README**

Document:
- `1` and `0` tap/hold behavior
- the mouse layer purpose
- the left-hand `A/Z/X/C` movement and `S/D/F` button cluster
- the right-hand `'`/`/`/`,`/`.` movement and `J/K/L` button cluster
- that mouse movement now starts precise and ramps to a faster top speed after roughly 300ms

**Step 2: Update Vial/QMK compatibility notes**

Document in `docs/vial-notes.md`:
- how the mirrored ZMK mouse layer is represented in `vial-export.vil`
- whether the hold-on-`1`/`0` layer-taps can be represented directly
- whether mouse movement acceleration/timing and mouse button hold behavior are fully representable in the export
- any ZMK-only behavior that must remain approximate or transparent in Vial

**Step 3: Verify docs match implementation**

Run: `rg -n "mouse layer|A/Z/X/C|S/D/F|J/K/L|300ms|precise|fast|tap.*1|tap.*0|hold.*mouse|Vial|QMK|vial-export" README.md docs/vial-notes.md`
Expected: README and Vial notes reflect the mirrored behavior, the 300ms acceleration ramp, and any export caveats.

### Task 7: Update the Vial export artifact

**Files:**
- Modify: `vial-export.vil`

**Step 1: Inspect the current Vial representation**

Run: `rg -n "KC_1|LALT_T\(KC_LBRACKET\)|LT|MO\(|TD\(|KC_MS_|MS_|BTN" vial-export.vil`
Expected: locate the existing base-layer `1` slot and any currently represented layer-tap, mouse, or button behaviors.

**Step 2: Patch the export to mirror the new reachable behavior as closely as possible**

Update `vial-export.vil` so it reflects:
- base `1` and `0` as layer-taps to the mouse layer if supported by the export model
- the mouse layer positions for both left and right mirrored clusters
- any required Vial macro, tap-dance, or transparent fallback for behaviors that do not have a trustworthy native export equivalent

Do not try to encode ZMK-specific acceleration timing in the Vial export unless the model can represent it honestly; document the limitation instead.

Prefer a conservative export:
- represent only behavior the Vial/QMK artifact can honestly express
- leave unsupported ZMK-only behavior transparent or documented as approximate

**Step 3: Verify the export changed in the expected places**

Run: `rg -n "KC_1|LT|MO\(|KC_MS_|MS_|BTN|QMK|Vial" vial-export.vil docs/vial-notes.md`
Expected: the export and notes show the mirrored mouse-layer-related changes or explicitly document limitations.

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
- hold `1` enables mouse layer while held
- hold `0` enables mouse layer while held
- `A/Z/X/C` start with precise movement and ramp to a faster top speed after about 300ms
- `'`/`/`/`,`/`.` start with precise movement and ramp to a faster top speed after about 300ms
- `S/D/F` hold and release mouse buttons correctly
- `J/K/L` hold and release mouse buttons correctly

**Step 4: Sanity-check the Vial artifact**

Confirm manually or by inspection:
- the `1`/`0` positions and mirrored mouse layer positions are updated in `vial-export.vil`
- any unsupported behavior is called out in `docs/vial-notes.md`
- no unrelated Vial layers/macros were changed accidentally

**Step 5: Commit**

```bash
git add config/silakka54.keymap README.md docs/vial-notes.md vial-export.vil docs/generated/silakka54.yaml docs/generated/silakka54.svg docs/plans/2026-04-18-mouse-layer-design.md docs/plans/2026-04-18-mouse-layer.md
git commit -m "feat(keymap): mirror mouse layer on both halves"
```
