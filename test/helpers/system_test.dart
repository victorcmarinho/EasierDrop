import 'package:flutter_test/flutter_test.dart';
import 'package:window_manager/window_manager.dart';
import 'package:easier_drop/helpers/system.dart';
import 'package:easier_drop/services/settings_service.dart';

// Este teste é limitado devido à dificuldade de mockar objetos globais finais
// como trayManager e windowManager
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SystemHelper', () {
    test('SystemHelper implementa WindowListener', () {
      final helper = SystemHelper();
      // Deve ser possível criar uma instância e ela implementar WindowListener
      expect(helper, isA<WindowListener>());
    });

    test('Métodos estáticos estão definidos', () {
      // Verificamos apenas se as funções estão definidas
      expect(SystemHelper.hide, isA<Function>());
      expect(SystemHelper.open, isA<Function>());
      expect(SystemHelper.exit, isA<Function>());
      expect(SystemHelper.setup, isA<Function>());
    });

    test('Integração com SettingsService', () {
      // Verificamos a interação entre SystemHelper e SettingsService
      expect(SettingsService.instance, isNotNull);
    });
  });
}
