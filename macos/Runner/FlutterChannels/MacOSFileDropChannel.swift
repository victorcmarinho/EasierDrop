import Cocoa
import FlutterMacOS

class MacOSFileDropChannel: NSObject {
    static let shared = MacOSFileDropChannel()
    
    private var channel: FlutterMethodChannel?
    private var eventChannel: FlutterEventChannel?
    private var eventSink: FlutterEventSink?
    
    private override init() {
        super.init()
    }
    
    func setup(binaryMessenger: FlutterBinaryMessenger) {
        Swift.print("[MacOSFileDropChannel] Setting up...")
        
        channel = FlutterMethodChannel(name: "file_drop_channel", binaryMessenger: binaryMessenger)
        eventChannel = FlutterEventChannel(name: "file_drop_channel/events", binaryMessenger: binaryMessenger)
        
        channel?.setMethodCallHandler(handleMethodCall)
        eventChannel?.setStreamHandler(self)
        
        Swift.print("[MacOSFileDropChannel] Setup complete.")
    }
    
    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        Swift.print("[MacOSFileDropChannel] Received method call: \(call.method)")
        
        switch call.method {
        case "startDropMonitor", "stopDropMonitor":
            // This is now handled by the window, but we can keep the call for compatibility
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func sendDropEvent(filePaths: [String]) {
        Swift.print("[MacOSFileDropChannel] Sending drop event to Flutter with paths: \(filePaths)")
        guard let sink = eventSink else {
            Swift.print("[MacOSFileDropChannel] Error: EventSink is nil. Cannot send drop event.")
            return
        }
        sink(filePaths)
    }
}

// MARK: - FlutterStreamHandler
extension MacOSFileDropChannel: FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        Swift.print("[MacOSFileDropChannel] Event channel listening.")
        self.eventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        Swift.print("[MacOSFileDropChannel] Event channel cancelled.")
        self.eventSink = nil
        return nil
    }
}
