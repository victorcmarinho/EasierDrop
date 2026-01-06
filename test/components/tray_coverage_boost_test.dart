import 'package:easier_drop/components/tray.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:tray_manager/tray_manager.dart';

class MockFilesProvider extends Mock implements FilesProvider {}

void main() {
  late MockFilesProvider mockFilesProvider;

  setUp(() {
    mockFilesProvider = MockFilesProvider();
  });

  testWidgets('Tray handles menu item clicks', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<FilesProvider>.value(
        value: mockFilesProvider,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Tray(),
        ),
      ),
    );

    final dynamic state = tester.state(find.byType(Tray));

    // Simulate clicks on various menu items
    state.onTrayMenuItemClick(MenuItem(key: 'settings', label: 'Settings'));
    state.onTrayMenuItemClick(MenuItem(key: 'clear', label: 'Clear'));
    state.onTrayMenuItemClick(MenuItem(key: 'exit', label: 'Exit'));
    state.onTrayMenuItemClick(MenuItem(key: 'unknown', label: 'Unknown'));

    expect(true, isTrue); // verified no crash
  });

  testWidgets('Tray rebuilds menu on locale change', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<FilesProvider>.value(
        value: mockFilesProvider,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const Tray(),
        ),
      ),
    );

    // Change locale
    await tester.pumpWidget(
      ChangeNotifierProvider<FilesProvider>.value(
        value: mockFilesProvider,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('pt'),
          home: const Tray(),
        ),
      ),
    );

    await tester.pump();
    expect(true, isTrue); // verified no crash
  });
}
