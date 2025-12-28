import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Easier Drop'**
  String get appTitle;

  /// No description provided for @dropHere.
  ///
  /// In en, this message translates to:
  /// **'Drop files here'**
  String get dropHere;

  /// No description provided for @clearFilesTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear files?'**
  String get clearFilesTitle;

  /// No description provided for @clearFilesMessage.
  ///
  /// In en, this message translates to:
  /// **'This will remove all collected files.'**
  String get clearFilesMessage;

  /// No description provided for @clearCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get clearCancel;

  /// No description provided for @clearConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearConfirm;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @removeAll.
  ///
  /// In en, this message translates to:
  /// **'Remove files'**
  String get removeAll;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @tooltipShare.
  ///
  /// In en, this message translates to:
  /// **'Share (Cmd+Shift+C)'**
  String get tooltipShare;

  /// No description provided for @tooltipClear.
  ///
  /// In en, this message translates to:
  /// **'Clear (Cmd+Backspace)'**
  String get tooltipClear;

  /// No description provided for @semAreaLabel.
  ///
  /// In en, this message translates to:
  /// **'File collection area'**
  String get semAreaLabel;

  /// No description provided for @semAreaHintEmpty.
  ///
  /// In en, this message translates to:
  /// **'Empty. Drag files here.'**
  String get semAreaHintEmpty;

  /// No description provided for @semAreaHintHas.
  ///
  /// In en, this message translates to:
  /// **'Contains {count, plural, one{{count} file} other{{count} files}}. Drag out to move or share.'**
  String semAreaHintHas(int count);

  /// No description provided for @semShareHintNone.
  ///
  /// In en, this message translates to:
  /// **'No files to share'**
  String get semShareHintNone;

  /// No description provided for @semShareHintSome.
  ///
  /// In en, this message translates to:
  /// **'Share {count, plural, one{{count} file} other{{count} files}}'**
  String semShareHintSome(int count);

  /// No description provided for @semRemoveHintNone.
  ///
  /// In en, this message translates to:
  /// **'No files to remove'**
  String get semRemoveHintNone;

  /// No description provided for @semRemoveHintSome.
  ///
  /// In en, this message translates to:
  /// **'Remove {count, plural, one{{count} file} other{{count} files}}'**
  String semRemoveHintSome(int count);

  /// No description provided for @trayFilesNone.
  ///
  /// In en, this message translates to:
  /// **'📂 No files'**
  String get trayFilesNone;

  /// No description provided for @trayFilesCount.
  ///
  /// In en, this message translates to:
  /// **'📁 Files: {count}'**
  String trayFilesCount(int count);

  /// No description provided for @trayExit.
  ///
  /// In en, this message translates to:
  /// **'Quit application'**
  String get trayExit;

  /// No description provided for @openTray.
  ///
  /// In en, this message translates to:
  /// **'Open tray'**
  String get openTray;

  /// No description provided for @filesCountTooltip.
  ///
  /// In en, this message translates to:
  /// **'Current number of files'**
  String get filesCountTooltip;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language:'**
  String get languageLabel;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languagePortuguese.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get languagePortuguese;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @limitReached.
  ///
  /// In en, this message translates to:
  /// **'File limit ({max}) reached'**
  String limitReached(int max);

  /// No description provided for @shareNone.
  ///
  /// In en, this message translates to:
  /// **'No files to share'**
  String get shareNone;

  /// No description provided for @shareError.
  ///
  /// In en, this message translates to:
  /// **'Error sharing files'**
  String get shareError;

  /// No description provided for @fileLabelSingle.
  ///
  /// In en, this message translates to:
  /// **'{name}'**
  String fileLabelSingle(String name);

  /// No description provided for @fileLabelMultiple.
  ///
  /// In en, this message translates to:
  /// **'{count} files'**
  String fileLabelMultiple(int count);

  /// No description provided for @genericFileName.
  ///
  /// In en, this message translates to:
  /// **'file'**
  String get genericFileName;

  /// No description provided for @semHandleLabel.
  ///
  /// In en, this message translates to:
  /// **'Window handle'**
  String get semHandleLabel;

  /// No description provided for @semHandleHint.
  ///
  /// In en, this message translates to:
  /// **'Drag to move the window'**
  String get semHandleHint;

  /// No description provided for @welcomeTo.
  ///
  /// In en, this message translates to:
  /// **'Hello, welcome to'**
  String get welcomeTo;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get updateAvailable;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'pt': return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
