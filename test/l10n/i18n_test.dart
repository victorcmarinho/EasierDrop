import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:easier_drop/l10n/app_localizations.dart';

void main() {
  testWidgets('Loads English strings', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('en'),
        home: SizedBox.shrink(),
      ),
    );
    final ctx = tester.element(find.byType(SizedBox));
    expect(AppLocalizations.of(ctx)!.share, 'Share');
    expect(AppLocalizations.of(ctx)!.settingsGeneral, 'General');
  });

  testWidgets('Loads Portuguese strings', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('pt'),
        home: SizedBox.shrink(),
      ),
    );
    final ctx = tester.element(find.byType(SizedBox));
    expect(AppLocalizations.of(ctx)!.share, 'Compartilhar');
    expect(AppLocalizations.of(ctx)!.settingsGeneral, 'Geral');
  });

  testWidgets('Pluralization (English) works', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('en'),
        home: SizedBox.shrink(),
      ),
    );
    final ctx = tester.element(find.byType(SizedBox));
    final loc = AppLocalizations.of(ctx)!;
    expect(loc.semShareHintSome(1), contains('1 file'));
    expect(loc.semShareHintSome(3), contains('3 files'));
  });

  testWidgets('Pluralization (Portuguese) works', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('pt'),
        home: SizedBox.shrink(),
      ),
    );
    final ctx = tester.element(find.byType(SizedBox));
    final loc = AppLocalizations.of(ctx)!;

    expect(loc.semShareHintSome(1), contains('1'));
    expect(loc.semShareHintSome(2), contains('2'));
  });
}
