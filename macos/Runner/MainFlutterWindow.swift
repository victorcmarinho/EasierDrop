import Cocoa
import FlutterMacOS
import desktop_multi_window

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
        
        RegisterGeneratedPlugins(registry: flutterViewController)
        
        FlutterMultiWindowPlugin.setOnWindowCreatedCallback { controller in
            RegisterGeneratedPlugins(registry: controller)
            
            if let appDelegate = NSApp.delegate as? AppDelegate {
                appDelegate.setupCustomChannels(messenger: controller.engine.binaryMessenger, view: controller.view)
            }
            
            // Allow secondary windows to receive file drops using an overlay view
            let dropOverlay = FileDropHandlerView(frame: controller.view.bounds)
            dropOverlay.messenger = controller.engine.binaryMessenger
            dropOverlay.autoresizingMask = [.width, .height]
            controller.view.addSubview(dropOverlay)
            dropOverlay.registerForDraggedTypes([.fileURL])
        }
    }
    
    // MARK: - NSDraggingDestination for Main Window
    
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
