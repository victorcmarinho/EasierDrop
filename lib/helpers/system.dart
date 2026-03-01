import 'package:easier_drop/services/window_manager_service.dart';
import 'package:easier_drop/services/native_events_service.dart';

class SystemHelper {
  static Future<void> initialize({
    bool isSecondaryWindow = false,
    String? windowId,
  }) async {
    NativeEventsService.instance.initialize();
    await WindowManagerService.instance.initialize(
      isSecondaryWindow: isSecondaryWindow,
      windowId: windowId,
    );
  }
}
