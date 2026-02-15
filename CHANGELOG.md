# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.2] - 2026-02-14

### Added
- **Check for Updates**: Added a "Check for Updates..." menu item to the macOS menu bar for easy access to software updates.
- **Dedicated Update Window**: Updates are now managed in a standalone, always-on-top window that ensures users don't miss important releases.
- **Shake Gesture Settings**: New settings panel to toggle and fine-tune shake gesture parameters (`reversalTimeout` and `requiredReversals`).
- **Max Shake Windows**: Implemented a limit for simultaneous floating windows to ensure system stability.

### Improved
- **User Experience**: The update window features a strict, focused design with no navigation distractions and explicit action buttons.
- **Testing**: Implemented a comprehensive suite of widget tests for the update screen, ensuring reliability across all states (loading, available, error).
- **Permission Management**: The app now refreshes shake permissions automatically on app resume.
- **Native Logic**: Migrated macOS plugin management to a modern Flutter-generated Swift package for better compatibility.

### Fixed
- **Dark Theme Accessibility**: Fixed an issue where the filename badge text was difficult to read in dark mode.

## [1.1.1] - 2026-01-06

### Added
- **Homebrew Integration**: Users can now install Easier Drop via Homebrew (`brew install --cask easier-drop`).
- **Release Automation**: The `release.sh` script now automatically updates the Homebrew Cask and website documentation versions.

### Optimization
- **Binary Splitting**: Implemented split builds for Apple Silicon (arm64) and Intel (x64), reducing the app size by ~45%.
- **Size Reduction**: Enabled code obfuscation and debug symbol stripping for release builds.
- **Asset Cleanup**: Removed unused assets from the production bundle (saving ~2.4MB).

## [1.1.0] - 2025-12-31

### Added
- **Multi-Window Support**: Now supports multiple windows! Shake your mouse while dragging files to spawn a new EasierDrop window at your cursor location.
- **Native Shake Detection**: Added native macOS shake gesture detection for seamless multi-window interaction.
- **Visual Feedback**: Real-time file processing states with shimmer effects, success animations, and improved error visibility using `AsyncFileWrapper`.
- **Analytics & Telemetry**: Integrated Aptabase for anonymous usage insights and error tracking, replacing the internal logger.
- **Environment Configuration**: Added support for `.env` files processed at build-time using `--dart-define`, accessed via a unified `AppConfig` (removing `flutter_dotenv`).
- **Tray Management**: Introduced `TrayService` for more reliable and consistent system tray interactions.
- **Minimalist Multi-Window UI**: Secondary windows now feature a cleaner, borderless interface without title bars or system buttons.
- **Clipboard Integration**: Now supports pasting files directly into the drop zone using `Cmd + V`. Copy files in Finder and paste them seamlessly!
- **Video Demo**: Added a video demonstration to the documentation and homepage for better onboarding.
- **Settings Window**: Dedicated preferences window to customize opacity, "Always on Top" mode, and "Launch at Login" options.
- **Window Management**:
    - **Opacity Control**: Adjust window opacity in real-time.
    - **Always on Top**: Toggle to keep the drop zone above other windows.
- **System Integration**:
    - **Launch at Login**: Option to start the app automatically.
    - **Shortcuts**: `Cmd + ,` to open Preferences.
    - **Tray Menu**: Added "Preferences..." option.
- **Localization**: Settings UI fully localized (English, Portuguese, Spanish).

### Improved
- **Architecture**: Migrated to a Repository pattern with `FileRepository` for cleaner separation of concerns.
- **Performance**: Optimized file addition with parallel validation, batch updates, and cached file lists for smoother operation.
- **Rendering**: Significantly reduced widget rebuilds in the file grid, improving UI responsiveness.
- **Service Refactoring**: Refactored `UpdateService` and `TrayService` with dependency injection and improved testability.
- **Testing Suite**: Replaced obsolete tests with a comprehensive new suite of unit and widget tests using a TDD approach, ensuring >85% coverage.
- **Native Integration**: Centralized custom channel setup for more robust multi-window communication.
- **Code Centralization**: Unified file addition logic in `FilesProvider` to support both Drag & Drop and Clipboard operations consistently.

### Improved
- **Shake Gesture Sensitivity**: Significantly lowered the shake threshold and reduced required reversals, making the "Shake to Select" gesture much easier and more reliable to trigger.
- **Navigation Architecture**: Refactored screen selection to use modern named routes (`/`, `/settings`, `/share`), improving code maintainability and scalability.

### Fixed
- **Shake Gesture Reliability**: Addressed issues where the shake gesture was difficult to trigger by tuning native parameters and adding robust logging for easier debugging.


### Fixed
- **UI Stability**: Resolved `ScrollController` assertion errors by replacing `text_marquee` with the more stable `marquee_text` package, restoring smooth filename scrolling.

### Changed
- Replaced the custom `AppLogger` with a unified `AnalyticsService`.
- Refactored `FilesProvider` and window management logic for better maintainability.
- Moved `flutter_launcher_icons` to `dev_dependencies` to streamline production builds.

### Removed
- **Tray File Count item**: Removed the file count display from the tray menu to keep a cleaner interface.
- **Lottie Dependency**: Removed the `lottie` package to reduce application bundle size and complexity.
- **Obsolete Tests**: Cleaned up the test directory by removing outdated or redundant test files.

## [1.0.4] - 2025-12-28

### Fixed
- **Window Close Behavior**: Fixed issue where clicking the close button (red X) would quit the app instead of minimizing to tray. The app now hides to the background when the window is closed.


## [1.0.3] - 2025-12-27

### Fixed
- **Window Close Behavior**: Fixed issue where clicking the close button (red X) would quit the app instead of minimizing to tray. The app now hides to the background when the window is closed.
- **Dock Icon Management**: Dock icon now appears only when the window is visible and hides when the app is running in the background (tray only).

### Changed
- Clicking the window close button now hides the app to the system tray instead of quitting.
- The app can only be fully closed via the "Fechar o aplicativo" / "Quit application" option in the tray menu.

## [1.0.2] - 2025-12-27

### Added
- **File Previews**: Implemented `QuickLookThumbnailing` on macOS to generate and display high-quality file previews.
- **Visual Staggering**: Added an index-based x-offset to `NSDraggingItem` frames for a staggered visual effect during dragging.
- **Update Service**: Added a service to check for app updates and notify the user.

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
