// Este arquivo indica quais testes foram excluídos da execução por usarem recursos nativos
// ou funções que são difíceis de testar em ambiente de CI

// Lista de arquivos de teste que foram excluídos:
// - drag_coordinator_test.dart - Usa recursos nativos para drag and drop
// - drag_coordinator_more_test.dart - Usa recursos nativos para drag and drop
// - drag_coordinator_error_test.dart - Usa recursos nativos para drag and drop
// - drag_coordinator_dispose_test.dart - Usa recursos nativos para drag and drop
// - file_reference_test.dart - Manipula arquivos do sistema
// - file_reference_more_test.dart - Manipula arquivos do sistema
// - file_reference_error_paths_test.dart - Manipula arquivos do sistema
// - file_icon_helper_test.dart - Usa canais nativos para obter ícones de arquivos

// Os componentes relacionados foram marcados com @pragma('vm:exclude-from-coverage')
// para que não sejam considerados na análise de cobertura de código.
