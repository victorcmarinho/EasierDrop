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
        
        channel = FlutterMethodChannel(name: "file_drop_channel", binaryMessenger: binaryMessenger)
        eventChannel = FlutterEventChannel(name: "file_drop_channel/events", binaryMessenger: binaryMessenger)
        
        channel?.setMethodCallHandler(handleMethodCall)
        eventChannel?.setStreamHandler(self)
        
    }
    
    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        switch call.method {
        case "startDropMonitor", "stopDropMonitor":
            
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func sendDropEvent(filePaths: [String]) {
        guard let sink = eventSink else {
            return
        }
        sink(filePaths)
    }
}


extension MacOSFileDropChannel: FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}
