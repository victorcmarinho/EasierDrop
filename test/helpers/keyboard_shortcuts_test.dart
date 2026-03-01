import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:easier_drop/helpers/keyboard_shortcuts.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class MockFilesProvider extends Mock implements FilesProvider {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('KeyboardShortcuts Tests', () {
    late MockFilesProvider mockFilesProvider;

    setUpAll(() {
      registerFallbackValue(Iterable<dynamic>.empty());
    });

    setUp(() {
      mockFilesProvider = MockFilesProvider();
    });

    Future<void> sendShortcut(
      WidgetTester tester,
      List<LogicalKeyboardKey> keys,
    ) async {
      for (final key in keys) {
        await tester.sendKeyDownEvent(key);
      }
      for (final key in keys.reversed) {
        await tester.sendKeyUpEvent(key);
      }
      await tester.pump();
    }

    testWidgets('ClearAllIntent should clear files', (tester) async {
      when(() => mockFilesProvider.hasFiles).thenReturn(true);
      when(() => mockFilesProvider.clear()).thenAnswer((_) async {});

      final focusNode = FocusNode();
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<FilesProvider>.value(
            value: mockFilesProvider,
            child: Shortcuts(
              shortcuts: KeyboardShortcuts.shortcuts,
              child: Builder(
                builder: (context) {
                  return Actions(
                    actions: KeyboardShortcuts.createActions(context),
                    child: Focus(
                      focusNode: focusNode,
                      autofocus: true,
                      child: const SizedBox(),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
      focusNode.requestFocus();
      await tester.pump();

      await sendShortcut(tester, [
        LogicalKeyboardKey.meta,
        LogicalKeyboardKey.backspace,
      ]);
      await tester.pumpAndSettle();

      verify(() => mockFilesProvider.clear()).called(1);
    });

    testWidgets('ShareIntent should trigger share', (tester) async {
      when(() => mockFilesProvider.shared()).thenAnswer((_) async => Object());

      final focusNode = FocusNode();
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<FilesProvider>.value(
            value: mockFilesProvider,
            child: Shortcuts(
              shortcuts: KeyboardShortcuts.shortcuts,
              child: Builder(
                builder: (context) {
                  return Actions(
                    actions: KeyboardShortcuts.createActions(context),
                    child: Focus(
                      focusNode: focusNode,
                      autofocus: true,
                      child: const SizedBox(),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
      focusNode.requestFocus();
      await tester.pump();

      await sendShortcut(tester, [
        LogicalKeyboardKey.meta,
        LogicalKeyboardKey.enter,
      ]);
      await tester.pumpAndSettle();

      verify(() => mockFilesProvider.shared()).called(1);
    });

    testWidgets('PreferencesIntent should open settings', (tester) async {
      const channel = MethodChannel('desktop_multi_window');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            return null;
          });

      final focusNode = FocusNode();
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<FilesProvider>.value(
            value: mockFilesProvider,
            child: Shortcuts(
              shortcuts: KeyboardShortcuts.shortcuts,
              child: Builder(
                builder: (context) {
                  return Actions(
                    actions: KeyboardShortcuts.createActions(context),
                    child: Focus(
                      focusNode: focusNode,
                      autofocus: true,
                      child: const SizedBox(),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
      focusNode.requestFocus();
      await tester.pump();

      await sendShortcut(tester, [
        LogicalKeyboardKey.meta,
        LogicalKeyboardKey.comma,
      ]);
      await tester.pumpAndSettle();

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    testWidgets('PasteFilesIntent should add files from pasteboard', (
      tester,
    ) async {
      const channel = MethodChannel('pasteboard');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            if (methodCall.method == 'getFiles' ||
                methodCall.method == 'files') {
              return ['/test/file1.txt'];
            }
            return null;
          });

      when(() => mockFilesProvider.addFiles(any())).thenAnswer((_) async {});

      late BuildContext actionContext;
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<FilesProvider>.value(
            value: mockFilesProvider,
            child: Shortcuts(
              shortcuts: KeyboardShortcuts.shortcuts,
              child: Builder(
                builder: (context) {
                  return Actions(
                    actions: KeyboardShortcuts.createActions(context),
                    child: Focus(
                      autofocus: true,
                      child: Builder(
                        builder: (innerContext) {
                          actionContext = innerContext;
                          return const SizedBox();
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.runAsync(() async {
        final action = Actions.maybeFind<PasteFilesIntent>(actionContext);
        expect(action, isNotNull);
        Actions.invoke(actionContext, const PasteFilesIntent());

        await Future.delayed(const Duration(milliseconds: 50));
      });

      verify(() => mockFilesProvider.addFiles(any())).called(1);

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });
    group('Accessibility Intents', () {
      test('ClearAllIntent', () {
        expect(const ClearAllIntent(), isA<ClearAllIntent>());
      });
      test('ShareIntent', () {
        expect(const ShareIntent(), isA<ShareIntent>());
      });
      test('PasteFilesIntent', () {
        expect(const PasteFilesIntent(), isA<PasteFilesIntent>());
      });
      test('PreferencesIntent', () {
        expect(const PreferencesIntent(), isA<PreferencesIntent>());
      });
    });
  });
}
