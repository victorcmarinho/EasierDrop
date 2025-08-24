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
        case "beginDrag":
            guard let args = call.arguments as? [String: Any],
                  let items = args["items"] as? [String] else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for beginDrag", details: nil))
                return
            }
            beginDrag(items: items, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func beginDrag(items: [String], result: FlutterResult) {
        guard let window = NSApplication.shared.mainWindow, let source = window as? NSDraggingSource else {
            result(FlutterError(code: "NO_WINDOW", message: "Main window not found or does not conform to NSDraggingSource", details: nil))
            return
        }

        let pasteboardItems = items.map { path -> NSPasteboardItem in
            let item = NSPasteboardItem()
            let url = URL(fileURLWithPath: path)
            item.setString(url.path, forType: .fileURL)
            return item
        }

        let draggingItems = items.enumerated().map { (index, path) -> NSDraggingItem in
            let url = URL(fileURLWithPath: path)
            let icon = NSWorkspace.shared.icon(forFile: url.path)
            
            let draggingItem = NSDraggingItem(pasteboardWriter: pasteboardItems[index])
            
            // Create a temporary view to get the drag image
            let imageView = NSImageView(image: icon)
            imageView.frame = NSRect(x: 0, y: 0, width: 64, height: 64)
            
            draggingItem.setDraggingFrame(imageView.bounds, contents: imageView.image)
            return draggingItem
        }

        if let event = NSApp.currentEvent {
            let session = window.beginDraggingSession(items: draggingItems, event: event, source: source)
            session.animatesToStartingPositionsOnCancelOrFailure = true
            result(nil) // Indicate success
        } else {
             result(FlutterError(code: "NO_EVENT", message: "No current event to start dragging session", details: nil))
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
