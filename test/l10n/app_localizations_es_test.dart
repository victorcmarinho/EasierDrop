import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  group('AppLocalizations para espanhol (es)', () {
    testWidgets('Carrega corretamente localização em espanhol', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const _TestWidget(),
        ),
      );

      await tester.pumpAndSettle();

      final context = tester.element(find.byType(_TestWidget));
      final localizations = AppLocalizations.of(context)!;

      // Verifica o idioma atual
      expect(localizations.localeName, 'es');

      // Testa valores específicos da localização em espanhol
      expect(localizations.appTitle, 'Easier Drop');
      expect(localizations.dropHere, 'Suelta los archivos aquí');
      expect(localizations.trayFilesNone, '📂 Sin archivos');
      expect(localizations.share, 'Compartir');
      expect(localizations.openTray, 'Abrir bandeja');
      expect(localizations.trayExit, 'Cerrar la aplicación');
      expect(localizations.languageLabel, 'Idioma:');
      expect(localizations.languageEnglish, 'Inglés');
      expect(localizations.languagePortuguese, 'Portugués');
      expect(localizations.languageSpanish, 'Español');

      // Testa método com parâmetros
      expect(localizations.trayFilesCount(1), '📁 Archivos: 1');
      expect(localizations.trayFilesCount(2), '📁 Archivos: 2');
      expect(localizations.semShareHintSome(1), 'Compartir 1 archivo');
      expect(localizations.semShareHintSome(3), 'Compartir 3 archivos');
      expect(
        localizations.semAreaHintHas(1),
        'Contiene 1 archivo. Arrastra para mover o compartir.',
      );
      expect(
        localizations.semAreaHintHas(5),
        'Contiene 5 archivos. Arrastra para mover o compartir.',
      );
      expect(localizations.semRemoveHintSome(1), 'Eliminar 1 archivo');
      expect(localizations.semRemoveHintSome(4), 'Eliminar 4 archivos');
    });
  });
}

class _TestWidget extends StatelessWidget {
  const _TestWidget();

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
