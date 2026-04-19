# Mouse Layer on Hold-1/0 Design

## Summary
Add a dedicated mouse layer that is active while holding the `1` or `0` key, plus a dedicated scroll layer that is active while holding the `2` or `9` key. Tapping `1`/`0`/`2`/`9` should still type their digits. The mouse and scroll layers should be mirrored across both halves. Mouse movement should start precise before ramping to a faster top speed after about 300ms, while scroll movement should use a constant speed.

## Current repo state
The mirrored mouse-layer structure is already present in the current branch history: `1`/`0` already enter the mouse layer on hold, both halves already expose the mirrored movement/button cluster, and the human-facing docs/export artifacts were already updated once. This design doc now captures the next follow-up state: keep the tuned mouse layer, add a parallel hold-`2`/`9` scroll layer, and re-sync verification/docs/export notes around both behaviors.

## Approved approach
- Keep the existing `1`/`0` layer-tap behavior for the mouse layer.
- Tap `1` -> `1`.
- Hold `1` -> activate the mouse layer while held.
- Tap `0` -> `0`.
- Hold `0` -> activate the mouse layer while held.
- Add matching layer-tap behavior for a new scroll layer on `2` and `9`.
- Tap `2` -> `2`.
- Hold `2` -> activate the scroll layer while held.
- Tap `9` -> `9`.
- Hold `9` -> activate the scroll layer while held.
- On the mouse layer, keep the left-hand cluster:
  - `A` -> mouse up
  - `Z` -> mouse down
  - `X` -> mouse left
  - `C` -> mouse right
  - `S` -> left button
  - `D` -> middle button
  - `F` -> right button
- Keep the mirrored right-hand mouse cluster:
  - `'` -> mouse up
  - `/` -> mouse down
  - `,` -> mouse left
  - `.` -> mouse right
  - `J` -> left button
  - `K` -> middle button
  - `L` -> right button
- Add a separate scroll layer with the same mirrored physical shape.
- On the scroll layer, map movement keys to scroll directions:
  - left hand: `A` up, `Z` down, `X` left, `C` right
  - right hand: `'` up, `/` down, `,` left, `.` right
- On the scroll layer, keep `S/D/F` and `J/K/L` as the same left/middle/right mouse buttons used on the mouse layer.
- Mouse movement should repeat while held.
- Scroll should use a constant speed rather than a delayed ramp.
- Tune stock ZMK mouse movement instead of adding a custom staged mode:
  - set `ZMK_POINTING_DEFAULT_MOVE_VAL` to `1400`
  - set `&mmv time-to-max-speed-ms = <300>`
  - set `&mmv acceleration-exponent = <2>`
  - keep `&mmv delay-ms = <0>`
- The intended mouse feel is “delayed turbo”: short holds stay more precise, and longer holds ramp into a faster movement mode after about 300ms.
- Mouse button bindings must use press/release semantics so keyboard key down maps to mouse button down, and keyboard key up maps to mouse button up.
- Update docs and the Vial/QMK compatibility artifact to describe both the new scroll layer and the fact that mouse timing/tuning changes must stay synchronized in the export notes.

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
- Tap `2` still types `2`.
- Tap `9` still types `9`.
- Holding `1` activates the mouse layer only while held.
- Holding `0` activates the mouse layer only while held.
- Holding `2` activates the scroll layer only while held.
- Holding `9` activates the scroll layer only while held.
- `A/Z/X/C` and `'`/`/`/`,`/`.` on the mouse layer start precise and ramp to a faster top speed after about 300ms while held.
- `A/Z/X/C` and `'`/`/`/`,`/`.` on the scroll layer scroll continuously at a constant speed while held.
- `S/D/F` and `J/K/L` behave as held mouse buttons on both the mouse and scroll layers, not tap-only clicks.
- `docs/vial-notes.md` documents the mirrored mouse layer, the mirrored scroll layer, and any export limitations.
- `vial-export.vil` is updated as far as the Vial/QMK compatibility model can represent the new behavior, including synced notes about mouse timing changes.
- The generated keymap docs reflect both layers.
- The keymap still builds cleanly.
