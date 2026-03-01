import 'package:easier_drop/l10n/app_localizations.dart';

class ShareMessageHelper {
  static String resolveShareMessage(String rawMessage, AppLocalizations loc) {
    switch (rawMessage) {
      case 'shareNone':
        return loc.shareNone;
      case 'shareError':
        return loc.shareError;
      default:
        return rawMessage;
    }
  }
}
