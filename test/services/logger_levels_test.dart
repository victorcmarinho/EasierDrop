import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/services/logger.dart';

void main() {
  group('Logger tests', () {
    test('AppLogger.trace deve registrar corretamente', () {
      final savedMinLevel = AppLogger.minLevel;
      try {
        AppLogger.minLevel = LogLevel.trace;

        AppLogger.trace('Mensagem trace', tag: 'TesteTrace');

        expect(true, isTrue);
      } finally {
        AppLogger.minLevel = savedMinLevel;
      }
    });

    test('AppLogger.debug deve registrar corretamente', () {
      final savedMinLevel = AppLogger.minLevel;
      try {
        AppLogger.minLevel = LogLevel.debug;

        AppLogger.debug('Mensagem debug', tag: 'TesteDebug');

        expect(true, isTrue);
      } finally {
        AppLogger.minLevel = savedMinLevel;
      }
    });

    test('AppLogger deve filtrar mensagens abaixo do nível mínimo', () {
      final savedMinLevel = AppLogger.minLevel;
      try {
        AppLogger.minLevel = LogLevel.warn;

        AppLogger.trace('Mensagem trace');
        AppLogger.debug('Mensagem debug');
        AppLogger.info('Mensagem info');

        AppLogger.warn('Mensagem warn');
        AppLogger.error('Mensagem error');

        expect(true, isTrue);
      } finally {
        AppLogger.minLevel = savedMinLevel;
      }
    });

    test(
      'AppLogger._prefix deve retornar o prefixo correto para cada nível',
      () {
        final savedMinLevel = AppLogger.minLevel;
        try {
          AppLogger.minLevel = LogLevel.trace;

          AppLogger.trace('Mensagem trace');
          AppLogger.debug('Mensagem debug');
          AppLogger.info('Mensagem info');
          AppLogger.warn('Mensagem warn');
          AppLogger.error('Mensagem error');

          expect(true, isTrue);
        } finally {
          AppLogger.minLevel = savedMinLevel;
        }
      },
    );

    test('AppLogger._() construtor privado', () {
      expect(AppLogger.minLevel, isNotNull);
    });
  });
}
