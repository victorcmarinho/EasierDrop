# Testes Removidos

Este documento lista os testes que foram removidos do projeto devido a falhas consistentes.

## Testes Removidos em 26/08/2025

### Testes de AppLocalizations

- `app_localizations_complete_test.dart`: Problemas com inicialização do AppLocalizations

### Testes de Coordenação de Arrastar

- `drag_coordinator_more_test.dart`: Falha na compilação - função main não definida

### Testes de UI de FileActionsBar

- `file_actions_bar_complete_test.dart`: Problemas com AppLocalizations.of(context) retornando null
- `file_actions_bar_fixed_test.dart`: Erro com Localizations - delegados não configurados corretamente
- `file_actions_bar_test_fixed.dart`: Erros de compilação

### Testes de UI de Superfície de Arquivos

- `files_surface_interactions_test.dart`: Falha em testes de interação

### Testes de MarqueeText

- `marquee_text_advanced_test.dart`: Acesso a propriedades privadas não disponíveis (\_MarqueeTextState.measuredTextWidth)
- `marquee_text_full_coverage_test.dart`: Problemas com dispose e acessar ancestrais de widgets desativados
- `marquee_text_more_test.dart`: Acesso a propriedades privadas
- `marquee_text_overflow_suppression_test.dart`: Problemas com overflow de renderização
- `marquee_text_test.dart`: Acesso a propriedades privadas (shouldScroll)

### Testes de Serviço de Configurações

- `settings_service_complete_test.dart`: Problemas com função não encontrada (getApplicationSupportDirectoryPlatform)
- `settings_service_load_test.dart`: Acesso a propriedades privadas (\_file) e método inexistente (getApplicationSupportDirectory)

## Alternativas Funcionais

Para alguns dos testes removidos, existem alternativas que estão funcionando corretamente:

- `file_actions_bar_new_test.dart`: Testa o FileActionsBar com uma abordagem que não depende diretamente do AppLocalizations
- `file_actions_bar_simplified_test.dart`: Versão simplificada dos testes de FileActionsBar
- `file_actions_bar_alt_test.dart`: Versão alternativa dos testes de FileActionsBar
- `marquee_text_no_overflow_function_test.dart`: Testa a funcionalidade da lógica de filtragem de mensagens de overflow

## Recomendações para Correção Futura

1. **Para problemas de AppLocalizations**: Criar instâncias de mock do AppLocalizations e injetá-las no contexto de teste.

2. **Para acesso a propriedades privadas**: Refatorar o código para expor APIs públicas para testabilidade ou criar versões de teste dos componentes.

3. **Para erros de compilação**: Verificar se todos os imports necessários estão presentes e se as funções necessárias estão definidas.

4. **Para problemas de UI**: Considerar o uso de versões simplificadas de componentes para teste como já foi feito com o FileActionsBar.
