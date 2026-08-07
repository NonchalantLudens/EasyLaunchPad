# EasyLaunchPad

> Classic Launchpad-style full-screen app launcher for macOS 15+

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![macOS](https://img.shields.io/badge/macOS-15%2B-black.svg)]()
[![Swift](https://img.shields.io/badge/Swift-5-orange.svg)]()
[![Release](https://img.shields.io/github/v/release/NonchalantLudens/EasyLaunchPad)](https://github.com/NonchalantLudens/EasyLaunchPad/releases)

[English](README.md) | [简体中文](README.zh-CN.md)

A full-screen app launcher that recreates the classic Launchpad experience — full-screen grid, frosted-glass background, pagination, search, delete mode, global hotkey and trackpad gestures.

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Troubleshooting](#troubleshooting)
- [Build from Source](#build-from-source)
- [Project Structure](#project-structure)
- [Contributing](#contributing)
- [License](#license)

## Features

- **Full-screen presentation** — instant overlay window, no Space-switching delay
- **Classic visuals** — blurred wallpaper + gradient dimming, multi-page grid, page dots
- **App management** — auto-scans `/Applications`, `/System/Applications`, `~/Applications`; manual add, hide (restorable), move to Trash
- **Live search** — type to filter instantly with match highlighting
- **Global hotkey** — F4 by default, customizable with conflict detection
- **Keyboard navigation** — arrow keys, left/right to switch pages, Return to open, Esc to dismiss
- **Trackpad gestures** — two/three-finger swipe or scroll wheel page switching (debounced), pinch to close
- **Delete mode** — hold Option to jiggle icons with delete badges
- **Customization** — 4 icon size levels, icon entry animation toggle, system apps toggle
- **Multi-display** — opens on the screen under the mouse cursor with exact full-screen sizing

## Requirements

| Requirement | Version |
| --- | --- |
| macOS | 15.0 or later |
| Architecture | Apple Silicon or Intel |

## Installation

### Homebrew (recommended)

The cask definition lives in this repository:

```bash
brew tap NonchalantLudens/EasyLaunchPad https://github.com/NonchalantLudens/EasyLaunchPad.git
brew install --cask easylaunchpad
```

### curl script

Downloads the latest release, verifies SHA-256 and installs to `/Applications`:

```bash
curl -fsSL https://raw.githubusercontent.com/NonchalantLudens/EasyLaunchPad/main/scripts/install.sh | bash
```

### DMG / PKG

Download the installer from the [Releases](https://github.com/NonchalantLudens/EasyLaunchPad/releases) page:

- **DMG** — drag EasyLaunchPad into the Applications folder
- **PKG** — follow the installation wizard

Press **F4** (or your custom hotkey) to open the launcher.

> Auto-launch at login requires the app to be installed in `/Applications`, then enable Settings → General → Launch at login.

## Usage

| Action | How |
| --- | --- |
| Open / Close | F4 or custom global hotkey; click the menu bar icon |
| Open an app | Click the icon / select and press Return |
| Switch pages | Left/Right arrows / two-finger swipe / scroll wheel (debounced) |
| Search | Just type (no need to click the field) / Cmd+F to focus |
| Delete mode | Hold Option → icons jiggle → click × → Hide or Move to Trash |
| Dismiss | Esc / click on empty space |

## Troubleshooting

### "Apple cannot verify EasyLaunchPad is free of malware"

The app is not notarized yet (requires a Developer ID certificate), so Gatekeeper may block the first launch. To open it:

1. **Right-click** (or Control-click) **EasyLaunchPad** in the Applications folder → select **Open** → click **Open** in the dialog.
2. Or open **System Settings → Privacy & Security** → click **Open Anyway** next to the app.
3. Or remove the quarantine flag from the terminal:

   ```bash
   xattr -dr com.apple.quarantine /Applications/EasyLaunchPad.app
   ```

> Homebrew installs (`brew install --cask easylaunchpad`) are not affected.

## Build from Source

```bash
# Generate the Xcode project and build
xcodegen generate
xcodebuild -project EasyLaunchPad.xcodeproj -scheme EasyLaunchPad build

# Run tests
xcodebuild -project EasyLaunchPad.xcodeproj -scheme EasyLaunchPad test

# Package the DMG (with a customized install page)
./scripts/build-dmg.sh

# Package the PKG installer
pkgbuild --component build/DerivedData/Build/Products/Release/EasyLaunchPad.app \
  --install-location /Applications --version 0.1.0 \
  --identifier com.easylaunchpad.app build/EasyLaunchPad-0.1.0.pkg
```

## Project Structure

```text
Sources/
├── Models/        # AppItem, IconSizeLevel
├── Services/      # App scanning, window control, hotkey, icon/wallpaper caches
├── Settings/      # Settings model and persistence
└── Views/         # SwiftUI interface
Tests/             # Unit tests
scripts/           # Packaging and icon generation scripts
Casks/             # Homebrew cask definition
```

## Contributing

Contributions are welcome. Please submit a pull request or open an issue.

## License

[MIT](LICENSE) © 2026 NonchalantLudens
