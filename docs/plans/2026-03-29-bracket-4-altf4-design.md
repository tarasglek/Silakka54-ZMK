# Bracket+4 Alt+F4 Design

## Summary
Change the close-window shortcut so it is tied to the physical `[` key rather than the resolved `Alt` modifier state from the mod-tap behavior.

## Problem
The current combo is documented and implemented as `LALT + 4 -> F4`. On this keyboard, the `[` key is also a mod-tap that becomes `Alt` when held. That makes the close-window gesture depend on mod-tap resolution and timing, which is less predictable than a direct combo on the physical keys the user intends to press.

## Approved approach
- Remove the existing `Alt + 4 -> F4` combo.
- Add a new combo for the physical `[` key plus `4`.
- Have that combo emit `Alt+F4` directly.
- Update docs so they describe `[ + 4 -> Alt+F4` instead of `LALT + 4 -> F4`.

## Files
- `config/lily58.keymap`
- `README.md`
- `docs/vial-notes.md`

## Verification
- Build or parse the keymap successfully.
- Confirm the combo definition in `config/lily58.keymap` uses the `[` key position with `4` and sends `LA(F4)`.
- Confirm docs match the implementation.
