import Cocoa
import FlutterMacOS

class MacOSFileDropChannel: NSObject {
    static let shared = MacOSFileDropChannel()
    
    private var handlers: [ObjectIdentifier: IndividualFileDropHandler] = [:]
    
    private override init() {
        super.init()
    }
    
    func setup(binaryMessenger: FlutterBinaryMessenger) {
        let key = ObjectIdentifier(binaryMessenger as AnyObject)
        if handlers[key] == nil {
            handlers[key] = IndividualFileDropHandler(messenger: binaryMessenger)
        }
    }

    func sendDropEvent(messenger: FlutterBinaryMessenger, filePaths: [String]) {
        let key = ObjectIdentifier(messenger as AnyObject)
        handlers[key]?.sendDropEvent(filePaths: filePaths)
    }
}

class IndividualFileDropHandler: NSObject, FlutterStreamHandler {
    private let messenger: FlutterBinaryMessenger
    private var eventSink: FlutterEventSink?
    private var methodChannel: FlutterMethodChannel?
    private var eventChannel: FlutterEventChannel?
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
        
        methodChannel = FlutterMethodChannel(name: "file_drop_channel", binaryMessenger: messenger)
        eventChannel = FlutterEventChannel(name: "file_drop_channel/events", binaryMessenger: messenger)
        
        methodChannel?.setMethodCallHandler(handleMethodCall)
        eventChannel?.setStreamHandler(self)
    }
    
    func sendDropEvent(filePaths: [String]) {
        eventSink?(filePaths)
    }
    
    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startDropMonitor", "stopDropMonitor":
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}
