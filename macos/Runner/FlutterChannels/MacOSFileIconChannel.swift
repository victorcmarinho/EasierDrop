//
//  MacOSFileIconChannel.swift
//  Runner
//
//  Created by Victor Marinho on 15/03/25.
//
import Cocoa
import FlutterMacOS

class MacOSFileIconChannel {
    private static var channel: FlutterMethodChannel?
    private static let iconCache = NSCache<NSString, NSImage>()
    
    static func setup(for controller: FlutterViewController) {
        channel = FlutterMethodChannel(
            name: "file_icon_channel",
            binaryMessenger: controller.engine.binaryMessenger)
        
        channel?.setMethodCallHandler { call, result in
            switch call.method {
            case "getFileIcon":
                handleGetFileIcon(arguments: call.arguments, result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private static func handleGetFileIcon(arguments: Any?, result: @escaping FlutterResult) {
        guard let path = arguments as? String else {
            result(FlutterError(
                code: "INVALID_ARGS",
                message: "Caminho do arquivo não fornecido",
                details: nil
            ))
            return
        }

        if let iconData = getIconForFile(path: path) {
            result(iconData)
        } else {
            result(FlutterError(
                code: "ICON_ERROR",
                message: "Não foi possível obter o ícone para: \(path)",
                details: nil
            ))
        }
    }

    private static func getIconForFile(path: String) -> FlutterStandardTypedData? {
        let pathKey = path as NSString
        
        // Verifica no cache primeiro
        if let cachedIcon = iconCache.object(forKey: pathKey),
           let tiffData = cachedIcon.tiffRepresentation {
            return FlutterStandardTypedData(bytes: tiffData)
        }
        
        // Se não estiver no cache, carrega o ícone
        let fileURL = URL(fileURLWithPath: path)
        let icon = NSWorkspace.shared.icon(forFile: fileURL.path)
        
        // Armazena no cache
        iconCache.setObject(icon, forKey: pathKey)
        
        return icon.tiffRepresentation.map { FlutterStandardTypedData(bytes: $0) }
    }
}
