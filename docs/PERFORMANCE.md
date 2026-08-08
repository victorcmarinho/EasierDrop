# EasierDrop — Performance & Stability Guide

> Last updated: March 2026

This document catalogues every optimisation applied in the March 2026 performance sweep, the rationale behind each change, and guidance on how to keep the codebase fast as it grows.

---

## 1. Changes Applied

### 1.1 Dart / Flutter

| # | File | Change | Benefit |
|---|------|--------|---------|
| 1 | `lib/providers/files_provider.dart` | Removed `AnalyticsService.debug()` from the `files` getter | Getter is called on every UI rebuild; logging inside it was O(N) side-effect on a hot path |
| 2 | `lib/services/file_repository.dart` | `validateFile` now uses `file.stat()` only — no open/read | Drops from 2 syscalls (open + read) to 1; `_testReadability` only remains in the sync rescan path |
| 3 | `lib/services/window_manager_service.dart` | `_onSettingsChanged` now diff-checks opacity & always-on-top before calling native bridge | Eliminates redundant cross-process calls when settings haven't changed |
| 4 | `lib/services/window_manager_service.dart` | `onWindowResize` / `onWindowMove` debounced (150 ms) | Prevents hundreds of settings-file writes during a single drag-resize gesture |
| 5 | `lib/controllers/drag_coordinator.dart` | `dispose()` made `async`; `FileDropService.stop()` is now `await`-ed | Eliminates a race condition where the drop listener was cleaned up before the native channel had stopped |
| 6 | `lib/main.macos.dart` | Replaced `AnimatedBuilder` with `ListenableBuilder` | Semantically correct Flutter 3.7+ API; identical performance, clearer intent |
| 7 | `lib/services/settings_service.dart` | Removed `if (this == instance) return;` guard in `dispose` | Subscription is now always cancelled, preventing a file-watcher memory leak |
| 8 | `analysis_options.yaml` | Enabled `prefer_const_constructors`, `use_super_parameters`, `unnecessary_this`, + more | Catches compile-time const opportunities that the Dart VM and tree-shaker can exploit |

### 1.2 Swift / macOS native

| # | File | Change | Benefit |
|---|------|--------|---------|
| 9 | `MacOSFileIconChannel.swift` | `getFileIcon` moved off main thread onto `DispatchQueue.global(.userInitiated)` | `NSWorkspace.shared.icon(forFile:)` + PNG conversion is I/O + CPU-heavy; blocking the main thread caused jank when many files were dropped simultaneously |
| 10 | `MacOSShakeMonitor.swift` | Replaced `Date().timeIntervalSince1970` with `ProcessInfo.processInfo.systemUptime` | Monotonic clock — no timezone/calendar math, zero allocation; called on every mouse-move event |
| 11 | `MacOSDragOutChannel.swift` | `setup()` prunes stale handlers; `isViewAlive` property added | Handlers for closed shake-windows were accumulating indefinitely — fixed without requiring a full `NSMapTable` |

### 1.3 Package Updates

| Package | Before | After | Notes |
|---------|--------|-------|-------|
| `pasteboard` | `^0.4.0` | `^0.5.0` | Bug fixes for clipboard access on macOS Sequoia |

---

## 2. Patterns to Maintain

### ✅ Hot-path discipline
Never add logging, analytics calls, or allocations inside getters that are called during widget rebuilds (e.g. `files`, `fileCount`). Log only in response to user actions or background events.

### ✅ Debounce window geometry callbacks
Any `WindowListener` override (`onWindowResize`, `onWindowMove`) MUST debounce its body. Even a 100–200 ms timer collapses hundreds of interim events into a single settings write.

### ✅ Native-bridge call coalescing
Before calling `windowManager.setX(...)`, compare the new value to the last applied value. Native bridge calls cross a process boundary and are expensive.

### ✅ Background threads for heavy I/O in Swift
All `NSWorkspace`, `QuickLookThumbnailing`, and image-conversion work must run on a background queue. Always dispatch results back to `DispatchQueue.main` before calling Flutter result handlers.

### ✅ Async dispose
Any service that holds a native channel subscription must `await` the stop/cancel call in its `dispose` method to avoid use-after-free races.

---

## 3. Packages to Monitor

Two dependencies were marked **discontinued** by pub.dev:

| Package | Replacement |
|---------|-------------|
| `flutter_markdown` | `flutter_markdown_plus` |
| `marquee_text` | `flutter_chen_common` |

These are non-critical (UI-only) and migration can be done in a future sprint.

---

## 4. Profiling Guide

To validate performance after future changes:

```bash
# Run the analyzer (no warnings allowed)
flutter analyze --no-fatal-infos

# Run all tests
flutter test

# Profile the macOS build (attach Instruments)
flutter run --profile --verbose -d macos
```

Use **Instruments → Time Profiler** to verify:
- `getFileIcon` shows background thread activity (not main)
- `onWindowMove`/`onWindowResize` fires at most ~7 times/sec (debounce working)
- `SettingsService._writeDebounce` does not fire more than once per gesture
