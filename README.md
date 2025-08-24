<div align="center">

# Easier Drop

Uma pequena ferramenta desktop (atualmente macOS) feita em Flutter para tornar o fluxo de mover arquivos entre pastas mais rápido e fluido.

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
- Arraste o lote para fora (drag out) para mover para outra pasta / app
- Visual empilhado dos ícones (ícones reais do sistema, quando disponíveis)
- Compartilhamento rápido usando o menu de compartilhamento do sistema (Share Plus)
- Ícones em cache com política LRU para reduzir chamadas nativas
- Tray icon com menu para reabrir / encerrar

## Capturas (futuro)

Adicionar screenshots / GIF demonstrando fluxo quando finalizado.

## Arquitetura

- Flutter + Provider para estado simples (`FilesProvider`)
- Canais de plataforma (`file_drop_channel`, `file_icon_channel`) para:
  - Receber eventos de arquivos soltos
  - Obter ícones de arquivos do macOS
- Cache LRU por extensão para ícones (limite configurado em `FileIconHelper`)
- Janela configurada com `window_manager` e ícone de tray via `tray_manager`

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
- Internacionalização (strings atualmente em pt-BR)

## Roadmap Sugerido

- [ ] Extrair serviço dedicado para drop / drag out (separar da UI)
- [ ] Internacionalização com `intl`
- [ ] Suporte Windows & Linux (plugins ou adaptações nativas equivalentes)
- [ ] Múltiplas coleções (multi “shelves”) simultâneas
- [ ] Ações rápidas (ex: copiar caminho, compactar, enviar)
- [ ] Histórico / recentes
- [ ] Opções de tema avançadas / transparência
- [ ] Testes automatizados (unidade e integração de canal)

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
