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
        }
    }
    
    
    
    func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        Swift.print("[MainFlutterWindow] Dragging Entered. Pasteboard types: \(sender.draggingPasteboard.types ?? [])")
        let sourceDragMask = sender.draggingSourceOperationMask
        if sourceDragMask.contains(.copy) {
            return .copy
        }
        return []
    }
    
    func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }
    
    func draggingExited(_ sender: NSDraggingInfo?) {
        Swift.print("[MainFlutterWindow] Dragging Exited.")
    }
    
    func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        Swift.print("[MainFlutterWindow] Preparing for drag operation.")
        return true
    }
    
    func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        Swift.print("[MainFlutterWindow] Performing drag operation.")
        
        let pasteboard = sender.draggingPasteboard
        
        
        guard let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL], !urls.isEmpty else {
            Swift.print("[MainFlutterWindow] Could not get file URLs from pasteboard.")
            return false
        }
        
        let filePaths = urls.map { $0.path }
        
        if !filePaths.isEmpty {
            Swift.print("[MainFlutterWindow] Sending \(filePaths.count) file(s) to Flutter.")
            fileDropChannel?.sendDropEvent(filePaths: filePaths)
            return true
        }
        
        Swift.print("[MainFlutterWindow] No valid file paths found.")
        return false
    }
    
    func concludeDragOperation(_ sender: NSDraggingInfo?) {
        Swift.print("[MainFlutterWindow] Concluding drag operation.")
    }
}


extension MainFlutterWindow: NSDraggingSource {
    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        return .copy
    }

    func draggingSession(_ session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
        
        print("[MainFlutterWindow] Dragging session ended.")
    }
}
