//
//  DragDrop.swift
//  Runner
//
//  Created by Victor Marinho on 15/03/25.
//
import Cocoa

class CustomDraggingSource: NSObject, NSDraggingSource {
    func draggingSession(
        _ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext
    ) -> NSDragOperation {
        return .copy
    }
}
