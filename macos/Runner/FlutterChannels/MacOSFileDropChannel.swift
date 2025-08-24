//
//  MacOSFileDropChannel.swift
//  Runner
//
//  Created by Victor Marinho on 15/03/25.
//

import Cocoa
import FlutterMacOS

/// Canal de comunicação para operações de drag and drop no macOS
class MacOSFileDropChannel {
    /// Canal de método Flutter para comunicação
    private static var channel: FlutterMethodChannel?
    
    /// Armazena os caminhos de arquivos dropados
    private static var droppedPaths: [String] = []
    
    /// Configura o canal de comunicação com o Flutter
    static func setup(for controller: FlutterViewController) {
        channel = FlutterMethodChannel(
            name: "file_drop_channel",
            binaryMessenger: controller.engine.binaryMessenger)

        channel?.setMethodCallHandler { call, result in
            switch call.method {
            case "getDroppedPath":
                handleGetDroppedPath(result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    /// Manipula um arquivo que foi solto na aplicação
    static func handleDroppedFile(_ url: URL) {
        let path = url.path
        print("url: \(url)")

        if !droppedPaths.contains(path) {
            droppedPaths.append(path)
            
            // Notifica o Flutter que um novo arquivo foi solto
            DispatchQueue.main.async {
                channel?.invokeMethod("onFileDrop", arguments: path)
            }
        }
    }

    /// Manipula a requisição para obter o último caminho de arquivo
    private static func handleGetDroppedPath(result: @escaping FlutterResult) {
        if let path = droppedPaths.first {
            result(path)
            droppedPaths.removeFirst() // Remove o path após enviá-lo
        } else {
            result(FlutterError(
                code: "PATH_ERROR",
                message: "Nenhum arquivo foi solto ainda",
                details: nil
            ))
        }
    }
}
