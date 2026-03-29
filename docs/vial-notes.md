# QMK Vial Port Notes

## Source of truth

- Vial export: `qmk-vial.vil` (kept in repo)
- Scope: reachable behavior only

## Reachable scope

### Layers
- Reachable: 0, 1, 2, 3, 4
- Not reachable / out of scope: 5, 6, 7

### Tap dance
- `TD(0)`: `PrintScreen` / `M2`
- `TD(1)`: `]` / `MO(2)` / `TOG(1)`

### Macros
- `M0`: Ctrl+Gui+Left
- `M1`: Ctrl+Gui+Right
- `M2`: Shift+Alt+PrintScreen
- `M3`: Ctrl+Alt+Left
- `M4`: Ctrl+Alt+Right
- `M5`: Ctrl+Alt+Up
- `M6`: Ctrl+Alt+Down

### Combos
- `H + J -> Left`
- `J + U -> Up`
- `J + K -> Right`
- `J + M -> Down`
- `[ + 4 -> Alt+F4`

## QMK -> ZMK behavior mapping

| QMK | ZMK |
|---|---|
| `LCTL_T(KC_SCOLON)` | `&mt LCTRL SEMI` |
| `LALT_T(KC_LBRACKET)` | `&mt LALT LBKT` |
| `LT3(KC_EQUAL)` | `&lt 3 EQUAL` |
| `LT4(KC_EQUAL)` | `&lt 4 EQUAL` |
| `TD(0)` | `&td0` |
| `TD(1)` | `&td1` |
| `M0..M6` | `&m0..&m6` |

## Physical mapping notes

- QMK Vial positions are mapped to Lily58 logical positions in ZMK `bindings`.
- Silakka54 missing positions remain `&none`.
- Right-half canonical physical order (layer 0):
  - Row 1: `6 7 8 9 0 Backspace`
  - Row 2: `Y U I O P \\`
  - Row 3: `H J K L ' GUI`
  - Row 4: `N M , . / Tab`
  - Thumbs: `Space - =`

## Validation checklist

- Hardware smoke checks:
  - base typing/mod-taps
  - Fn and layer access paths
  - Studio unlock on Fn layer
  - macros `M0..M6`
  - combos
  - Bluetooth profile keys

## CI artifact provenance used during bring-up

- CI run: https://github.com/tarasglek/Silakka54-ZMK/actions/runs/23198677094
- Firmware artifacts:
  - `lily58_left nice_view_adapter nice_view-nice_nano-zmk.uf2`
  - `lily58_right nice_view_adapter nice_view-nice_nano-zmk.uf2`
  - `settings_reset-nice_nano-zmk.uf2`
