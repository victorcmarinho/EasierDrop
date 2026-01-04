import Cocoa
import FlutterMacOS
import ServiceManagement

class MacOSLaunchAtLoginChannel {
    static let shared = MacOSLaunchAtLoginChannel()
    private let channelName = "com.easierdrop/launch_at_login"
    
    private init() {}
    
    func setup(binaryMessenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(
            name: channelName,
            binaryMessenger: binaryMessenger
        )
        
        channel.setMethodCallHandler { [weak self] (call, result) in
            self?.handleMethodCall(call, result: result)
        }
    }
    
    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "checkPermission":
            checkPermission(result: result)
        case "isEnabled":
            isEnabled(result: result)
        case "setEnabled":
            if let args = call.arguments as? [String: Any],
               let enabled = args["enabled"] as? Bool {
                setEnabled(enabled: enabled, result: result)
            } else {
                result(FlutterError(
                    code: "INVALID_ARGUMENTS",
                    message: "Missing or invalid 'enabled' argument",
                    details: nil
                ))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func checkPermission(result: @escaping FlutterResult) {
        if #available(macOS 13.0, *) {
            let service = SMAppService.mainApp
            // If status is .notFound or .requiresApproval, permission is needed
            // If status is .enabled or .notRegistered, permission is granted
            let hasPermission = service.status != .requiresApproval
            result(hasPermission)
        } else {
            // For macOS < 13.0, we don't have this functionality
            result(false)
        }
    }
    
    private func isEnabled(result: @escaping FlutterResult) {
        if #available(macOS 13.0, *) {
            let service = SMAppService.mainApp
            result(service.status == .enabled)
        } else {
            result(false)
        }
    }
    
    private func setEnabled(enabled: Bool, result: @escaping FlutterResult) {
        if #available(macOS 13.0, *) {
            let service = SMAppService.mainApp
            
            do {
                if enabled {
                    if service.status == .enabled {
                        // Already enabled
                        result(nil)
                        return
                    }
                    try service.register()
                } else {
                    if service.status == .notRegistered {
                        // Already disabled
                        result(nil)
                        return
                    }
                    try service.unregister()
                }
                result(nil)
            } catch {
                result(FlutterError(
                    code: "LAUNCH_AT_LOGIN_ERROR",
                    message: "Failed to \(enabled ? "enable" : "disable") launch at login: \(error.localizedDescription)",
                    details: nil
                ))
            }
        } else {
            result(FlutterError(
                code: "UNSUPPORTED_OS",
                message: "Launch at login requires macOS 13.0 or later",
                details: nil
            ))
        }
    }
}
