# Mouse Layer on Hold-1/0 Design

## Summary
Add a dedicated mouse layer that is active while holding the `1` or `0` key. Tapping `1` should still type `1`, and tapping `0` should still type `0`. The mouse layer should be mirrored across both halves, and mouse movement should start precise before ramping to a faster top speed after about 300ms.

## Current repo state
The mirrored mouse-layer structure is already present in the current branch history: `1`/`0` already enter the mouse layer on hold, both halves already expose the mirrored movement/button cluster, and the human-facing docs/export artifacts were already updated once. This design doc now captures the intended final state for the follow-up tuning pass so the remaining work is framed as “add the 300ms precise-then-fast movement tuning and re-sync verification/docs,” not “invent the mirrored layer from scratch.”

## Approved approach
- Replace the plain `1` and `0` bindings on the base layer with layer-tap behavior.
- Tap `1` -> `1`.
- Hold `1` -> activate the mouse layer while held.
- Tap `0` -> `0`.
- Hold `0` -> activate the mouse layer while held.
- On the mouse layer, keep the left-hand cluster:
  - `A` -> mouse up
  - `Z` -> mouse down
  - `X` -> mouse left
  - `C` -> mouse right
  - `S` -> left button
  - `D` -> middle button
  - `F` -> right button
- Add a mirrored right-hand cluster:
  - `'` -> mouse up
  - `/` -> mouse down
  - `,` -> mouse left
  - `.` -> mouse right
  - `J` -> left button
  - `K` -> middle button
  - `L` -> right button
- Mouse movement should repeat while held.
- Tune stock ZMK mouse movement instead of adding a custom staged mode:
  - set `ZMK_POINTING_DEFAULT_MOVE_VAL` to `1400`
  - set `&mmv time-to-max-speed-ms = <300>`
  - set `&mmv acceleration-exponent = <2>`
  - keep `&mmv delay-ms = <0>`
- The intended feel is “delayed turbo”: short holds stay more precise, and longer holds ramp into a faster movement mode after about 300ms.
- Mouse button bindings must use press/release semantics so keyboard key down maps to mouse button down, and keyboard key up maps to mouse button up.

## Files
- `config/silakka54.keymap`
- `README.md`
- `docs/vial-notes.md`
- `vial-export.vil`
- `docs/generated/silakka54.yaml`
- `docs/generated/silakka54.svg`

## Verification
- Tap `1` still types `1`.
- Tap `0` still types `0`.
- Holding `1` activates the mouse layer only while held.
- Holding `0` activates the mouse layer only while held.
- `A/Z/X/C` start precise and ramp to a faster top speed after about 300ms while held.
- `S/D/F` behave as held mouse buttons, not tap-only clicks.
- `'`/`/`/`,`/`.` start precise and ramp to a faster top speed after about 300ms while held.
- `J/K/L` behave as held mouse buttons, not tap-only clicks.
- `docs/vial-notes.md` documents the mirrored mouse layer and any export limitations.
- `vial-export.vil` is updated as far as the Vial/QMK compatibility model can represent the new behavior.
- The generated keymap docs reflect the mirrored mouse layer.
- The keymap still builds cleanly.
