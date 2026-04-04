# Vial Port Notes

## Source of truth

- ZMK keymap: `config/silakka54.keymap` is the source of truth for behavior and layer intent
- Vial export: `vial-export.vil` is a backported compatibility artifact derived from the ZMK keymap
- Scope: reachable behavior only

## Reachable scope

### Layers
- Reachable: 0, 1, 2, 3, 4
- Layer roles:
  - `0`: base
  - `1`: `overflow`
  - `2`: `nav`
  - `3`: `desktop-move`
  - `4`: `onehand-mirror`

### Tap dance
- `TD(0)`: `PrintScreen` / `M2`
- `TD(1)`: tap `]`, hold `MO(1)` (`overflow`), double-tap `TG(4)` (`onehand-mirror`)

### Mirrored thumb behavior
- `[`: hold for `Alt`
- `]`: hold for `MO(1)` (`overflow`)
- `-`: hold for `MO(3)` (`desktop-move`)
- `=`: hold for `MO(2)` (`nav`)

### Mirrored direction cluster
Shared visible cluster: `, . / '`

- On `nav`:
  - `,` -> Left
  - `.` -> Right
  - `/` -> Down
  - `'` -> Up

- On `desktop-move`:
  - `,` -> Ctrl+Alt+Left
  - `.` -> Ctrl+Alt+Right
  - `/` -> Ctrl+Alt+Down
  - `'` -> Ctrl+Alt+Up

### Combos
- `H + J -> Left`
- `J + U -> Up`
- `J + K -> Right`
- `J + M -> Down`

## Vial -> ZMK behavior mapping (current)

| Vial representation | ZMK |
|---|---|
| key override `LAlt + ; -> Tab` | `&alt_semi_tab` |
| key override `LAlt + 2 -> F2` | `&alt_2_f2` |
| key override `LAlt + 4 -> F4` | `&alt_4_f4` |
| `[` Alt hold-tap | `&mt LALT LBKT` |
| `]` overflow hold-tap/tap-dance | `&td1` |
| `-` desktop hold-tap | `&fn_lt 3 MINUS` |
| `=` nav hold-tap | `&fn_lt 2 EQUAL` |
| screenshot tap dance | `&td0` |

## Physical mapping notes

- Vial positions are mapped to native Silakka54 logical positions in ZMK `bindings`.
- Native keymap uses exactly 54 active positions (no compatibility placeholders).
- Right-half canonical physical order (layer 0):
  - Row 1: `6 7 8 9 0 Backspace`
  - Row 2: `Y U I O P \\`
  - Row 3: `H J K L ' GUI`
  - Row 4: `N M , . / Tab`
  - Thumbs: `Space - =`

## Vial export backport notes

- `vial-export.vil` has been updated to mirror the current reachable ZMK layers.
- Porting strategy used for this backport:
  - keep `config/silakka54.keymap` as the source of truth for behavior
  - keep the existing `vial-export.vil` structure and only patch dynamic Vial data already present in the export
  - map ZMK hold-taps to native Vial/QMK mod-tap or layer-tap entries where possible
  - map ZMK tap-dances to Vial tap-dance entries
  - preserve existing Vial macros for desktop/workspace movement
  - map ZMK `mod-morph` behaviors with `keep-mods` to Vial `key_override` entries instead of combos
  - restrict overrides to layer 0 when the original ZMK behavior only exists on the base layer
  - leave ZMK-only actions transparent when there is no clean or trustworthy Vial export equivalent
- The three base-layer Alt morphs are represented as left-Alt key overrides in `key_override`:
  - `LAlt + LCTL_T(KC_SCOLON) -> Tab` for ZMK `&alt_semi_tab`
  - `LAlt + 2 -> F2`
  - `LAlt + 4 -> F4`
- Because these overrides use `suppressed_mods = 0`, Alt is preserved during the replacement, matching ZMK `keep-mods` behavior.
- The semicolon morph is attached to the Vial mod-tap keycode `LCTL_T(KC_SCOLON)`, not plain `KC_SCOLON`, because the base-layer semicolon position is itself a mod-tap in both ZMK intent and the backported Vial layout.
- ZMK-only actions without a clean Vial equivalent are left as transparent in the export:
  - Bluetooth profile keys / `BT_CLR`
  - `studio_unlock`
- This backport should be understood as an export-level compatibility mirror, not a full Vial/QMK source port.

## Validation checklist

- Hardware smoke checks:
  - base typing/mod-taps
  - thumb holds (`[` -> Alt, `=` -> nav, `]` -> overflow, `-` -> desktop-move)
  - mirrored direction cluster behavior
  - Alt+Tab on `Tab` in nav layer
  - Alt+Tab on base via `LAlt +` the semicolon mod-tap key (`LCTL_T(KC_SCOLON)`)
  - Alt+F2 / Alt+F4 on base via `Alt+2` / `Alt+4`
  - Studio unlock on layer 2
  - Bluetooth profile keys

## CI artifact provenance used during bring-up

- CI run: https://github.com/tarasglek/Silakka54-ZMK/actions/runs/23198677094
- Firmware artifacts:
  - `silakka54_left nice_view_adapter nice_view-nice_nano-zmk.uf2`
  - `silakka54_right nice_view_adapter nice_view-nice_nano-zmk.uf2`
  - `settings_reset-nice_nano-zmk.uf2`
