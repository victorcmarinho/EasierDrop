# Plano de Ação para Cobertura de Testes 100%

## Arquivos com Baixa Cobertura

Baseado na análise do relatório de cobertura, os seguintes arquivos precisam de atenção:

1. **lib/components/drag_drop.dart** (2.6% cobertura - 1/39 linhas)
2. **lib/components/window_handle.dart** (3.4% cobertura - 1/29 linhas)
3. **lib/main.dart** (7.0% cobertura - 3/43 linhas)
4. **lib/screens/file_transfer_screen.dart** (14.3% cobertura - 3/21 linhas)
5. **lib/components/parts/marquee_text.dart** (61.8% cobertura - 34/55 linhas)
6. **lib/services/settings_service.dart** (95.7% cobertura - 44/46 linhas)
7. **lib/l10n/app_localizations.dart** (89.5% cobertura - 17/19 linhas)
8. **lib/components/parts/file_actions_bar.dart** (96.9% cobertura - 31/32 linhas)
9. **lib/components/mac_close_button.dart** (98.0% cobertura - 48/49 linhas)

## Estratégia para cada arquivo

### 1. lib/components/drag_drop.dart

Desafios:

- Envolve coordenação de arrastar e soltar
- Depende de `DragCoordinator` e `FilesProvider`

Estratégia:

- Criar mocks para `DragCoordinator` e `FilesProvider`
- Testar o ciclo de vida (initState, dispose)
- Testar método `_clearImmediate`
- Testar método `_getButtonPosition`
- Testar o build com diferentes combinações de estado

Teste a ser criado: `test/components/drag_drop_test.dart`

### 2. lib/components/window_handle.dart

Desafios:

- Depende de `window_manager` que interage com o sistema nativo
- Envolve gestos de arrastar

Estratégia:

- Criar um mock para `window_manager`
- Testar os estados de hover e pressed
- Testar o comportamento de reset
- Testar a construção do widget com diferentes tamanhos e configurações

Teste a ser criado: `test/components/window_handle_test.dart`

### 3. lib/main.dart

Desafios:

- Ponto de entrada da aplicação
- Depende de inicialização de sistema
- Contém shortcuts globais

Estratégia:

- Criar mocks para `SystemHelper`, `FilesProvider`, e `SettingsService`
- Testar os atalhos de teclado (\_ClearAllIntent e \_ShareIntent)
- Testar a construção do aplicativo com diferentes configurações de localização

Teste a ser criado: `test/main_test.dart`

### 4. lib/screens/file_transfer_screen.dart

Desafios:

- Depende de `FilesProvider`
- Contém atalhos de teclado

Estratégia:

- Criar um mock para `FilesProvider`
- Testar as ações para ClearFilesIntent e ShareFilesIntent
- Testar a construção do widget

Teste a ser criado: `test/screens/file_transfer_screen_test.dart`

### 5. lib/components/parts/marquee_text.dart

Desafios:

- Envolve animações
- Depende de medições de texto e layout

Estratégia:

- Simular diferentes tamanhos de texto e container
- Testar o comportamento de scrolling quando o texto é muito longo
- Testar a atualização do widget quando o texto muda

Teste a ser criado: `test/components/parts/marquee_text_full_test.dart`

### 6. Outros arquivos com alta cobertura

Para os arquivos com cobertura superior a 80%, vamos apenas complementar os testes existentes para cobrir os casos restantes.

## Implementação

### Fase 1: Preparação

1. Criar classes mock necessárias
2. Preparar estrutura de testes

### Fase 2: Implementação dos testes

1. Implementar testes para cada arquivo, começando pelos de menor cobertura
2. Verificar a cobertura incrementalmente

### Fase 3: Revisão e ajustes

1. Identificar código difícil de testar
2. Marcar como ignorado para cobertura, se necessário, usando anotações

## Casos Especiais

Para código que é especialmente difícil de testar, usaremos anotações para ignorá-lo na cobertura:

```dart
// coverage:ignore-start
// Código difícil de testar
// coverage:ignore-end
```

Isso será usado apenas em último caso, quando não for possível testar o código de forma razoável.

## Pacotes Adicionais para Auxílio em Testes

1. **mockito** - Para criação de mocks
2. **build_runner** - Para geração de código para mocks
3. **network_image_mock** - Se necessário para testar widgets com imagens
4. **flutter_test_utils** - Para testes mais avançados de widgets

## Monitoramento

Após cada implementação, executaremos os testes com cobertura para verificar o progresso:
