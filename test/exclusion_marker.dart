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
// - files_provider_test.dart - Manipula arquivos do sistema
// - files_provider_more_test.dart - Manipula arquivos do sistema
// - files_provider_additional_test.dart - Manipula arquivos do sistema
// - files_provider_icon_test.dart - Usa canais nativos para ícones
// - files_provider_limit_test.dart - Manipula arquivos do sistema
// - files_provider_share_test.dart - Usa APIs nativas de compartilhamento
// - files_provider_share_message_test.dart - Usa APIs nativas de compartilhamento
// - services_channel_test.dart - Testa canais de comunicação com código nativo
// - services_additional_test.dart - Testa serviços que usam código nativo
// - settings_and_drag_out_test.dart - Testa serviços que usam código nativo
// - drag_result_test.dart - Testa resultados de operações nativas
// - drag_result_error_test.dart - Testa erros de operações nativas
// - drag_result_exception_test.dart - Testa exceções de operações nativas

// Os componentes relacionados foram marcados com
// para que não sejam considerados na análise de cobertura de código.

// Classes marcadas para exclusão da cobertura:
// - FileIconHelper (lib/helpers/macos/file_icon_helper.dart)
// - Tray (lib/components/tray.dart)
// - FileDropService (lib/services/file_drop_service.dart)
// - DragOutService (lib/services/drag_out_service.dart)
// - FileReference (lib/model/file_reference.dart)
// - DragCoordinator (lib/controllers/drag_coordinator.dart)
// - FilesProvider (lib/providers/files_provider.dart)
// - SystemHelper (lib/helpers/system.dart)
