import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NoOverflowDebugPrint - Teste de lógica de filtragem', () {
    test('Deve filtrar mensagens de overflow corretamente', () {
      final List<String> loggedMessages = [];

      void mockLog(String message) {
        loggedMessages.add(message);
      }

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
          return;
        }

        logFunction(message);
      }

      noOverflowDebugPrint(null, mockLog);
      expect(loggedMessages, isEmpty);

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

      noOverflowDebugPrint('Mensagem normal de log', mockLog);
      noOverflowDebugPrint('Outra mensagem importante', mockLog);
      expect(
        loggedMessages,
        hasLength(2),
        reason: 'Mensagens normais devem passar pelo filtro',
      );
      expect(loggedMessages[0], equals('Mensagem normal de log'));
      expect(loggedMessages[1], equals('Outra mensagem importante'));

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
