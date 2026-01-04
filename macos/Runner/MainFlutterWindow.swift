import Cocoa
import FlutterMacOS
import desktop_multi_window
import ServiceManagement

class MainFlutterWindow: NSWindow, NSDraggingDestination {
    
    private var fileDropChannel: MacOSFileDropChannel?

    override func awakeFromNib() {
        let flutterViewController = FlutterViewController.init()
        let windowFrame = self.frame
        self.contentViewController = flutterViewController
        self.setFrame(windowFrame, display: true)
        
        if #available(macOS 10.13, *) {
            center()
        }
        
        registerForDraggedTypes([.fileURL])
        
        self.fileDropChannel = MacOSFileDropChannel.shared
        
        FlutterMethodChannel(
            name: "launch_at_startup",
            binaryMessenger: flutterViewController.engine.binaryMessenger
        ).setMethodCallHandler { (_ call: FlutterMethodCall, result: @escaping FlutterResult) in
            switch call.method {
            case "launchAtStartupIsEnabled":
                if #available(macOS 13.0, *) {
                    let service = SMAppService.mainApp
                    result(service.status == .enabled)
                } else {
                    // For macOS < 13, we can't reliably check the status
                    result(false)
                }
            case "launchAtStartupSetEnabled":
                if let arguments = call.arguments as? [String: Any],
                   let setEnabled = arguments["setEnabledValue"] as? Bool {
                    if #available(macOS 13.0, *) {
                        let service = SMAppService.mainApp
                        do {
                            if setEnabled {
                                try service.register()
                            } else {
                                try service.unregister()
                            }
                            result(nil)
                        } catch {
                            result(FlutterError(code: "LAUNCH_AT_STARTUP_ERROR",
                                              message: "Failed to \(setEnabled ? "enable" : "disable") launch at startup: \(error.localizedDescription)",
                                              details: nil))
                        }
                    } else {
                        result(FlutterError(code: "UNSUPPORTED_OS",
                                          message: "Launch at startup requires macOS 13.0 or later",
                                          details: nil))
                    }
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENTS",
                                      message: "Invalid arguments for setEnabled",
                                      details: nil))
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        RegisterGeneratedPlugins(registry: flutterViewController)
        
        FlutterMultiWindowPlugin.setOnWindowCreatedCallback { controller in
            RegisterGeneratedPlugins(registry: controller)
            
            if let appDelegate = NSApp.delegate as? AppDelegate {
                appDelegate.setupCustomChannels(messenger: controller.engine.binaryMessenger, view: controller.view)
            }
            
            let dropOverlay = FileDropHandlerView(frame: controller.view.bounds)
            dropOverlay.messenger = controller.engine.binaryMessenger
            dropOverlay.autoresizingMask = [.width, .height]
            controller.view.addSubview(dropOverlay)
            dropOverlay.registerForDraggedTypes([.fileURL])
        }
    }
    
    func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }
    
    func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }
    
    func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let urls = sender.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL], !urls.isEmpty else {
            return false
        }
        
        let filePaths = urls.map { $0.path }
        
        if let controller = self.contentViewController as? FlutterViewController {
            MacOSFileDropChannel.shared.sendDropEvent(messenger: controller.engine.binaryMessenger, filePaths: filePaths)
            return true
        }
        
        return false
    }
}

// MARK: - Overlay View for Multi-Windows
class FileDropHandlerView: NSView {
    var messenger: FlutterBinaryMessenger?
    
    override func hitTest(_ point: NSPoint) -> NSView? {
        // Return nil to allow mouse events to pass through to Flutter
        return nil
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let urls = sender.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL], !urls.isEmpty, let messenger = messenger else {
            return false
        }
        
        let filePaths = urls.map { $0.path }
        MacOSFileDropChannel.shared.sendDropEvent(messenger: messenger, filePaths: filePaths)
        return true
    }
}

extension MainFlutterWindow: NSDraggingSource {
    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        return .copy
    }

    func draggingSession(_ session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
    }
}
