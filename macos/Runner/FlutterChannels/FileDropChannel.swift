//
//  DragDrop.swift
//  Runner
//
//  Created by Victor Marinho on 15/03/25.
//

import Cocoa
import FlutterMacOS

class FileDropChannel {
    private static var channel: FlutterMethodChannel?
    private static var lastDroppedPath: String?

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

    static func handleDroppedFile(_ url: URL) {
        lastDroppedPath = url.path
    }

    private static func handleGetDroppedPath(result: @escaping FlutterResult) {
        if let path = lastDroppedPath {
            result(path)
            // Limpa o caminho após retornar
            lastDroppedPath = nil
        } else {
            result(FlutterError(
                code: "PATH_ERROR",
                message: "Nenhum arquivo foi solto recentemente",
                details: nil
            ))
        }
    }
}
