import 'package:flutter_test/flutter_test.dart';

void main() {
  // Este teste aborda a lógica da função que suprime mensagens de overflow
  group('NoOverflowDebugPrint - Teste de lógica de filtragem', () {
    test('Deve filtrar mensagens de overflow corretamente', () {
      // Lista para capturar mensagens que passam pelo filtro
      final List<String> loggedMessages = [];

      // Função de log simulada
      void mockLog(String message) {
        loggedMessages.add(message);
      }

      // Implementação da lógica da função _noOverflowDebugPrint
      void noOverflowDebugPrint(
        String? message,
        void Function(String) logFunction,
      ) {
        if (message == null) return;
        if (message.contains('overflowed') ||
            message.contains('overflow') ||
            message.contains('exceeds') ||
            message.contains('Render') ||
            message.contains('flutter: A RenderFlex')) {
          // Ignora mensagens de overflow
          return;
        }
        // Preserva outras mensagens
        logFunction(message);
      }

      // Testa com mensagem nula
      noOverflowDebugPrint(null, mockLog);
      expect(loggedMessages, isEmpty);

      // Testa com mensagens que devem ser filtradas
      noOverflowDebugPrint('Widget overflowed by 10 pixels', mockLog);
      noOverflowDebugPrint('A RenderFlex has overflow issues', mockLog);
      noOverflowDebugPrint('Content exceeds container', mockLog);
      noOverflowDebugPrint('Render problem detected', mockLog);
      noOverflowDebugPrint('flutter: A RenderFlex has issues', mockLog);
      expect(
        loggedMessages,
        isEmpty,
        reason: 'Mensagens com termos de overflow devem ser filtradas',
      );

      // Testa com mensagens normais que não devem ser filtradas
      noOverflowDebugPrint('Mensagem normal de log', mockLog);
      noOverflowDebugPrint('Outra mensagem importante', mockLog);
      expect(
        loggedMessages,
        hasLength(2),
        reason: 'Mensagens normais devem passar pelo filtro',
      );
      expect(loggedMessages[0], equals('Mensagem normal de log'));
      expect(loggedMessages[1], equals('Outra mensagem importante'));

      // Teste com mensagem que contém palavra similar mas não exata
      noOverflowDebugPrint(
        'Esta mensagem fala sobre flows de trabalho',
        mockLog,
      );
      expect(
        loggedMessages,
        hasLength(3),
        reason: 'Termos parciais não devem ser filtrados',
      );
    });
  });
}
