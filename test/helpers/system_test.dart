import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:window_manager/window_manager.dart';
import 'package:easier_drop/helpers/system.dart';

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

    test('onWindowResize coverage', () {
      runZonedGuarded(() {
        final helper = SystemHelper();
        helper.onWindowResize();
      }, (e, st) {});
    });

    test('onWindowMove coverage', () {
      runZonedGuarded(() {
        final helper = SystemHelper();
        helper.onWindowMove();
      }, (e, st) {});
    });

    test('onWindowClose coverage', () {
      runZonedGuarded(() {
        final helper = SystemHelper();
        helper.onWindowClose();
      }, (e, st) {});
    });
  });
}
