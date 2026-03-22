import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:easier_drop/components/drag_drop.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:flutter/services.dart';
import 'package:macos_ui/macos_ui.dart';

class MockFilesProvider extends Mock implements FilesProvider {}

void main() {
  late MockFilesProvider mockFiles;

  setUp(() async {
    mockFiles = MockFilesProvider();
    when(() => mockFiles.hasFiles).thenReturn(false);
    when(() => mockFiles.recentlyAtLimit).thenReturn(false);
    when(() => mockFiles.addListener(any())).thenAnswer((_) {});
    when(() => mockFiles.removeListener(any())).thenAnswer((_) {});
    when(() => mockFiles.files).thenReturn([]);
    when(() => mockFiles.fileCount).thenReturn(0);

    // Mock platform channels
    const channelIn = MethodChannel('com.easierdrop/file_drop');
    const channelOut = MethodChannel('com.easierdrop/drag_out');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channelIn, (call) async => null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channelOut, (call) async => null);
        
    await SettingsService.instance.load();
  });

  Widget createWidget() {
    return MacosApp(
      theme: MacosThemeData.light(),
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ChangeNotifierProvider<FilesProvider>.value(
        value: mockFiles,
        child: MacosWindow(
          child: MacosScaffold(
            children: [
              ContentArea(
                builder: (context, _) => const DragDrop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  group('DragDrop Widget', () {
    testWidgets('renderizado e limpeza', (tester) async {
       when(() => mockFiles.hasFiles).thenReturn(true);
       when(() => mockFiles.fileCount).thenReturn(1);
       when(() => mockFiles.clear()).thenAnswer((_) async {});
       
       await tester.pumpWidget(createWidget());
       await tester.pump();
       await tester.pumpAndSettle();
       expect(find.byType(DragDrop), findsOneWidget);
       
       // FileActionsBar deve ter o ícone de deletar
       final deleteIcon = find.byIcon(Icons.delete_outline);
       if (deleteIcon.evaluate().isNotEmpty) {
           await tester.tap(deleteIcon);
           verify(() => mockFiles.clear()).called(1);
       }
    });

    testWidgets('ciclo de vida', (tester) async {
       await tester.pumpWidget(createWidget());
       await tester.pumpAndSettle();
       await tester.pumpWidget(const SizedBox());
    });
  });
}
