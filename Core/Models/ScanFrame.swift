import Foundation
import ARKit

struct ScanFrame {
    let imageURL: URL
    let depthData: DepthFrame?
    let timestamp: TimeInterval
    let cameraTransform: simd_float4x4
    let intrinsics: simd_float3x3
    let trackingState: ARCamera.TrackingState
}
