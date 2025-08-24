<div align="center">

# Easier Drop

Aplicativo desktop nativo para **macOS** (exclusivo) feito em Flutter + macos_ui para acelerar o fluxo de juntar temporariamente vários arquivos e arrastá‑los em lote para um destino.

</div>

## Objetivo

Fornecer uma pequena “caixa flutuante” onde você pode:

1. Arrastar arquivos de qualquer lugar do sistema para dentro dela (soltando na área do app).
2. Reunir vários arquivos ao mesmo tempo sem precisar manter múltiplas janelas lado a lado.
3. Depois pegar esse conjunto e arrastá‑lo em bloco para a pasta de destino desejada, efetivamente movendo/cop iando (dependendo do destino / operação do SO) esses arquivos.

Funcionalidade semelhante ao conceito do aplicativo macOS [Dropover](https://dropoverapp.com/) (que oferece “shelves” flutuantes para coletar itens). O Easier Drop busca oferecer um núcleo mínimo gratuito / open para esse fluxo básico de coletar e soltar múltiplos arquivos, sem ainda replicar todas as funcionalidades avançadas (multi‑shelves, ações instantâneas, upload em nuvem, etc.).

> Inspirado por ideias de usabilidade do Dropover: juntar arquivos temporariamente em um lugar neutro e só então navegar até o destino final com calma e mover tudo de uma vez.

## Principais Recursos (atual)

- Caixa flutuante sempre no topo (alwaysOnTop) e fora da barra de tarefas (skipTaskbar)
- Arraste & solte arquivos para dentro (drag in) via canal nativo macOS
- Arraste o lote para fora (drag out) para mover/copiar para outra pasta / app (canal dedicado `file_drag_out_channel`)
- Visual empilhado dos ícones (ícones reais do sistema, quando disponíveis)
- Compartilhamento rápido usando o menu de compartilhamento do sistema (Share Plus)
- Ícones em cache com política LRU para reduzir chamadas nativas
- Tray icon com menu para reabrir / encerrar

### Drag Out (Como funciona)

O fluxo de arrastar para fora (drag out) é tratado por um canal de plataforma separado (`file_drag_out_channel`).

1. Ao iniciar um gesto de arrastar dentro da área (onPanStart), o app invoca `beginDrag` passando todos os caminhos coletados.
2. O código nativo prepara uma sessão de arraste (`NSDraggingSession`) com ícones reais dos arquivos.
3. Ao soltar em um destino válido, o canal retorna um callback (`fileDropped`) indicando a operação (copy/move) e o app limpa a coleção atual.

Essa separação garante que a lógica de entrada (drag in) e saída (drag out) não se misturem, mantendo o código mais simples de evoluir.

### Atalhos de Teclado

| Ação                     | Atalho                         |
| ------------------------ | ------------------------------ |
| Limpar todos os arquivos | Cmd + Backspace / Cmd + Delete |
| Compartilhar arquivos    | Cmd + Shift + C / Cmd + Enter  |

É necessário que a janela esteja focada (o app já coloca foco automático na área principal).

## Capturas (futuro)

Adicionar screenshots / GIF demonstrando fluxo quando finalizado.

## Arquitetura (resumo)

- Flutter + Provider (`FilesProvider`) para estado.
- UI 100% macOS com `macos_ui` (sem camada Material, app é exclusivo macOS).
- Canais nativos (Swift) dedicados:
  - `file_drop_channel`: eventos de arquivos arrastados para dentro.
  - `file_drag_out_channel`: inicia sessão de drag out (copy/move).
  - `file_icon_channel`: resolve / cacheia ícones reais.
- Cache LRU para ícones de arquivos.
- Tray via `tray_manager`; gerenciamento de janela com `window_manager`.

## Status Atual

MVP funcional focado em:

1. Capturar arquivos arrastados
2. Exibir ícones / placeholders
3. Permitir limpar ou compartilhar
4. Iniciar drag para fora contendo todos os arquivos

Ainda NÃO implementa:

- Múltiplas “shelves” (apenas uma coleção única)
- Ações de processamento (renomear, zipar, ações customizadas)
- Persistência ou histórico de coleções
- Suporte Windows / Linux (planejado)

Internacionalização: concluída via `gen_l10n` (en, pt-BR, es). Seletor de idioma via tray.

## Roadmap (alto nível)

Curto prazo:

- Feedback limite de arquivos (UI) e testes de i18n adicionais.
- Tratamento estruturado de erros nos canais Swift.

Médio prazo:

- Pausar monitor quando janela oculta.
- CI (analyze/test/build) e métricas básicas de uso (opt‑in).

Longo prazo:

- Multi "shelves".
- Port para Windows/Linux (exigirá abstração de canais).
- Ações rápidas pluginizadas.

## Como Rodar (macOS)

Pré‑requisitos:

- Flutter 3.7+ (Dart 3.7+)
- Xcode configurado para build macOS

Passos:

```bash
flutter pub get
flutter run -d macos
```

Para gerar build release:

```bash
flutter build macos
```

## Estrutura Simplificada

```
lib/
	components/      # Widgets UI (drag area, botões, tray dummy)
	helpers/         # Funções de sistema e helpers nativos
	model/           # Modelo FileReference
	providers/       # Estado (FilesProvider)
	screens/         # Telas (FileTransferScreen)
	theme/           # Temas claro/escuro
```

## Licença

Ver arquivo LICENSE.

## Aviso Legal

Este projeto é independente e não é afiliado ao aplicativo Dropover. O nome Dropover é citado apenas como referência de conceito e pertence aos seus respectivos proprietários.

---

Contribuições e sugestões são bem-vindas. Abra uma issue com ideias ou problemas encontrados.
