//
//  CustomDraggingSource.swift
//  Runner
//
//  Created by Victor Marinho on 15/03/25.
//

import Cocoa

/// CustomDraggingSource é responsável por gerenciar operações de drag and drop nativas do macOS.
/// Implementa o protocolo NSDraggingSource para fornecer feedback visual e comportamental durante operações de drag.
class CustomDraggingSource: NSObject, NSDraggingSource {
    
    /// Callback chamado quando a operação de drag termina
    var onDragEnd: ((Bool) -> Void)?
    
    /// Callback chamado quando o drag começa
    var onDragStart: (() -> Void)?
    
    /// Define as operações permitidas para o contexto de drag
    /// - Parameters:
    ///   - session: A sessão de drag atual
    ///   - context: O contexto onde o drag está ocorrendo
    /// - Returns: As operações permitidas para o contexto
    func draggingSession(
        _ session: NSDraggingSession,
        sourceOperationMaskFor context: NSDraggingContext
    ) -> NSDragOperation {
        switch context {
        case .outsideApplication:
            // Permite copiar e mover quando arrastando para fora do app
            return [.copy, .move, .delete]
        case .withinApplication:
            // Permite apenas copiar e mover dentro do app
            return [.copy, .move]
        @unknown default:
            // Caso seguro para futuros contextos
            return .copy
        }
    }
    
    /// Chamado quando a sessão de drag termina
    /// - Parameters:
    ///   - session: A sessão de drag que terminou
    ///   - screenPoint: O ponto na tela onde o drag terminou
    ///   - operation: A operação que foi realizada
    func draggingSession(
        _ session: NSDraggingSession,
        endedAt screenPoint: NSPoint,
        operation: NSDragOperation
    ) {
        let succeeded = operation != []
        onDragEnd?(succeeded)
    }
    
    /// Chamado quando a sessão de drag está prestes a começar
    /// - Parameter session: A sessão de drag que vai começar
    func draggingSession(
        _ session: NSDraggingSession,
        willBeginAt screenPoint: NSPoint
    ) {
        onDragStart?()
    }
    
    /// Chamado para determinar a imagem de drag
    /// - Parameters:
    ///   - session: A sessão de drag atual
    ///   - offset: O offset da imagem em relação ao cursor
    func draggingSession(
        _ session: NSDraggingSession,
        movedTo screenPoint: NSPoint
    ) {
        // Atualiza a aparência durante o drag se necessário
    }
}
