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

The keymap includes 5 active layers:

| Layer | Name | Description |
|-------|------|-------------|
| 0 | `qmk-0` | Base typing layer |
| 1 | `qmk-1` | Toggle layer |
| 2 | `qmk-2` | Fn/media/Bluetooth + Studio unlock |
| 3 | `nav` | Navigation layer (arrows + Alt+Tab + Alt+F4) |
| 4 | `desktop-move` | Desktop-move layer (Ctrl+Alt arrows) |

## Features

### Mirrored thumb layer access

- `[` and `=`: tap for key, hold for `nav` layer.
- `]` and `-`: tap for key, hold for `desktop-move` layer.
- `TD(1)` remains on `]`:
  - Tap `]`
  - Hold for `desktop-move`
  - Double-tap toggles layer 1

### Mirrored direction cluster

On both mirrored layers, the visible direction cluster is on `, . / '`:

- `, . / '` on `nav` -> Left / Down / Right / Up arrows
- `, . / '` on `desktop-move` -> Ctrl+Alt+Left / Down / Right / Up

Additional `nav` bindings:
- `;` -> Alt+Tab
- `Tab` -> Alt+Tab
- right GUI-position key -> Alt+F4

### Screenshot behavior

- `TD(0)`: tap `PrintScreen`, double-tap `M2` (Shift+Alt+PrintScreen)

### Combos

- `H + J -> Left`
- `J + U -> Up`
- `J + K -> Right`
- `J + M -> Down`

### Fn usage + Studio unlock

- Layer 2 (`qmk-2`) still carries media/Bluetooth keys and `studio_unlock`.

### Bluetooth

- Profiles on layer 2 (`BT_SEL 0..3`)
- Clear bonding via `BT_CLR`

### Display / power

- nice!view support enabled
- Deep sleep enabled (`CONFIG_ZMK_SLEEP=y`)

## Keymap Visualization

Generated layout docs are committed under `docs/generated/`.

- Regenerate YAML + SVG: `make keymap-svg`
- Canonical rendered keymap: [`docs/generated/silakka54.svg`](docs/generated/silakka54.svg)

![Generated Silakka54 keymap](docs/generated/silakka54.svg)

## Building

Firmware is built automatically via GitHub Actions. Push to the repository to trigger a build.

The workflow generates firmware for:
- `lily58_left` with nice!view
- `lily58_right` with nice!view
- `settings_reset` (for clearing bond information)

### Local Build (Docker)

Requirements:
- Docker
- GNU Make

Run:

```bash
make build
```

Outputs are written to `artifacts/`:
- `artifacts/lily58_left.uf2`
- `artifacts/lily58_right.uf2`
- `artifacts/settings_reset.uf2`

GitHub Actions uses the same `make build` path.

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