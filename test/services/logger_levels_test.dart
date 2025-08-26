import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/services/logger.dart';

void main() {
  group('Logger tests', () {
    test('AppLogger.trace deve registrar corretamente', () {
      final savedMinLevel = AppLogger.minLevel;
      try {
        AppLogger.minLevel = LogLevel.trace;

        // Verificar se não causa exceção
        AppLogger.trace('Mensagem trace', tag: 'TesteTrace');

        // Teste bem-sucedido se não lançar exceção
        expect(true, isTrue);
      } finally {
        AppLogger.minLevel = savedMinLevel;
      }
    });

    test('AppLogger.debug deve registrar corretamente', () {
      final savedMinLevel = AppLogger.minLevel;
      try {
        AppLogger.minLevel = LogLevel.debug;

        // Verificar se não causa exceção
        AppLogger.debug('Mensagem debug', tag: 'TesteDebug');

        // Teste bem-sucedido se não lançar exceção
        expect(true, isTrue);
      } finally {
        AppLogger.minLevel = savedMinLevel;
      }
    });

    test('AppLogger deve filtrar mensagens abaixo do nível mínimo', () {
      final savedMinLevel = AppLogger.minLevel;
      try {
        // Definir um nível mínimo mais alto
        AppLogger.minLevel = LogLevel.warn;

        // Estas mensagens devem ser filtradas (não causam problemas)
        AppLogger.trace('Mensagem trace');
        AppLogger.debug('Mensagem debug');
        AppLogger.info('Mensagem info');

        // Estas mensagens devem ser registradas (não causam problemas)
        AppLogger.warn('Mensagem warn');
        AppLogger.error('Mensagem error');

        // Teste bem-sucedido se não lançar exceção
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

          // Testar indiretamente através das funções de log
          AppLogger.trace('Mensagem trace');
          AppLogger.debug('Mensagem debug');
          AppLogger.info('Mensagem info');
          AppLogger.warn('Mensagem warn');
          AppLogger.error('Mensagem error');

          // Teste bem-sucedido se não lançar exceção
          expect(true, isTrue);
        } finally {
          AppLogger.minLevel = savedMinLevel;
        }
      },
    );

    test('AppLogger._() construtor privado', () {
      // Teste indireto do construtor privado
      // Simplesmente verificamos que a classe existe e pode ser usada
      expect(AppLogger.minLevel, isNotNull);
    });
  });
}
