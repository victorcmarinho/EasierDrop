import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:easier_drop/l10n/app_localizations.dart';

void main() {
  testWidgets('Loads English strings', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: [
          AppLocalizationsDelegate(),
          DefaultWidgetsLocalizations.delegate,
          DefaultMaterialLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('en'),
        home: SizedBox.shrink(),
      ),
    );
    final ctx = tester.element(find.byType(SizedBox));
    expect(AppLocalizations.of(ctx).t('share'), 'Share');
  });

  testWidgets('Loads Portuguese strings', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: [
          AppLocalizationsDelegate(),
          DefaultWidgetsLocalizations.delegate,
          DefaultMaterialLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('pt', 'BR'),
        home: SizedBox.shrink(),
      ),
    );
    final ctx = tester.element(find.byType(SizedBox));
    expect(AppLocalizations.of(ctx).t('share'), 'Compartilhar');
  });

  testWidgets('Interpolation works', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: [
          AppLocalizationsDelegate(),
          DefaultWidgetsLocalizations.delegate,
          DefaultMaterialLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('en'),
        home: SizedBox.shrink(),
      ),
    );
    final ctx = tester.element(find.byType(SizedBox));
    final text = AppLocalizations.of(
      ctx,
    ).t('sem.share.hint.some', params: {'count': '3'});
    expect(text, contains('3'));
  });
}
