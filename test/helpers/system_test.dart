import 'package:flutter_test/flutter_test.dart';
import 'package:window_manager/window_manager.dart';
import 'package:easier_drop/helpers/system.dart';
import 'package:easier_drop/services/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SystemHelper', () {
    test('SystemHelper implementa WindowListener', () {
      final helper = SystemHelper();
      expect(helper, isA<WindowListener>());
    });

    test('Métodos estáticos estão definidos', () {
      expect(SystemHelper.hide, isA<Function>());
      expect(SystemHelper.open, isA<Function>());
      expect(SystemHelper.exit, isA<Function>());
      expect(SystemHelper.initialize, isA<Function>());
    });

    test('Integração com SettingsService', () {
      expect(SettingsService.instance, isNotNull);
    });
  });
}
