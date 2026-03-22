import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/helpers/share_message_helper.dart';
import 'package:easier_drop/l10n/app_localizations.dart';

class FakeAppLocalizations extends Fake implements AppLocalizations {
  @override
  String get shareNone => 'None';
  @override
  String get shareError => 'Error';
}

void main() {
  group('ShareMessageHelper', () {
    final loc = FakeAppLocalizations();

    test('resolveShareMessage maps keys correctly', () {
      expect(ShareMessageHelper.resolveShareMessage('shareNone', loc), 'None');
      expect(ShareMessageHelper.resolveShareMessage('shareError', loc), 'Error');
      expect(ShareMessageHelper.resolveShareMessage('other', loc), 'other');
    });
  });
}
