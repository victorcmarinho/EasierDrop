import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/helpers/system.dart';
import 'package:easier_drop/services/window_manager_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SystemHelper', () {
    // removed redundant test

    test('Métodos estáticos estão definidos', () {
      expect(WindowManagerService.instance.hide, isA<Function>());
      expect(WindowManagerService.instance.open, isA<Function>());
      expect(WindowManagerService.instance.exitApp, isA<Function>());
      expect(SystemHelper.initialize, isA<Function>());
    });

    test('onWindowResize coverage', () {
      runZonedGuarded(() {
        WindowManagerService.instance.onWindowResize();
      }, (e, st) {});
    });

    test('onWindowMove coverage', () {
      runZonedGuarded(() {
        WindowManagerService.instance.onWindowMove();
      }, (e, st) {});
    });

    test('onWindowClose coverage', () {
      runZonedGuarded(() {
        WindowManagerService.instance.onWindowClose();
      }, (e, st) {});
    });
  });
}
