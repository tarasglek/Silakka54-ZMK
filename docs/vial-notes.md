# Vial Port Notes

## Source of truth

- Vial export: `vial-export.vil` (kept in repo)
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
- `TD(1)`: tap `]`, hold `MO(1)` (`overflow`), double-tap `SL(4)` (`onehand-mirror`)

### Mirrored thumb behavior
- `[` and `=`: hold for `MO(3)` (`nav`)
- `]`: hold for `MO(1)` (`overflow`)
- `-`: hold for `MO(4)` (`desktop-move`)

### Mirrored direction cluster
Shared visible cluster: `, . / '`

- On `nav`:
  - `,` -> Left
  - `.` -> Down
  - `/` -> Right
  - `'` -> Up
  - `Tab` -> Alt+Tab

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

## Vial -> ZMK behavior mapping (current)

| Concept | ZMK |
|---|---|
| semicolon mod-tap (Alt morphs to Tab) | `&alt_semi_tab` |
| `2` (Alt morphs to F2) | `&alt_2_f2` |
| `4` (Alt morphs to F4) | `&alt_4_f4` |
| `[` nav hold-tap | `&fn_lt 3 LBKT` |
| `]` overflow hold-tap/tap-dance | `&td1` |
| `-` desktop hold-tap | `&fn_lt 4 MINUS` |
| `=` nav hold-tap | `&fn_lt 3 EQUAL` |
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

## Validation checklist

- Hardware smoke checks:
  - base typing/mod-taps
  - mirrored thumb holds (`[`/`=` -> nav, `]` -> overflow, `-` -> desktop-move)
  - mirrored direction cluster behavior
  - Alt+Tab on `Tab` in nav layer
  - Alt+Tab on base via `Alt+;`
  - Alt+F2 / Alt+F4 on base via `Alt+2` / `Alt+4`
  - Studio unlock on layer 2
  - Bluetooth profile keys

## CI artifact provenance used during bring-up

- CI run: https://github.com/tarasglek/Silakka54-ZMK/actions/runs/23198677094
- Firmware artifacts:
  - `silakka54_left nice_view_adapter nice_view-nice_nano-zmk.uf2`
  - `silakka54_right nice_view_adapter nice_view-nice_nano-zmk.uf2`
  - `settings_reset-nice_nano-zmk.uf2`
