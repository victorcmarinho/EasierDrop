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
        }
    }
    
    
    
    func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
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
    }
    
    func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return true
    }
    
    func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let urls = sender.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL], !urls.isEmpty else {
            return false
        }
        
        
        
        let filePaths = urls.map { $0.path }
        
        if !filePaths.isEmpty {
            fileDropChannel?.sendDropEvent(filePaths: filePaths)
            return true
        }
        
        return false
    }
    
    func concludeDragOperation(_ sender: NSDraggingInfo?) {
    }
}


extension MainFlutterWindow: NSDraggingSource {
    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        return .copy
    }

    func draggingSession(_ session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
        
    }
}
