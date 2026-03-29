# QMK Vial Port Notes

## Source of truth

- Vial export: `qmk-vial.vil` (kept in repo)
- Scope: reachable behavior only

## Reachable scope

### Layers
- Reachable: 0, 1, 2, 3, 4
- Layer roles:
  - `0`: base
  - `1`: toggle
  - `2`: Fn/media/Bluetooth/Studio
  - `3`: `nav`
  - `4`: `desktop-move`

### Tap dance
- `TD(0)`: `PrintScreen` / `M2`
- `TD(1)`: tap `]`, hold `MO(4)`, double-tap `TOG(1)`

### Mirrored thumb behavior
- `[` and `=`: hold for `MO(3)` (`nav`)
- `]` and `-`: hold for `MO(4)` (`desktop-move`)

### Mirrored direction cluster
Shared visible cluster: `, . / '`

- On `nav`:
  - `,` -> Left
  - `.` -> Down
  - `/` -> Right
  - `'` -> Up
  - `;` -> Alt+Tab
  - `Tab` -> Alt+Tab
  - right GUI-position key -> Alt+F4

- On `desktop-move`:
  - `,` -> Ctrl+Alt+Left
  - `.` -> Ctrl+Alt+Down
  - `/` -> Ctrl+Alt+Right
  - `'` -> Ctrl+Alt+Up

### Combos
- `H + J -> Left`
- `J + U -> Up`
- `J + K -> Right`
- `J + M -> Down`

## QMK -> ZMK behavior mapping (current)

| Concept | ZMK |
|---|---|
| semicolon mod-tap | `&mt LCTRL SEMI` |
| `[` nav hold-tap | `&fn_lt 3 LBKT` |
| `]` desktop hold-tap/tap-dance | `&td1` |
| `-` desktop hold-tap | `&fn_lt 4 MINUS` |
| `=` nav hold-tap | `&fn_lt 3 EQUAL` |
| screenshot tap dance | `&td0` |

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
  - mirrored thumb holds (`[`/`=` -> nav, `]`/`-` -> desktop-move)
  - mirrored direction cluster behavior
  - Alt+Tab on `;` and `Tab` in nav layer
  - Alt+F4 in mirrored nav layer
  - Studio unlock on layer 2
  - Bluetooth profile keys

## CI artifact provenance used during bring-up

- CI run: https://github.com/tarasglek/Silakka54-ZMK/actions/runs/23198677094
- Firmware artifacts:
  - `lily58_left nice_view_adapter nice_view-nice_nano-zmk.uf2`
  - `lily58_right nice_view_adapter nice_view-nice_nano-zmk.uf2`
  - `settings_reset-nice_nano-zmk.uf2`
