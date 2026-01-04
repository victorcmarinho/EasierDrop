import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/l10n/app_localizations.dart';

void main() {
  group('AppLocalizationsDelegate', () {
    test('isSupported returns true for supported locales', () {
      const delegate = AppLocalizations.delegate;
      expect(delegate.isSupported(const Locale('en')), isTrue);
      expect(delegate.isSupported(const Locale('es')), isTrue);
      expect(delegate.isSupported(const Locale('pt')), isTrue);
    });

    test('isSupported returns false for unsupported locales', () {
      const delegate = AppLocalizations.delegate;
      expect(delegate.isSupported(const Locale('fr')), isFalse);
    });

    test('shouldReload returns false', () {
      const delegate = AppLocalizations.delegate;
      expect(delegate.shouldReload(delegate), isFalse);
    });

    test('load returns correct localizations', () async {
      const delegate = AppLocalizations.delegate;

      final en = await delegate.load(const Locale('en'));
      expect(en.localeName, 'en');

      final es = await delegate.load(const Locale('es'));
      expect(es.localeName, 'es');

      final pt = await delegate.load(const Locale('pt'));
      expect(pt.localeName, 'pt');
    });

    test('lookupAppLocalizations returns correct instance', () {
      expect(lookupAppLocalizations(const Locale('en')).localeName, 'en');
      expect(lookupAppLocalizations(const Locale('es')).localeName, 'es');
      expect(lookupAppLocalizations(const Locale('pt')).localeName, 'pt');
    });

    test('lookupAppLocalizations throws on unsupported locale', () {
      expect(
        () => lookupAppLocalizations(const Locale('fr')),
        throwsA(isA<FlutterError>()),
      );
    });
  });
}
