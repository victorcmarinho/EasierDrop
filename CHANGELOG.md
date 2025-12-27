# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.2] - 2025-12-27

### Added
- **File Previews**: Implemented `QuickLookThumbnailing` on macOS to generate and display high-quality file previews.
- **Visual Staggering**: Added an index-based x-offset to `NSDraggingItem` frames for a staggered visual effect during dragging.

### Changed
- **Optimized Loading**: Improved performance by adding existence checks and optimizing preview/icon loading using JPEG compression and size reduction.
- **Enhanced Reliability**: Refined file icons and preview fetching logic to handle edge cases and missing files.

## [1.0.1] - 2025-12-26

### Added
- Implemented `flutter_launcher_icons` for standardized app icons.
- Enabled string catalog symbol generation.

### Changed
- Refactored `WelcomeScreen` UI with an improved layout.
- Set initial fixed window size to 250x250.
- Migrated entitlements to native Xcode build settings.
- Updated macOS deployment target to 11.0.
- Updated promotional assets.

### Removed
- Obsolete debug entitlements files.

## [1.0.0] - 2025-12-25

### Added

- **Drag & Drop**: Collect files from anywhere in macOS by dragging them into the floating shelf.
- **Drag Out**: Move or copy collected files in bulk to any destination.
- **Native Experience**: Built with `macos_ui` for a seamless system integration.
- **Tray Icon**: Quick access to hide/show the shelf or quit the app.
- **Shortcuts**:
    - `Cmd + Backspace`: Clear all files.
    - `Cmd + Shift + C`: Share files via system share menu.
- **Internationalization**: Support for English (en), Portuguese (pt-BR), and Spanish (es).
