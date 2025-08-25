import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/l10n/app_localizations.dart';

// Simple stub localization implementing only required getters for test
class _StubLoc implements AppLocalizations {
  @override
  String get localeName => 'en';
  const _StubLoc();
  @override
  String get shareNone => 'No files to share';
  @override
  String get shareError => 'Share error';
  // Unused members stubbed with throws to surface unexpected usage
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('resolveShareMessage maps internal keys', () {
    const loc = _StubLoc();
    expect(FilesProvider.resolveShareMessage('shareNone', loc), loc.shareNone);
    expect(
      FilesProvider.resolveShareMessage('shareError', loc),
      loc.shareError,
    );
    expect(FilesProvider.resolveShareMessage('Other text', loc), 'Other text');
  });
}
