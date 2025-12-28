import Cocoa
import FlutterMacOS

class MacOSShakeMonitor: NSObject {
    static let shared = MacOSShakeMonitor()
    
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    
    private var methodChannel: FlutterMethodChannel?
    
    // Shake detection variables
    private var lastLocation: CGPoint = .zero
    private var reversalCount = 0
    private var lastReversalTime: TimeInterval = 0
    
    // Configurable parameters
    private let shakeThreshold: CGFloat = 15.0 // Decreased threshold for easier detection
    private let reversalTimeout: TimeInterval = 0.4 // Time window for next reversal
    private let requiredReversals = 5 // Reduced slightly
    
    private var lastDirectionX: Int = 0 // -1 left, 1 right, 0 none
    private var lastDirectionY: Int = 0 // -1 up, 1 down, 0 none
    
    func setup(binaryMessenger: FlutterBinaryMessenger) {
        methodChannel = FlutterMethodChannel(name: "com.easier_drop/shake", binaryMessenger: binaryMessenger)
        startMonitoring()
    }
    
    func startMonitoring() {
        print("MacOSShakeMonitor: startMonitoring called")
        let mask = (1 << CGEventType.mouseMoved.rawValue) | (1 << CGEventType.leftMouseDragged.rawValue)
        
        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(mask),
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                MacOSShakeMonitor.shared.handleEvent(event)
                return Unmanaged.passUnretained(event)
            },
            userInfo: nil
        )
        
        if let tap = eventTap {
            print("MacOSShakeMonitor: Event tap created successfully")
            runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: tap, enable: true)
        } else {
            print("MacOSShakeMonitor: Failed to create event tap. Check Accessibility permissions.")
        }
    }
    
    // ... (stopMonitoring remains same)

    private func handleEvent(_ event: CGEvent) {
        let currentLocation = event.location
        let currentTime = Date().timeIntervalSince1970
        
        // Skip first point or large jumps
        if lastLocation == .zero {
            lastLocation = currentLocation
            return
        }
        
        let deltaX = currentLocation.x - lastLocation.x
        let deltaY = currentLocation.y - lastLocation.y
        
        // Determine direction for X
        var currentDirectionX = 0
        if deltaX > shakeThreshold {
            currentDirectionX = 1
        } else if deltaX < -shakeThreshold {
            currentDirectionX = -1
        }
        
        // Determine direction for Y
        var currentDirectionY = 0
        if deltaY > shakeThreshold {
            currentDirectionY = 1
        } else if deltaY < -shakeThreshold {
            currentDirectionY = -1
        }
        
        var reversalDetected = false
        
        // Check X Reversal
        if currentDirectionX != 0 {
            if lastDirectionX != 0 && currentDirectionX != lastDirectionX {
                reversalDetected = true
            }
            lastDirectionX = currentDirectionX
        }
        
        // Check Y Reversal
        if currentDirectionY != 0 {
            if lastDirectionY != 0 && currentDirectionY != lastDirectionY {
                reversalDetected = true
            }
            lastDirectionY = currentDirectionY
        }
        
        if reversalDetected {
            let timeSinceLastReversal = currentTime - lastReversalTime
            
            if timeSinceLastReversal < reversalTimeout {
                reversalCount += 1
                print("MacOSShakeMonitor: Reversal detected (Any Dir). Count: \(reversalCount)")
            } else {
                reversalCount = 1
                // print("MacOSShakeMonitor: Reset count (timeout)")
            }
            
            lastReversalTime = currentTime
            
            if reversalCount >= requiredReversals {
                print("MacOSShakeMonitor: Shake detected! Triggering...")
                triggerShake(location: currentLocation)
                reversalCount = 0
            }
        }
        
        lastLocation = currentLocation
    }
    
    private func triggerShake(location: CGPoint) {
        // Send event to Flutter with mouse position
        let args: [String: Double] = [
            "x": Double(location.x),
            "y": Double(location.y)
        ]
        
        DispatchQueue.main.async { [weak self] in
            self?.methodChannel?.invokeMethod("shake_detected", arguments: args)
        }
    }
}
