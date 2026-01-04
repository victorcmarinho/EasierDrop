import Cocoa
import FlutterMacOS
import QuickLookThumbnailing

class MacOSFileIconChannel: NSObject {
    static let shared = MacOSFileIconChannel()
    private var channels: [FlutterMethodChannel] = []
    
    func setup(binaryMessenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(
            name: "file_icon_channel",
            binaryMessenger: binaryMessenger
        )
        channel.setMethodCallHandler(handleMethodCall)
        channels.append(channel)
    }
    
    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "getFileIcon" {
            getFileIcon(call, result)
        } else if call.method == "getFilePreview" {
            getFilePreview(call, result)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func getFileIcon(_ call: FlutterMethodCall, _ result: FlutterResult) {
        guard let filePath = call.arguments as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS",
                              message: "Argumentos inválidos: o caminho do arquivo é esperado",
                              details: nil))
            return
        }
        
        let icon = NSWorkspace.shared.icon(forFile: filePath)
        
        guard let tiffData = icon.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let pngData = bitmap.representation(using: NSBitmapImageRep.FileType.png, properties: [:]) else {
            result(FlutterError(code: "ICON_CONVERSION_FAILED",
                              message: "Falha ao converter ícone",
                              details: nil))
            return
        }
        
        result(FlutterStandardTypedData(bytes: pngData))
    }

    private func getFilePreview(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
         guard let filePath = call.arguments as? String else {
             result(FlutterError(code: "INVALID_ARGUMENTS",
                               message: "Argumentos inválidos: o caminho do arquivo é esperado",
                               details: nil))
             return
         }

         let fileURL = URL(fileURLWithPath: filePath)
         let size = CGSize(width: 256, height: 256)
         let scale = NSScreen.main?.backingScaleFactor ?? 2.0
         
         let request = QLThumbnailGenerator.Request(
             fileAt: fileURL,
             size: size,
             scale: scale,
             representationTypes: .thumbnail
         )
         
         QLThumbnailGenerator.shared.generateBestRepresentation(for: request) { (thumbnail, error) in
             if error != nil {
                 result(nil)
                 return
             }
             
             guard let thumbnail = thumbnail else {
                 result(nil)
                 return
             }
             
             // Convert NSImage to JPEG data (Performance optimization)
             let image = thumbnail.nsImage
             guard let tiffData = image.tiffRepresentation,
                   let bitmap = NSBitmapImageRep(data: tiffData),
                   let jpegData = bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.8]) else {
                 result(nil)
                 return
             }
             
             result(FlutterStandardTypedData(bytes: jpegData))
         }
    }
}
