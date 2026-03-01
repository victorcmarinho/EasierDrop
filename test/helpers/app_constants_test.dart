import 'package:easier_drop/helpers/app_constants.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConstants Tests', () {
    test('UI configuration constants have expected values', () {
      expect(AppConstants.windowHandleHeight, equals(28.0));
      expect(AppConstants.actionButtonSize, equals(40.0));
      expect(AppConstants.borderRadius, equals(8.0));
      expect(AppConstants.borderWidth, equals(4.0));
    });

    test('animation durations are properly defined', () {
      expect(
        AppConstants.fastAnimation,
        equals(const Duration(milliseconds: 160)),
      );
      expect(
        AppConstants.mediumAnimation,
        equals(const Duration(milliseconds: 300)),
      );
      expect(
        AppConstants.slowAnimation,
        equals(const Duration(milliseconds: 500)),
      );
      expect(AppConstants.shareOriginSize, equals(40.0));
    });

    test('stack configuration constants are defined', () {
      expect(AppConstants.stackMaxVisible, equals(6));
      expect(AppConstants.stackRotationBase, equals(3.0));
      expect(AppConstants.stackSpreadBase, equals(14.0));
      expect(AppConstants.stackSizeMultiplier, equals(0.78));
    });

    test('file configuration constants are defined', () {
      expect(AppConstants.defaultMaxFiles, equals(100));
      expect(
        AppConstants.fileValidationTimeout,
        equals(const Duration(seconds: 5)),
      );
    });

    test('notification configuration constants are defined', () {
      expect(
        AppConstants.limitNotificationDuration,
        equals(const Duration(seconds: 2)),
      );
      expect(
        AppConstants.debounceDelay,
        equals(const Duration(milliseconds: 250)),
      );
      expect(AppConstants.monitorInterval, equals(const Duration(seconds: 5)));
    });

    test('welcome screen constants are defined', () {
      expect(
        AppConstants.welcomeAnimationDuration,
        equals(const Duration(milliseconds: 1500)),
      );
      expect(
        AppConstants.welcomeNavigationDelay,
        equals(const Duration(seconds: 3)),
      );
    });

    test('githubLatestReleaseUrl returns correct URL', () {
      expect(
        AppConstants.githubLatestReleaseUrl,
        equals(
          'https://api.github.com/repos/victorcmarinho/EasierDrop/releases/latest',
        ),
      );
    });

    test('system dimensions are defined', () {
      expect(AppConstants.defaultWindowSize, equals(250.0));
    });

    test('platform channel names are defined', () {
      expect(AppConstants.shakeChannelName, equals('com.easier_drop/shake'));
    });

    test('routes are properly defined', () {
      expect(AppConstants.routeHome, equals('/'));
      expect(AppConstants.routeSettings, equals('/settings'));
      expect(AppConstants.routeShare, equals('/share'));
    });
  });

  group('SemanticKeys Tests', () {
    test('semantic keys are properly defined', () {
      expect(SemanticKeys.shareButton, equals(const ValueKey('shareSem')));
      expect(SemanticKeys.removeButton, equals(const ValueKey('removeSem')));
      expect(SemanticKeys.dropArea, equals(const ValueKey('dropAreaSem')));
    });

    test('semantic keys are unique', () {
      final keys = [
        SemanticKeys.shareButton,
        SemanticKeys.removeButton,
        SemanticKeys.dropArea,
      ];

      final uniqueKeys = keys.toSet();
      expect(uniqueKeys.length, equals(keys.length));
    });
  });

  group('AppOpacity Tests', () {
    test('opacity values are within valid range', () {
      expect(AppOpacity.subtle, greaterThanOrEqualTo(0.0));
      expect(AppOpacity.subtle, lessThanOrEqualTo(1.0));

      expect(AppOpacity.border, greaterThanOrEqualTo(0.0));
      expect(AppOpacity.border, lessThanOrEqualTo(1.0));

      expect(AppOpacity.disabled, greaterThanOrEqualTo(0.0));
      expect(AppOpacity.disabled, lessThanOrEqualTo(1.0));

      expect(AppOpacity.overlay, greaterThanOrEqualTo(0.0));
      expect(AppOpacity.overlay, lessThanOrEqualTo(1.0));
    });

    test('opacity constants have expected values', () {
      expect(AppOpacity.subtle, equals(0.03));
      expect(AppOpacity.border, equals(0.7));
      expect(AppOpacity.disabled, equals(0.5));
      expect(AppOpacity.overlay, equals(0.8));
    });

    test('opacity values are ordered logically', () {
      expect(AppOpacity.subtle, lessThan(AppOpacity.disabled));
      expect(AppOpacity.subtle, lessThan(AppOpacity.border));
      expect(AppOpacity.subtle, lessThan(AppOpacity.overlay));

      expect(AppOpacity.disabled, lessThan(AppOpacity.overlay));
    });
  });
}
