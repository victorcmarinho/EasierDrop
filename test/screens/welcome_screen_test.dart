import 'package:easier_drop/screens/welcome_screen.dart';
import 'package:easier_drop/screens/file_transfer_screen.dart';
import 'package:easier_drop/helpers/app_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:easier_drop/providers/files_provider.dart';

import 'package:easier_drop/l10n/app_localizations.dart';

class MockFilesProvider extends Mock implements FilesProvider {}

void main() {
  testWidgets('WelcomeScreen displays content and navigates', (
    WidgetTester tester,
  ) async {
    final mockProvider = MockFilesProvider();
    when(() => mockProvider.files).thenReturn([]);
    when(() => mockProvider.hasFiles).thenReturn(false);
    when(() => mockProvider.recentlyAtLimit).thenReturn(false);
    when(() => mockProvider.lastLimitHit).thenReturn(null);
    when(() => mockProvider.isEmpty).thenReturn(true);
    when(() => mockProvider.fileCount).thenReturn(0);

    await tester.pumpWidget(
      ChangeNotifierProvider<FilesProvider>.value(
        value: mockProvider,
        child: MacosApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: WelcomeScreen(),
          routes: {AppConstants.routeShare: (_) => FileTransferScreen()},
        ),
      ),
    );

    expect(find.text('Easier Drop'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.cloud_download), findsOneWidget);

    await tester.pump(AppConstants.welcomeAnimationDuration);
    await tester.pump(AppConstants.welcomeNavigationDelay);

    await tester.pumpAndSettle();

    expect(find.byType(FileTransferScreen), findsOneWidget);
  });
}
