import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  override func applicationDidFinishLaunching(_ aNotification: Notification) {
    let controller = self.mainFlutterWindow!.contentViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "file_icon_helper", binaryMessenger: controller.engine.binaryMessenger)

    channel.setMethodCallHandler { (call, result) in
        if call.method == "getFileIcon", let args = call.arguments as? String {
            if let iconData = self.getIconForFile(path: args) {
              result(iconData)
            } else {
              result(FlutterError(code: "ICON_ERROR", message: "Não foi possível obter o ícone", details: nil))
            }
        } else {
          result(FlutterMethodNotImplemented)
        }
    }
  }

  func getIconForFile(path: String) -> FlutterStandardTypedData? {
    let fileURL = URL(fileURLWithPath: path)
    let icon = NSWorkspace.shared.icon(forFile: fileURL.path)

    guard let tiffData = icon.tiffRepresentation else { return nil }
    return FlutterStandardTypedData(bytes: tiffData)
  }

}
