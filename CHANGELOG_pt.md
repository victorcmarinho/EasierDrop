# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
e este projeto adere ao [Versionamento Semântico](https://semver.org/spec/v2.0.0.html).

## [1.1.2] - 14-02-2026

### Adicionado
- **Verificar Atualizações**: Adicionado um item "Verificar Atualizações..." no menu do macOS para facilitar o acesso.
- **Janela de Atualização Dedicada**: As atualizações agora são gerenciadas em uma janela independente e sempre no topo.
- **Configurações de Gesto de Shake**: Novo painel de configurações para ativar/desativar e ajustar os parâmetros do gesto de balançar (`reversalTimeout` e `requiredReversals`).
- **Limite de Janelas de Shake**: Implementado um limite máximo de janelas flutuantes simultâneas para garantir a estabilidade do sistema.

### Melhorado
- **Experiência do Usuário**: A janela de atualização possui um design focado, sem distrações de navegação e com botões de ação explícitos.
- **Testes**: Implementado um conjunto abrangente de testes de widget para a tela de atualização.
- **Gerenciamento de Permissões**: O app agora atualiza as permissões de shake automaticamente ao retomar o foco.
- **Lógica Nativa**: Migração do gerenciamento de plugins do macOS para um Swift Package moderno gerado pelo Flutter.

### Corrigido
- **Acessibilidade no Tema Escuro**: Corrigido um problema onde o texto do badge do nome do arquivo era difícil de ler no modo escuro.

## [1.1.1] - 06-01-2026

### Adicionado
- **Integração com Homebrew**: Usuários agora podem instalar o Easier Drop via Homebrew (`brew install --cask easier-drop`).
- **Automação de Release**: O script `release.sh` agora atualiza automaticamente o Cask do Homebrew e as versões da documentação do site.

### Otimização
- **Divisão de Binários**: Implementado builds separados para Apple Silicon (arm64) e Intel (x64), reduzindo o tamanho do app em ~45%.
- **Redução de Tamanho**: Ativado ofuscação de código e remoção de símbolos de debug em builds de release.
- **Limpeza de Assets**: Removidos assets não utilizados do bundle de produção (economia de ~2.4MB).

## [1.1.0] - 31-12-2025

### Adicionado
- **Suporte Multi-Janelas**: Agora com suporte a múltiplas janelas! Balance o mouse enquanto arrasta arquivos para criar uma nova janela do EasierDrop na posição do cursor.
- **Detecção Nativa de Shake**: Adicionada detecção nativa de gesto de balançar no macOS.
- **Feedback Visual**: Estados de processamento em tempo real com efeitos shimmer, animações de sucesso e melhor visibilidade de erros usando `AsyncFileWrapper`.
- **Analytics & Telemetria**: Integrado Aptabase para insights de uso anônimos e rastreamento de erros.
- **Configuração de Ambiente**: Suporte para arquivos `.env` processados em tempo de build usando `--dart-define`.
- **Gerenciamento de Tray**: Introduzido `TrayService` para interações mais confiáveis com o ícone da barra de sistema.
- **UI Minimalista Multi-Janela**: Janelas secundárias agora possuem uma interface mais limpa, sem barras de título.
- **Integração com Área de Transferência**: Suporte para colar arquivos diretamente usando `Cmd + V`.
- **Vídeo de Demonstração**: Adicionado vídeo demonstrativo na documentação e homepage.
- **Janela de Configurações**: Janela de preferências dedicada com design "Liquid Glass" (Blur + Translucidez).
- **Gerenciamento de Janelas**:
    - **Controle de Opacidade**: Ajuste a opacidade da janela em tempo real.
    - **Sempre no Topo**: Opção para manter a zona de drop acima de outras janelas.
- **Integração com o Sistema**:
    - **Abrir no Login**: Opção para iniciar o app automaticamente.
    - **Atalhos**: `Cmd + ,` para abrir Preferências.
    - **Menu de Tray**: Adicionada opção "Preferências...".
- **Localização**: UI de configurações totalmente localizada (Inglês, Português, Espanhol).

### Melhorado
- **Arquitetura**: Migração para o padrão Repository com `FileRepository`.
- **Performance**: Otimização da adição de arquivos com validação paralela e atualizações em lote.
- **Renderização**: Redução significativa de rebuilds na grade de arquivos.
- **Refatoração de Serviços**: Refatorados `UpdateService` e `TrayService` para melhor testabilidade.
- **Suíte de Testes**: Substituição de testes obsoletos por uma nova suíte abrangente (>85% de cobertura).

### Ajustes
- **Sensibilidade do Gesto de Shake**: Reduzido o limite de balanço necessário para facilitar o acionamento do gesto.
- **Arquitetura de Navegação**: Refatorada a seleção de telas para usar rotas nomeadas modernas.

### Corrigido
- **Confiabilidade do Shake**: Ajuste de parâmetros nativos e adição de logs para depuração.
- **Estabilidade da UI**: Resolvido erro de `ScrollController` substituindo `text_marquee` pelo pacote `marquee_text`.

## [1.0.4] - 28-12-2025

### Corrigido
- **Comportamento de Fechar Janela**: Corrigido erro onde fechar a janela encerrava o app em vez de minimizar para o tray.

## [1.0.3] - 27-12-2025

### Corrigido
- **Comportamento de Fechar Janela**: Agora o app permanece rodando em segundo plano ao fechar a janela.
- **Gerenciamento do Ícone no Dock**: O ícone do Dock agora aparece apenas quando a janela está visível.

## [1.0.2] - 27-12-2025

### Adicionado
- **Previews de Arquivo**: Implementado `QuickLookThumbnailing` para visualização de alta qualidade.
- **Efeito Visual ao Arrastar**: Adicionado deslocamento visual escalonado ao arrastar múltiplos itens.
- **Serviço de Atualização**: Adicionado serviço para verificar novas versões.

## [1.0.1] - 26-12-2025

### Adicionado
- Ícones padronizados via `flutter_launcher_icons`.

## [1.0.0] - 25-12-2025

### Adicionado
- **Drag & Drop**: Arraste arquivos para a prateleira flutuante.
- **Drag Out**: Mova ou copie arquivos coletados em lote.
- **Experiência Nativa**: Construído com `macos_ui` para integração total.
- **Ícone de Tray**: Acesso rápido para mostrar/esconder a prateleira ou sair.
- **Localização**: Suporte para Inglês, Português e Espanhol.
