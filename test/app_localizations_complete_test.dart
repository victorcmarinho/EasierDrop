import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'AppLocalizations deve carregar corretamente para todos os locales suportados',
    (WidgetTester tester) async {
      // Teste para inglês
      await _pumpLocalized(tester, const Locale('en'));
      expect(find.text('Drop files here'), findsOneWidget);

      // Teste para português
      await _pumpLocalized(tester, const Locale('pt'));
      expect(find.text('Solte arquivos aqui'), findsOneWidget);

      // Teste para espanhol
      await _pumpLocalized(tester, const Locale('es'));
      expect(find.text('Suelta archivos aquí'), findsOneWidget);
    },
  );

  test(
    'lookupAppLocalizations deve retornar a classe correta para cada locale',
    () {
      final en = lookupAppLocalizations(const Locale('en'));
      final pt = lookupAppLocalizations(const Locale('pt'));
      final es = lookupAppLocalizations(const Locale('es'));

      expect(en.dropHere, 'Drop files here');
      expect(pt.dropHere, 'Solte arquivos aqui');
      expect(es.dropHere, 'Suelta archivos aquí');
    },
  );

  test(
    'lookupAppLocalizations deve lançar exceção para locale não suportado',
    () {
      expect(
        () => lookupAppLocalizations(const Locale('de')),
        throwsA(isA<FlutterError>()),
      );
    },
  );

  test(
    'AppLocalizations.delegate.isSupported deve identificar corretamente locales suportados',
    () {
      final delegate = AppLocalizations.delegate;

      expect(delegate.isSupported(const Locale('en')), isTrue);
      expect(delegate.isSupported(const Locale('pt')), isTrue);
      expect(delegate.isSupported(const Locale('es')), isTrue);
      expect(delegate.isSupported(const Locale('de')), isFalse);
    },
  );

  test('AppLocalizations.delegate.shouldReload deve retornar false', () {
    final delegate = AppLocalizations.delegate;
    expect(delegate.shouldReload(delegate), isFalse);
  });
}

Future<void> _pumpLocalized(WidgetTester tester, Locale locale) async {
  await tester.pumpWidget(
    Localizations(
      locale: locale,
      delegates: const [
        AppLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      child: Builder(
        builder: (context) {
          final loc = AppLocalizations.of(context)!;
          return Directionality(
            textDirection: TextDirection.ltr,
            child: Text(loc.dropHere),
          );
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}
