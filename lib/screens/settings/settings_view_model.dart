import 'package:flutter/foundation.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:easier_drop/services/native_events_service.dart';

class SettingsViewModel extends ChangeNotifier {
  bool _hasLaunchAtLoginPermission = false;
  bool _isCheckingPermission = true;
  bool _hasShakePermission = false;
  bool _checkingShake = true;

  bool get hasLaunchAtLoginPermission => _hasLaunchAtLoginPermission;
  bool get isCheckingPermission => _isCheckingPermission;
  bool get hasShakePermission => _hasShakePermission;
  bool get checkingShake => _checkingShake;

  Future<void> checkPermissions() async {
    _isCheckingPermission = true;
    _checkingShake = true;
    notifyListeners();

    final launchPerm = await SettingsService.instance
        .checkLaunchAtLoginPermission();
    final shakePerm = await NativeEventsService.instance.checkShakePermission();

    _hasLaunchAtLoginPermission = launchPerm;
    _isCheckingPermission = false;
    _hasShakePermission = shakePerm;
    _checkingShake = false;
    notifyListeners();
  }
}
