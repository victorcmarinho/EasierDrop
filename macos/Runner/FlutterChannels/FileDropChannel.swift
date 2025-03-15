//
//  DragDrop.swift
//  Runner
//
//  Created by Victor Marinho on 15/03/25.
//

import Cocoa
import FlutterMacOS

class FileDropChannel {

    static func setup(for controller: FlutterViewController) {
        let channel = FlutterMethodChannel(
            name: "file_drop_channel", binaryMessenger: controller.engine.binaryMessenger)

        channel.setMethodCallHandler { call, result in
            guard call.method == "getDroppedPath" else {
                result(FlutterMethodNotImplemented)
                return
            }

            if let path = self.getDroppedFilePath(channel: channel) {
                result(path)
            } else {
                result(
                    FlutterError(
                        code: "PATH_ERROR", message: "Não foi possível obet o path", details: nil)
                )
            }

        }

    }

    static func getDroppedFilePath() -> String? {
        return "TODO:"
    }
}
