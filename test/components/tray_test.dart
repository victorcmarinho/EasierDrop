import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:easier_drop/components/tray.dart';
import 'package:easier_drop/services/tray_service.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:easier_drop/l10n/app_localizations.dart';

class MockTrayService extends Mock implements TrayService {}
class MockSettingsService extends Mock implements SettingsService {}
class FakeAppLocalizations extends Fake implements AppLocalizations {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockTrayService mockTrayService;
  late MockSettingsService mockSettingsService;

  setUpAll(() {
    registerFallbackValue(FakeAppLocalizations());
    registerFallbackValue(MenuItem(key: ''));
  });

  setUp(() {
    mockTrayService = MockTrayService();
    mockSettingsService = MockSettingsService();
    
    TrayService.instance = mockTrayService;
    SettingsService.instance = mockSettingsService;

    when(() => mockTrayService.checkForUpdates()).thenAnswer((_) async {});
    when(() => mockTrayService.addListener(any())).thenReturn(null);
    when(() => mockTrayService.removeListener(any())).thenReturn(null);
    when(() => mockTrayService.rebuildMenu(loc: any(named: 'loc'), currentLocale: any(named: 'currentLocale'))).thenAnswer((_) async {});
    when(() => mockTrayService.handleMenuItemClick(any())).thenAnswer((_) async {});
    
    when(() => mockSettingsService.localeCode).thenReturn('en');
  });

  testWidgets('Tray widget initializes and disposes correctly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Tray(),
      ),
    );

    verify(() => mockTrayService.checkForUpdates()).called(1);
    verify(() => mockTrayService.addListener(any())).called(1);

    await tester.pumpAndSettle();
    
    await tester.pumpWidget(const SizedBox());
    
    verify(() => mockTrayService.removeListener(any())).called(1);
  });

  testWidgets('Tray handles mouse events and timer', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Tray(),
      ),
    );

    // initState call
    verify(() => mockTrayService.checkForUpdates()).called(1);

    final trayState = tester.state(find.byType(Tray)) as TrayListener;
    
    // Simulate mouse down
    trayState.onTrayIconMouseDown();
    verify(() => mockTrayService.checkForUpdates()).called(1); // 1 more call

    // Simulate menu item click
    final menuItem = MenuItem(key: 'test');
    trayState.onTrayMenuItemClick(menuItem);
    verify(() => mockTrayService.handleMenuItemClick(menuItem)).called(1);

    // Trigger timer (6 hours)
    await tester.pump(const Duration(hours: 6));
    verify(() => mockTrayService.checkForUpdates()).called(1); // 1 more call from timer
  });
}
