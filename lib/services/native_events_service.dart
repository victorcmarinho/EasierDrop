import 'dart:io' as io;
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easier_drop/services/analytics_service.dart';
import 'package:easier_drop/helpers/app_constants.dart';
import 'package:easier_drop/services/window_manager_service.dart';

class NativeEventsService {
  static final NativeEventsService _instance = NativeEventsService._();
  NativeEventsService._();

  static NativeEventsService get instance => _instance;

  static const MethodChannel _shakeChannel = MethodChannel(
    AppConstants.shakeChannelName,
  );

  void initialize() {
    _shakeChannel.setMethodCallHandler(_handleShakeEvent);
  }

  Future<void> _handleShakeEvent(MethodCall call) async {
    if (call.method == 'shake_detected') {
      AnalyticsService.instance.debug(
        'Shake event received via channel',
        tag: 'NativeEventsService',
      );
      final args = call.arguments as Map;
      final x = (args['x'] as num).toDouble();
      final y = (args['y'] as num).toDouble();
      AnalyticsService.instance.shakeDetected(x, y);

      await WindowManagerService.instance.createNewWindow(x, y);
    }
  }

  Future<bool> checkShakePermission() async {
    try {
      final bool? result = await _shakeChannel.invokeMethod<bool>(
        'checkPermission',
      );
      return result ?? false;
    } catch (e) {
      AnalyticsService.instance.warn('Failed to check shake permission: $e');
      return false;
    }
  }

  Future<void> openAccessibilitySettings() async {
    final Uri url = Uri.parse(
      'x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      final Uri fallbackUrl = Uri.parse(
        'x-apple.systempreferences:com.apple.preference.security',
      );
      if (await canLaunchUrl(fallbackUrl)) {
        await launchUrl(fallbackUrl);
      }
    }
  }

  Future<void> restartApp() async {
    if (io.Platform.isMacOS) {
      final String executable = io.Platform.resolvedExecutable;
      final String appBundlePath = io.File(
        executable,
      ).parent.parent.parent.path;

      await io.Process.start('open', ['-n', appBundlePath]);
      await WindowManagerService.instance.exitApp();
    }
  }
}
