import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  String get appTitle;

  String get dropHere;

  String get clearFilesTitle;

  String get clearFilesMessage;

  String get clearCancel;

  String get clearConfirm;

  String get share;

  String get removeAll;

  String get close;

  String get tooltipShare;

  String get tooltipClear;

  String get semAreaLabel;

  String get semAreaHintEmpty;

  String semAreaHintHas(int count);

  String get semShareHintNone;

  String semShareHintSome(int count);

  String get semRemoveHintNone;

  String semRemoveHintSome(int count);

  String get trayFilesNone;

  String trayFilesCount(int count);

  String get trayExit;

  String get openTray;

  String get filesCountTooltip;

  String get languageLabel;

  String get languageEnglish;

  String get languagePortuguese;

  String get languageSpanish;

  String limitReached(int max);

  String get shareNone;

  String get shareError;

  String fileLabelSingle(String name);

  String fileLabelMultiple(int count);

  String get genericFileName;

  String get semHandleLabel;

  String get semHandleHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
