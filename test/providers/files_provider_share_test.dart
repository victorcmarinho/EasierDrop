import 'dart:io';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:easier_drop/helpers/share_message_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';

void main() {
  testWidgets('shareNone and shareError messages resolved', (tester) async {
    final provider = FilesProvider(enableMonitoring: false);
    AppLocalizations? loc;
    await tester.pumpWidget(
      MacosApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (c) {
            loc = AppLocalizations.of(c);
            return const SizedBox();
          },
        ),
      ),
    );
    await tester.pump();

    final noneResult = await provider.shared();
    expect(noneResult, isA());
    final msgNone = ShareMessageHelper.resolveShareMessage('shareNone', loc!);
    expect(msgNone, loc!.shareNone);

    final msgErr = ShareMessageHelper.resolveShareMessage('shareError', loc!);
    expect(msgErr, loc!.shareError);
  });

  test('rescan removes invalid files', () async {
    final provider = FilesProvider(enableMonitoring: false);

    final temp = await File(
      '${Directory.systemTemp.path}/ed_test_${DateTime.now().millisecondsSinceEpoch}',
    ).create();
    final path = temp.path;
    final ref = FileReference(pathname: path);
    provider.addFileForTest(ref);
    expect(provider.files.length, 1);
    await temp.delete();
    provider.rescanNow();

    await Future.delayed(const Duration(milliseconds: 10));
    expect(provider.files.length, 0);
  });
}
