# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2025-12-26

### Added
- Implementado `flutter_launcher_icons` para padronização de ícones.
- Ativação de geração de símbolos de catálogo de strings.

### Changed
- Refatoração da interface da `WelcomeScreen` com layout aprimorado.
- Tamanho fixo da janela inicial definido para 250x250.
- Migração de *entitlements* para configurações nativas do Xcode.
- Alvo de implantação do macOS atualizado para 11.0.
- Atualização de ativos promocionais.

### Removed
- Arquivos de *entitlements* de depuração obsoletos.

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
