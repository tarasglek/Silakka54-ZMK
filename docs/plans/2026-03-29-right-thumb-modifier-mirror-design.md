# Mirrored Thumb Navigation Layers Design

## Summary
Replace the old asymmetric thumb/layer arrangement with mirrored thumb-accessed layers that are easier to visualize in the keymap, and make that visualization a committed repo artifact generated from the real ZMK config.

## Approved design
Thumb roles become symmetric across both hands:
- `[` and `=` enter the **navigation layer**
- `]` and `-` enter the **desktop-move layer**

These are layer-oriented roles, not generic modifier-state tricks.

## Direction cluster
Use the same right-hand direction cluster in both layers:
- `,` = Left
- `.` = Down
- `/` = Right
- `'` = Up

### Navigation layer behavior
On the navigation layer:
- `,` -> Left Arrow
- `.` -> Down Arrow
- `/` -> Right Arrow
- `'` -> Up Arrow
- `;` -> Alt+Tab
- `Tab` -> Alt+Tab
- the approved mirrored slot for close-window should send `Alt+F4`

### Desktop-move layer behavior
On the desktop-move layer:
- `,` -> Ctrl+Alt+Left
- `.` -> Ctrl+Alt+Down
- `/` -> Ctrl+Alt+Right
- `'` -> Ctrl+Alt+Up

## Scope changes from earlier designs
- Keep layers because they are easier to visualize.
- Remove the old dependency on layers 3 and 4 for these actions.
- Remove dedicated desktop-switching keys such as Ctrl+Gui+Left and Ctrl+Gui+Right.
- Keep screenshot behavior separate where it already exists.
- Fold the old separate Alt+F4 combo idea into this mirrored layer design instead of tracking it as a standalone change.

## Benefits
- Left/right thumb symmetry
- One visible direction cluster with two clearly visualized modes
- Less reliance on combos and mod-tap timing quirks
- Easier maintenance and documentation
- A reproducible generated SVG that README can reference directly

## Files likely involved
- `Makefile`
- `config/lily58.keymap`
- `config/macros.dtsi`
- `README.md`
- `docs/vial-notes.md`
- generated keymap visualization files such as `docs/generated/*.yaml` and `docs/generated/*.svg`

## Verification
- Confirm the thumb bindings enter the intended layers symmetrically.
- Confirm the direction cluster on those layers matches the approved behaviors.
- Confirm the mirrored layout includes the approved `Alt+F4` position.
- Confirm layers 3/4 are removed or no longer needed for navigation/macros.
- Confirm desktop-switching macros using Ctrl+Gui are removed.
- Confirm the Makefile can regenerate the committed keymap YAML/SVG artifacts.
- Confirm README references the generated SVG.
- Optionally compare before/after generated SVGs to validate the visual change.
