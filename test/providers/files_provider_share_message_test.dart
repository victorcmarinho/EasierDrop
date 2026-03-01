import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:easier_drop/helpers/share_message_helper.dart';

class _StubLoc implements AppLocalizations {
  @override
  String get localeName => 'en';
  const _StubLoc();
  @override
  String get shareNone => 'No files to share';
  @override
  String get shareError => 'Share error';

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('resolveShareMessage maps internal keys', () {
    const loc = _StubLoc();
    expect(
      ShareMessageHelper.resolveShareMessage('shareNone', loc),
      loc.shareNone,
    );
    expect(
      ShareMessageHelper.resolveShareMessage('shareError', loc),
      loc.shareError,
    );
    expect(
      ShareMessageHelper.resolveShareMessage('Other text', loc),
      'Other text',
    );
  });
}
