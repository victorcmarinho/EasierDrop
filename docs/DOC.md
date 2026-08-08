# Documentação do Projeto: Easier Drop

## Visão Geral
O **Easier Drop** é uma aplicação Flutter desktop desenvolvida para facilitar a coleta temporária de arquivos e o arraste em lote para outros destinos. Ele funciona como uma "área de transferência visual" para arquivos.

## Objetivo
Resolver a fricção de mover arquivos entre diferentes pastas, aplicativos ou janelas, permitindo que o usuário "solte" arquivos em uma zona de captura e depois os "arraste" todos de uma vez para o destino final.

## Principais Funcionalidades
- **Suporte Multi-plataforma**: MacOS (nativo) e Web (promocional/estático).
- **Integração com Sistema**: Uso de `tray_manager` para acesso rápido via barra de menus.
- **Gestão de Janelas**: Janelas secundárias para transferências rápidas.
- **Internacionalização**: Suporte completo para Inglês, Português e Espanhol.
- **Analytics**: Telemetria via Aptabase para entender o uso da aplicação.

## Tecnologias Utilizadas
- **Linguagem**: Dart
- **Framework**: Flutter
- **Gerenciamento de Estado**: Provider
- **UI (MacOS)**: macos_ui
- **Outras Bibliotecas**: 
  - `window_manager` para controle de janelas.
  - `desktop_multi_window` para janelas independentes.
  - `path_provider` para acesso ao sistema de arquivos.

## Primeiros Passos
Para rodar o projeto localmente:
1. Instale o Flutter SDK.
2. Execute `flutter pub get`.
3. Para macOS: `flutter run -d macos`.
4. Para Web: `flutter run -d chrome`.
