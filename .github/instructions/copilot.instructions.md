---
applyTo: "**"
---

# ⚡ GitHub Copilot – Instruções Base

Este documento define instruções para o uso do GitHub Copilot em projetos Flutter, Dart e Swift, com foco em **boas práticas, qualidade de código e escalabilidade**.  
Destina-se a desenvolvedores **sêniores** que desejam consistência no desenvolvimento.

---

## 🎯 Contexto

- Sempre gerar código **idiomático** de Flutter/Dart/Swift.
- Evitar soluções simplistas → preferir abordagens **robustas e escaláveis**.
- Assumir que o desenvolvedor tem conhecimento avançado → não sugerir explicações triviais.
- O código deve ser **modular, limpo, testável e reutilizável**.

---

## 📱 Flutter & Dart

- Utilizar **arquiteturas reativas**: Bloc, Riverpod ou ValueNotifier avançado.
- Separar **UI, lógica de negócios e data layer**.
- Sempre usar `const` quando aplicável para otimizar rebuilds.
- Garantir **null safety**; `late` apenas quando indispensável.
- Usar `freezed` para modelos imutáveis e `json_serializable` para serialização.
- Em listas, preferir `ListView.builder` ou `SliverList`.
- Evitar cálculos pesados em `build()` (usar `memoization` ou `Selector`).

---

## 🍏 Swift (iOS / integração com Flutter)

- Usar **Swift moderno**: `async/await`, `struct` em vez de `class` quando aplicável, `Codable` para modelos.
- Seguir boas práticas de integração Flutter ↔ iOS via `MethodChannel` e `EventChannel`.
- Manter `AppDelegate` e `SceneDelegate` organizados e modulares.
- Usar `guard let` para optionals.
- Sempre aplicar `weak self` em closures para evitar retain cycles.
- Seguir padrões do **SwiftLint** para estilo de código.

---

## 🔒 Qualidade e Testes

- Flutter: escrever **testes unitários e widget tests** (`flutter_test`, `mocktail`).
- Swift/iOS: usar **XCTest** para lógica de negócios.
- Configurar **CI/CD** com Fastlane + GitHub Actions.

---

## 🌍 Internacionalização (i18n) com gen-n10n

- Utilizar o [gen-n10n](https://pub.dev/packages/gen_n10n) para geração automática de traduções.
- Idiomas suportados:
  - **Inglês (en)**
  - **Português do Brasil (pt-BR)**
  - **Espanhol (es)**

### Estrutura recomendada
