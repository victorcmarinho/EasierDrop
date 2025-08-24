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

    override func applicationDidFinishLaunching(_ notification: Notification) {
        guard let controller = mainFlutterWindow?.contentViewController as? FlutterViewController else {
            fatalError("FlutterViewController not found")
        }
        
    // Setup communication channels
    let messenger = controller.engine.binaryMessenger
    MacOSFileIconChannel.shared.setup(binaryMessenger: messenger)
    MacOSFileDropChannel.shared.setup(binaryMessenger: messenger)
    MacOSDragOutChannel.shared.setup(view: controller.view, messenger: messenger)
        
        super.applicationDidFinishLaunching(notification)
    }
}
