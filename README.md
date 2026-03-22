<div align="center">

<img src="https://raw.githubusercontent.com/victorcmarinho/EasierDrop/main/assets/icon/icon.png" width="128" alt="Easier Drop Icon">

# Easier Drop

**The missing drag-and-drop shelf for macOS.**

[🇺🇸 English](README.md) | [🇧🇷 Português](README_pt.md) | [🇪🇸 Español](README_es.md)

[**🌐 Website**](https://easierdrop.victorcmarinho.app/)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-macOS-lightgrey.svg)](https://www.apple.com/macos/)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=flat&logo=dart&logoColor=white)](https://dart.dev)
[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=flat&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Tests](https://github.com/victorcmarinho/EasierDrop/actions/workflows/test.yml/badge.svg)](https://github.com/victorcmarinho/EasierDrop/actions/workflows/test.yml)
[![Coverage Status](https://coveralls.io/repos/github/victorcmarinho/EasierDrop/badge.svg?branch=main)](https://coveralls.io/github/victorcmarinho/EasierDrop?branch=main)

</div>

## 🚀 Why Easier Drop?

**Ever felt the frustration of dragging a file only to realize the destination app is hidden behind three other windows?** 

Easier Drop is your native macOS productivity companion that ends the window-shuffling madness. It provides a **temporary shelf**—a floating zone where you can "stash" anything (files, images, text) from any app. Gather your pile, navigate freely, and drop everything at once when you're ready.

> **It's like a physical shelf for your digital workflow. Free, open-source, and natively fast.**

---

## ✨ Power Features (v1.1.2)

### 📦 Collect Anywhere, Instantly
Drag from Finder, Safari, Photos, or even your code editor. Your files stay put until you're ready to move them.
> ![Collecting Files](https://raw.githubusercontent.com/victorcmarinho/EasierDrop/main/assets/promo/useged-2.png)
> *Stash files from multiple sources into one organized stack.*

### 🛠️ Multi-Window Magic
Need to keep separate piles for different projects? Open multiple Easier Drop windows anywhere on your screen.
> ![Multi-Window Support](https://raw.githubusercontent.com/victorcmarinho/EasierDrop/main/assets/promo/multi_window.png)
> *Productivity doubled: manage different stacks for different tasks.*

### 🤝 Native Shake-to-Select
Feeling the "shake"? Just shake your mouse while dragging a file to instantly spawn a new Easier Drop window exactly at your cursor.
> ![Shake Gesture](https://raw.githubusercontent.com/victorcmarinho/EasierDrop/main/assets/promo/shake_gesture.gif)
> *The most natural way to spawn a drop zone on the fly.*

### 📋 Clipboard Integration
Already copied something? Just `Cmd + V` over the drop zone to add it to your shelf. Seamless integration with Finder and system clipboards.
> ![Clipboard Integration](https://raw.githubusercontent.com/victorcmarinho/EasierDrop/main/assets/promo/demo.webp)
> *Paste files directly into your workflow without redundant dragging.*

### 💎 Customizable Settings
A powerful preferences window to tailor Easier Drop to your workflow. Fine-tune the shake gesture sensitivity, adjust window opacity, and toggle features like "Always on Top" or "Launch at Login."
> ![Settings UI](https://raw.githubusercontent.com/victorcmarinho/EasierDrop/main/assets/promo/settings_ui.png)
> *Personalize every detail of your drop zones for maximum productivity.*

### ⚡️ Always on Top & Native Speed
Built with Flutter and native macOS hooks, Easier Drop is incredibly lightweight and stays visible above your work so it's always there when you need it.

---

## 🛠 Installation & Security

### Download App
[**Download Latest Release**](https://github.com/victorcmarinho/EasierDrop/releases)

### Homebrew
You can also install via Homebrew:

```bash
brew tap victorcmarinho/easier-drop https://github.com/victorcmarinho/EasierDrop
brew install --cask easier-drop
```

### ⚠️ Important: Gatekeeper Bypass
Since Easier Drop is an independent hobby/study project, it **does not have a paid Apple Developer subscription** ($99/year). 

Consequently, macOS will apply a security quarantine that prevents the app from opening, showing messages like "App is damaged" or "Developer cannot be verified." **This happens even if you install via Homebrew.**

**To fix this, you MUST run this command in Terminal after installation:**

```bash
sudo xattr -rd com.apple.quarantine "/Applications/Easier Drop.app"
```

#### 🖱️ Visual Alternative (No Terminal)
If you're not comfortable with the Terminal:
1. Try to open **Easier Drop** in your Applications folder.
2. When the security warning pops up, click **'OK'**.
3. Go to **System Settings** > **Privacy & Security**.
4. Scroll to the bottom and find the **'Security'** section.
5. You'll see a notice about Easier Drop. Click **'Open Anyway'**.
6. Enter your Mac password and confirm. You're all set!

> **Why is this necessary?** Without the $99/year fee, Apple doesn't allow automatic "notarization." This process manually removes the quarantine flag that macOS puts on apps downloaded from the internet without an official signature.

### Accessibility Issues?
If the shake gesture stops working after an update:
1. Go to *System Settings > Privacy & Security > Accessibility*.
2. Remove **Easier Drop** from the list using the minus (-) button.
3. Open the app and allow it to request permission again from scratch.

---

## ❤️ Support the Project & Apple Subscription

Easier Drop will remain free and open-source. However, to remove these security warnings and make life easier for all users, our goal is to acquire an official Apple Developer subscription.

**Goal: $100/year** via GitHub Sponsors.

If Easier Drop makes your life easier, consider helping us reach this goal! With the subscription, we can notarize the app, removing the need for terminal commands or manual bypasses.

<div align="center">
  <a href="https://github.com/sponsors/victorcmarinho">
    <img src="https://img.shields.io/badge/Sponsor-❤️-pink?style=for-the-badge" alt="Sponsor">
  </a>
</div>

---


## ⌨️ Pro Shortcuts

- `Cmd + V`: Paste copied files directly to the shelf.
- `Cmd + Backspace`: Clear the entire shelf.
- `Cmd + C`: Copy all shelf items back to the clipboard.
- `Cmd + Shift + C`: Quickly share items via the macOS Share Menu.
- `Cmd + ,`: Open Preferences.

---

## 🤝 Contributing

We love contributors! 
1. **Fork** the project.
2. **Create** your feature branch.
3. **Submit** a Pull Request.

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---

## 🛠️ Technical Overview

### How it Works
Easier Drop is built as a macOS desktop application that leverages Flutter for the UI and native macOS APIs for system integration.
- **Drag & Drop Logic**: Utilizes native platform channels and the `desktop_multi_window` package to manage multiple shelf instances.
- **State Management**: Uses the `Provider` pattern to synchronize files across multiple windows in real-time.
- **Native Integration**: Implements a custom `MacOSShakeMonitor` using native Swift hooks to detect the shake gesture during drags.
- **Persistence**: File references are managed in memory for speed, with transient path validation to ensure data integrity.

### Tech Stack
- **Framework**: [Flutter](https://flutter.dev) (macOS Desktop)
- **Language**: Dart & Swift (for native hooks)
- **State Management**: Provider
- **Local Analytics**: Aptabase
- **UI Components**: `macos_ui` for native look & feel

### Getting Started
To run the project locally:
1. Ensure you have the [Flutter SDK](https://docs.flutter.dev/get-started/install/macos) installed.
2. Clone the repository.
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Create a `.env` file based on `.env.example`:
   ```bash
   cp .env.example .env
   ```
5. Run the application:
   ```bash
   flutter run -d macos
   ```

### Running Tests
We maintain high code quality with comprehensive unit tests.
To execute the test suite:
```bash
flutter test
```
To check coverage:
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Environment Variables
The project uses `.env` files for configuration:
- `APTABASE_APP_KEY`: Your Aptabase telemetry key.
- `GITHUB_LATEST_RELEASE_URL`: API endpoint for update checks.

