# EasyLaunchPad

A full-screen app launcher that recreates the classic Launchpad experience. On macOS 15+ (where Launchpad has been removed), it brings back the original full-screen grid, frosted-glass background, pagination, search, delete mode, global hotkey and trackpad gestures.

## Features

- **Full-screen presentation**: instant overlay window (no Space-switching delay)
- **Classic visuals**: blurred wallpaper + gradient dimming, multi-page grid, page dots
- **App management**: auto-scans `/Applications`, `/System/Applications`, `~/Applications`; manual add, hide (restorable), move to Trash
- **Live search**: type to filter instantly, with match highlighting
- **Global hotkey**: F4 by default, customizable with conflict detection
- **Keyboard navigation**: arrow keys, left/right to switch pages, Return to open, Esc to dismiss
- **Trackpad gestures**: two/three-finger swipe or scroll wheel page switching (debounced), pinch to close
- **Delete mode**: hold Option to jiggle icons with delete badges
- **Customization**: 4 icon size levels, icon entry animation toggle, system apps toggle
- **Multi-display**: opens on the screen under the mouse cursor with exact full-screen sizing

## Requirements

- macOS 15.0 or later
- Apple Silicon or Intel

## Installation

Download the installer from the [Releases](https://github.com/NonchalantLudens/EasyLaunchPad/releases) page, either way:

- **DMG**: download the `.dmg` and drag EasyLaunchPad into the Applications folder
- **PKG installer**: download the `.pkg` and follow the installation wizard

Press **F4** (or your custom hotkey) to open the launcher.

> Auto-launch at login requires the app to be installed in `/Applications`, then enable Settings → General → Launch at login.

## Usage

| Action | How |
|---|---|
| Open / Close | F4 or custom global hotkey; click the menu bar icon |
| Open an app | Click the icon / select and press Return |
| Switch pages | Left/Right arrows / two-finger swipe / scroll wheel (debounced) |
| Search | Just type (no need to click the field) / Cmd+F to focus |
| Delete mode | Hold Option → icons jiggle → click × → Hide or Move to Trash |
| Dismiss | Esc / click on empty space |

## Build

```bash
# Generate the Xcode project and build
xcodegen generate
xcodebuild -project EasyLaunchPad.xcodeproj -scheme EasyLaunchPad build

# Build the DMG (with a customized install page)
./scripts/build-dmg.sh
```

## Project structure

```
Sources/
├── Models/        # AppItem, IconSizeLevel
├── Services/      # App scanning, window control, hotkey, icon/wallpaper caches
├── Settings/      # Settings model and persistence
└── Views/         # SwiftUI interface
Tests/             # Unit tests
scripts/           # Packaging and icon generation scripts
```

## License

[MIT](LICENSE) © 2026 NonchalantLudens
