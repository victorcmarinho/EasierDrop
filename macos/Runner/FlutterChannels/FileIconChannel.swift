//
//  DragDrop.swift
//  Runner
//
//  Created by Victor Marinho on 15/03/25.
//
import Cocoa
import FlutterMacOS

class FileIconChannel {
    static func setup(for controller: FlutterViewController) {
        let channel = FlutterMethodChannel(
            name: "file_icon_channel", binaryMessenger: controller.engine.binaryMessenger)
        channel.setMethodCallHandler { call, result in
            guard call.method == "getFileIcon", let path = call.arguments as? String else {
                result(FlutterMethodNotImplemented)
                return
            }

            if let iconData = getIconForFile(path: path) {
                result(iconData)
            } else {
                result(
                    FlutterError(
                        code: "ICON_ERROR", message: "Não foi possível obter o ícone", details: nil)
                )
            }
        }
    }

    private static func getIconForFile(path: String) -> FlutterStandardTypedData? {
        let fileURL = URL(fileURLWithPath: path)
        let icon = NSWorkspace.shared.icon(forFile: fileURL.path)
        return icon.tiffRepresentation.map { FlutterStandardTypedData(bytes: $0) }
    }
}
