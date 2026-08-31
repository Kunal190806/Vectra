import Foundation
import ARKit

struct DepthFrame {
    let url: URL
    let width: Int
    let height: Int
    let format: OSType
    let accuracy: Float
}

struct CameraFrame {
    let cameraID: String
    let imageURL: URL
}

struct SensorCapture {
    let timestamp: TimeInterval
    let cameraFrames: [CameraFrame]
    let cameraPose: simd_float4x4
    let depth: DepthFrame?
    let trackingState: ARCamera.TrackingState
}

enum SensorCaptureState: Equatable {
    case ready
    case capturing
    case thermalThrottled
    case error(Error)
    
    static func == (lhs: SensorCaptureState, rhs: SensorCaptureState) -> Bool {
        switch (lhs, rhs) {
        case (.ready, .ready): return true
        case (.capturing, .capturing): return true
        case (.thermalThrottled, .thermalThrottled): return true
        case (.error(let e1), .error(let e2)):
            return (e1 as NSError).domain == (e2 as NSError).domain && (e1 as NSError).code == (e2 as NSError).code
        default: return false
        }
    }
}
