import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    override func applicationDidFinishLaunching(_ notification: Notification) {
        guard let controller = mainFlutterWindow?.contentViewController as? FlutterViewController else {
            fatalError("FlutterViewController not found")
        }
        
        setupCustomChannels(messenger: controller.engine.binaryMessenger, view: controller.view)
        
        super.applicationDidFinishLaunching(notification)
    }

    func setupCustomChannels(messenger: FlutterBinaryMessenger, view: NSView) {
        MacOSFileIconChannel.shared.setup(binaryMessenger: messenger)
        MacOSFileDropChannel.shared.setup(binaryMessenger: messenger)
        MacOSDragOutChannel.shared.setup(view: view, messenger: messenger)
        MacOSShakeMonitor.shared.setup(binaryMessenger: messenger)
        MacOSLaunchAtLoginChannel.shared.setup(binaryMessenger: messenger)
    }
}
