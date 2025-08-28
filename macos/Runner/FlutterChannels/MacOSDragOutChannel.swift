import Cocoa
import FlutterMacOS

final class MacOSDragOutChannel: NSObject, NSDraggingSource {
	static let shared = MacOSDragOutChannel()
	private var channel: FlutterMethodChannel?
	private weak var view: NSView?
	private var forceCopyFromCmd: Bool = false

	func setup(view: NSView, messenger: FlutterBinaryMessenger) {
		self.view = view
		channel = FlutterMethodChannel(name: "file_drag_out_channel", binaryMessenger: messenger)
		channel?.setMethodCallHandler(handle)
	}

	private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
		switch call.method {
		case "beginDrag":
			guard let args = call.arguments as? [String: Any],
				  let items = args["items"] as? [String], !items.isEmpty else {
				result(nil)
				return
			}
			beginDrag(paths: items, result: result)
		default:
			result(FlutterMethodNotImplemented)
		}
	}

	private func beginDrag(paths: [String], result: FlutterResult) {
		guard let view = view else {
			result(FlutterError(code: "NO_VIEW", message: "Flutter view ausente", details: nil))
			return
		}
		let fileManager = FileManager.default
		let urls = paths.compactMap { p -> URL? in
			if fileManager.fileExists(atPath: p) { return URL(fileURLWithPath: p) }
			return nil
		}
		if urls.isEmpty {
			result(FlutterError(code: "NO_FILES", message: "Nenhum arquivo válido", details: nil))
			return
		}

		let items: [NSDraggingItem] = urls.map { url in
			let provider = url as NSURL
			let draggingItem = NSDraggingItem(pasteboardWriter: provider)
			let icon = NSWorkspace.shared.icon(forFile: url.path)
			icon.size = NSSize(width: 64, height: 64)
			let frame = NSRect(origin: .zero, size: icon.size)
			draggingItem.setDraggingFrame(frame, contents: icon)
			return draggingItem
		}

		guard let event = NSApp.currentEvent else {
			result(FlutterError(code: "NO_EVENT", message: "Evento atual ausente", details: nil))
			return
		}

		forceCopyFromCmd = event.modifierFlags.contains(.command)

		view.beginDraggingSession(with: items, event: event, source: self)
		result(nil)
	}

	func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
		return [.copy, .move]
	}

	func draggingSession(_ session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
		let effectiveOp: NSDragOperation = forceCopyFromCmd ? .copy : operation
		let op = effectiveOp == .move ? "move" : "copy"
		channel?.invokeMethod("fileDropped", arguments: op)
		forceCopyFromCmd = false
	}
}
