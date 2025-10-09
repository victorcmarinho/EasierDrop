import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/l10n/app_localizations.dart';

class FilesSemanticsHelper {
  const FilesSemanticsHelper._();

  static String generateHint(List<FileReference> files, AppLocalizations loc) {
    return files.isEmpty
        ? loc.semAreaHintEmpty
        : loc.semAreaHintHas(files.length);
  }

  static String generateFileLabel(
    List<FileReference> files,
    AppLocalizations loc,
  ) {
    if (files.isEmpty) return '';

    if (files.length == 1) {
      final name = files.first.fileName;
      return loc.fileLabelSingle(name);
    }

    return loc.fileLabelMultiple(files.length);
  }
}

class FilesSurfaceStyles {
  const FilesSurfaceStyles._();

  static const Duration animationDuration = Duration(milliseconds: 160);
  static const Duration opacityDuration = Duration(milliseconds: 300);
  static const double borderWidth = 4.0;
  static const double borderRadius = 8.0;
  static const double contentHeightFactor = 0.6;
  static const double badgeTopPadding = 6.0;
}
