// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Easier Drop';

  @override
  String get dropHere => 'Drop files here';

  @override
  String get clearFilesTitle => 'Clear files?';

  @override
  String get clearFilesMessage => 'This will remove all collected files.';

  @override
  String get clearCancel => 'Cancel';

  @override
  String get clearConfirm => 'Clear';

  @override
  String get share => 'Share';

  @override
  String get removeAll => 'Remove files';

  @override
  String get close => 'Close';

  @override
  String get tooltipShare => 'Share (Cmd+Shift+C)';

  @override
  String get tooltipClear => 'Clear (Cmd+Backspace)';

  @override
  String get semAreaLabel => 'File collection area';

  @override
  String get semAreaHintEmpty => 'Empty. Drag files here.';

  @override
  String semAreaHintHas(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files',
      one: '$count file',
    );
    return 'Contains $_temp0. Drag out to move or share.';
  }

  @override
  String get semShareHintNone => 'No files to share';

  @override
  String semShareHintSome(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files',
      one: '$count file',
    );
    return 'Share $_temp0';
  }

  @override
  String get semRemoveHintNone => 'No files to remove';

  @override
  String semRemoveHintSome(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files',
      one: '$count file',
    );
    return 'Remove $_temp0';
  }

  @override
  String get trayExit => 'Quit application';

  @override
  String get openTray => 'Open tray';

  @override
  String get languageLabel => 'Language:';

  @override
  String get languageEnglish => 'English';

  @override
  String get languagePortuguese => 'Portuguese';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String limitReached(int max) {
    return 'File limit ($max) reached';
  }

  @override
  String get shareNone => 'No files to share';

  @override
  String get shareError => 'Error sharing files';

  @override
  String fileLabelSingle(String name) {
    return '$name';
  }

  @override
  String fileLabelMultiple(int count) {
    return '$count files';
  }

  @override
  String get genericFileName => 'file';

  @override
  String get semHandleLabel => 'Window handle';

  @override
  String get semHandleHint => 'Drag to move the window';

  @override
  String get welcomeTo => 'Hello, welcome to';

  @override
  String get updateAvailable => 'Update Available';

  @override
  String get preferences => 'Preferences';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsLaunchAtLogin => 'Launch at Login';

  @override
  String get settingsAlwaysOnTop => 'Always on Top';

  @override
  String get settingsOpacity => 'Window Opacity';
}
