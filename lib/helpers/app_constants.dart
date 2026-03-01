import 'package:flutter/widgets.dart';
import 'package:easier_drop/config/env_config.dart';

class AppConstants {
  const AppConstants._();
  @visibleForTesting
  static void testCoverage() => const AppConstants._();

  static const double windowHandleHeight = 28.0;
  static const double actionButtonSize = 40.0;
  static const double borderRadius = 8.0;
  static const double borderWidth = 4.0;

  static const Duration fastAnimation = Duration(milliseconds: 160);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const double shareOriginSize = 40.0;
  static const Duration slowAnimation = Duration(milliseconds: 500);

  static const int stackMaxVisible = 6;
  static const double stackRotationBase = 3.0;
  static const double stackSpreadBase = 14.0;
  static const double stackSizeMultiplier = 0.78;

  static const int defaultMaxFiles = 100;
  static const Duration fileValidationTimeout = Duration(seconds: 5);

  static const Duration limitNotificationDuration = Duration(seconds: 2);
  static const Duration debounceDelay = Duration(milliseconds: 250);
  static const Duration monitorInterval = Duration(seconds: 5);

  static const Duration welcomeAnimationDuration = Duration(milliseconds: 1500);
  static const Duration welcomeNavigationDelay = Duration(seconds: 3);

  static String get githubLatestReleaseUrl => Env.githubLatestReleaseUrl;

  static const double defaultWindowSize = 250.0;
  static const int maxWindows = 3;

  static const String shakeChannelName = 'com.easier_drop/shake';

  static const String routeHome = '/';
  static const String routeSettings = '/settings';
  static const String routeShare = '/share';
  static const String routeUpdate = '/update';
}

class SemanticKeys {
  const SemanticKeys._();
  @visibleForTesting
  static void testCoverage() => const SemanticKeys._();

  static const Key shareButton = ValueKey('shareSem');
  static const Key removeButton = ValueKey('removeSem');
  static const Key dropArea = ValueKey('dropAreaSem');
}

class AppOpacity {
  const AppOpacity._();
  @visibleForTesting
  static void testCoverage() => const AppOpacity._();

  static const double subtle = 0.03;
  static const double border = 0.7;
  static const double disabled = 0.5;
  static const double overlay = 0.8;
}
