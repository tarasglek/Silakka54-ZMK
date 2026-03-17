# Silakka54 ZMK Configuration

A ZMK firmware configuration for the **Silakka54** split ergonomic keyboard.

## Overview

The Silakka54 is a 54-key split keyboard that uses the Lily58 shield in ZMK. Since the Lily58 has 58 keys, the 4 keys not present on the Silakka54 are mapped as `&none` (dead keys).

### Hardware

- **Controller**: nice!nano
- **Display**: nice!view
- **Layout**: Split ergonomic (54 keys)
- **Features**: Bluetooth, deep sleep, mouse emulation

## Layers

The keymap includes 5 layers aligned to reachable QMK Vial behavior:

| Layer | Name | Description |
|-------|------|-------------|
| 0 | `qmk-0` | Base layer (QMK layer 0 equivalent) |
| 1 | `qmk-1` | Toggle layer (QMK layer 1 equivalent) |
| 2 | `qmk-2` | Fn/media/nav/Bluetooth (QMK layer 2 equivalent) |
| 3 | `qmk-3` | Macro access layer for `M1`/`M0` |
| 4 | `qmk-4` | Macro access layer for `M5`/`M6`/`M4`/`M3` |

## Features

### QMK-reachable behavior port

- Reachable QMK layers 0–4 are mapped into this ZMK keymap.
- Tap dances:
  - `TD(0)`: tap `PrintScreen`, double-tap `M2`
  - `TD(1)`: single-tap/hold `FN_LT(2, ])`, double-tap `TOG(1)`
- `FN_LT`: custom hold-tap (hold-preferred) that sends `]` on tap and activates layer 2 while held.
- Layer-tap access:
  - Layer 0 thumb `=` key: hold for layer 3 (`M1`/`M0`)
  - Layer 1 thumb `=` key: hold for layer 4 (`M5`/`M6`/`M4`/`M3`)

### Macro set (`M0..M6`)

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
- `LALT + 4 -> F4`

### Fn usage + Studio unlock

- Use `TD(1)` as a normal Fn key:
  - Tap for `]`
  - Hold for momentary layer 2 access
  - Double-tap to toggle layer 1
- `studio_unlock` is on layer 2 so ZMK Studio remains available.

### Bluetooth

- Profiles on layer 2 (`BT_SEL 0..3`)
- Clear bonding via `BT_CLR`

### Display / power

- nice!view support enabled
- Deep sleep enabled (`CONFIG_ZMK_SLEEP=y`)

## Building

Firmware is built automatically via GitHub Actions. Push to the repository to trigger a build.

The workflow generates firmware for:
- `lily58_left` with nice!view
- `lily58_right` with nice!view
- `settings_reset` (for clearing bond information)

### Manual Build

To build locally, follow the [ZMK documentation](https://zmk.dev/docs/development/setup) for setting up a development environment.

## Installation

1. Download the firmware artifacts from GitHub Actions
2. Put your nice!nano into bootloader mode (double-tap reset)
3. Copy the `.uf2` file to the mounted drive
4. Repeat for the other half

## File Structure

```
├── .github/
│   └── workflows/
│       └── build.yml       # GitHub Actions workflow
├── config/
│   ├── lily58.conf         # ZMK configuration options
│   ├── lily58.keymap       # Keymap definition
│   ├── macros.dtsi         # Macro definitions
│   └── west.yml            # West manifest
├── build.yaml              # Build matrix configuration
└── README.md
```

## Resources

- [ZMK Documentation](https://zmk.dev/docs)
- [ZMK Keycodes](https://zmk.dev/docs/keymaps/behaviors)
- [nice!nano Documentation](https://nicekeyboards.com/docs/nice-nano/)
- [nice!view Documentation](https://nicekeyboards.com/docs/nice-view/)

## License

This configuration is provided as-is for personal use with the Silakka54 keyboard.