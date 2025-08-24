import Cocoa
import FlutterMacOS

class MacOSFileIconChannel: NSObject {
    static let shared = MacOSFileIconChannel()
    private var channel: FlutterMethodChannel?
    
    private override init() {
        super.init()
    }
    
    func setup(binaryMessenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(
            name: "file_icon_channel",
            binaryMessenger: binaryMessenger
        )
        channel?.setMethodCallHandler(handleMethodCall)
    }
    
    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "getFileIcon" {
            getFileIcon(call, result)
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
        
        // Obter o ícone do arquivo
        let icon = NSWorkspace.shared.icon(forFile: filePath)
        
        // Converter para PNG
        guard let tiffData = icon.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let pngData = bitmap.representation(using: NSBitmapImageRep.FileType.png, properties: [:]) else {
            result(FlutterError(code: "ICON_CONVERSION_FAILED",
                              message: "Falha ao converter ícone",
                              details: nil))
            return
        }
        
        // Retornar os bytes do PNG
        result(FlutterStandardTypedData(bytes: pngData))
    }
}
