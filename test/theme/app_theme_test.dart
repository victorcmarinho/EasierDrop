import 'package:easier_drop/theme/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macos_ui/macos_ui.dart';

void main() {
  group('AppTheme', () {
    test('cobertura do construtor privado', () {
      AppTheme.testCoverage();
    });

    test('light theme deve ter tipografia configurada', () {
      final theme = AppTheme.light;
      expect(theme.brightness, Brightness.light);
      expect(theme.typography.largeTitle.fontSize, 26);
      expect(theme.typography.largeTitle.fontWeight, FontWeight.bold);
      expect(theme.typography.body.fontSize, 13);
      expect(theme.typography.subheadline.fontSize, 11);
      expect(theme.typography.title1.fontSize, 22);
      expect(theme.typography.title2.fontSize, 17);
      expect(theme.typography.title3.fontSize, 15);
      expect(theme.typography.caption1.fontSize, 10);
      expect(theme.typography.callout.fontSize, 12);
      expect(theme.typography.footnote.fontSize, 10);
    });

    test('dark theme deve ter tipografia configurada', () {
      final theme = AppTheme.dark;
      expect(theme.brightness, Brightness.dark);
      expect(theme.typography.largeTitle.fontSize, 26);
      expect(theme.typography.largeTitle.fontWeight, FontWeight.bold);
      expect(theme.typography.body.fontSize, 13);
      expect(theme.typography.title1.fontSize, 22);
      expect(theme.typography.title2.fontSize, 17);
      expect(theme.typography.title3.fontSize, 15);
    });

    testWidgets('getCupertinoTheme deve retornar tema compatível no modo claro', (tester) async {
      await tester.pumpWidget(
        MacosTheme(
          data: AppTheme.light,
          child: Builder(
            builder: (context) {
              final theme = AppTheme.getCupertinoTheme(context);
              expect(theme.brightness, Brightness.light);
              expect(theme.scaffoldBackgroundColor, AppTheme.light.canvasColor);
              expect(theme.textTheme.textStyle.color, MacosColors.black);
              expect(theme.textTheme.navTitleTextStyle.fontWeight, FontWeight.w600);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('getCupertinoTheme deve retornar tema compatível no modo escuro', (tester) async {
      await tester.pumpWidget(
        MacosTheme(
          data: AppTheme.dark,
          child: Builder(
            builder: (context) {
              final theme = AppTheme.getCupertinoTheme(context);
              expect(theme.brightness, Brightness.dark);
              expect(theme.scaffoldBackgroundColor, AppTheme.dark.canvasColor);
              expect(theme.textTheme.textStyle.color, MacosColors.white);
              expect(theme.textTheme.dateTimePickerTextStyle.fontSize, 13);
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });
}
