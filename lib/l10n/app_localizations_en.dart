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

  @override
  String get checkForUpdates => 'Check for updates';

  @override
  String get noUpdatesAvailable => 'No updates available';

  @override
  String get checkingForUpdates => 'Checking for updates';

  @override
  String get updateAvailableMessage => 'A new version is available.';

  @override
  String get download => 'Download';

  @override
  String get later => 'Later';

  @override
  String get settingsShakeGesture => 'Shake Gesture';

  @override
  String get settingsShakePermissionActive => 'Active';

  @override
  String get settingsShakePermissionInactive => 'Inactive';

  @override
  String get settingsShakePermissionDescription => 'Shake your mouse cursor to quickly open the drop window.';

  @override
  String get settingsShakePermissionInstruction => 'To enable this feature, allow accessibility permission in System Settings.';

  @override
  String settingsShakeRestartHint(String link) {
    return 'If you have already enabled the permission, click $link to restart the app.';
  }

  @override
  String get settingsShakeRestartLink => 'here';

  @override
  String get webHeroTitle => 'Drag, Drop, Done.';

  @override
  String get webHeroSubtitle => 'The easiest way to collect and move files on your Mac.';

  @override
  String get webDownloadMac => 'Download for macOS';

  @override
  String get webInstallBrew => 'Install via Homebrew';

  @override
  String get webFeaturesTitle => 'Features';

  @override
  String get webChangelogTitle => 'Changelog';

  @override
  String get webFooterText => 'Open Source on GitHub.';

  @override
  String get webFeature1Title => 'Temporary Stash';

  @override
  String get webFeature1Desc => 'Drag files into Easier Drop and they stay there until you need them.';

  @override
  String get webFeature2Title => 'Batch Operations';

  @override
  String get webFeature2Desc => 'Select multiple files from anywhere and drag them out together.';

  @override
  String get webFeature3Title => 'Shake to Open';

  @override
  String get webFeature3Desc => 'Just shake your mouse to quickly reveal the drop window.';
}
