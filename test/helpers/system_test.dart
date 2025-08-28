import 'package:flutter_test/flutter_test.dart';
import 'package:window_manager/window_manager.dart';
import 'package:easier_drop/helpers/system.dart';

// Este teste foi adaptado para um teste de widget
// devido às limitações de mockar objetos globais finais como trayManager e windowManager
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SystemHelper básico', () {
    test('WindowListener métodos', () {
      final helper = SystemHelper();

      // Deve ser possível criar uma instância e ela implementar WindowListener
      expect(helper, isA<WindowListener>());

      // Chamamos os métodos, mas não podemos verificar o resultado
      // Verificamos apenas se não lança exceção
      expect(() => helper.onWindowResize(), returnsNormally);
      expect(() => helper.onWindowMove(), returnsNormally);
    });
  });
}
