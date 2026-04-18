# Mouse Layer on Hold-1 Design

## Summary
Add a dedicated mouse layer that is active while holding the `1` key. Tapping `1` should still type `1`.

## Approved approach
- Replace the plain `1` binding on the base layer with a layer-tap behavior.
- Tap `1` -> `1`.
- Hold `1` -> activate a new mouse layer while held.
- On the mouse layer:
  - `A` -> mouse up
  - `Z` -> mouse down
  - `X` -> mouse left
  - `C` -> mouse right
  - `S` -> left button
  - `D` -> middle button
  - `F` -> right button
- Mouse movement should repeat while held.
- Mouse button bindings must use press/release semantics so keyboard key down maps to mouse button down, and keyboard key up maps to mouse button up.

## Files
- `config/silakka54.keymap`
- `README.md`
- `docs/vial-notes.md`
- `vial-export.vil`

## Verification
- Tap `1` still types `1`.
- Holding `1` activates the mouse layer only while held.
- `A/Z/X/C` move continuously while held.
- `S/D/F` behave as held mouse buttons, not tap-only clicks.
- `docs/vial-notes.md` documents the new mouse layer and any export limitations.
- `vial-export.vil` is updated as far as the Vial/QMK compatibility model can represent the new behavior.
- The keymap still builds cleanly.
