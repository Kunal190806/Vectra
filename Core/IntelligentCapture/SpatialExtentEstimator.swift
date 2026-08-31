import Foundation
import simd
import ARKit

enum ScanStrategy {
    case small
    case medium
    case large
    case veryLarge
}

struct EstimatedSize {
    let width: Float
    let height: Float
    let depth: Float
    let distanceToCamera: Float
    let centerPosition: simd_float3
    let confidence: Float // 0...1
}

class SpatialExtentEstimator: ObservableObject {
    @Published var currentSize: EstimatedSize?
    @Published var strategy: ScanStrategy = .medium
    
    // Simplistic raycasting method to estimate size based on detected 2D bounding box
    func updateEstimation(with object: DetectedObject, frame: ARFrame) {
        var assumedDistance: Float = 1.0
        var confidence: Float = 0.3
        
        // If LiDAR depth is available, use it to get a much more accurate center distance
        if let sceneDepth = frame.sceneDepth {
            // Simplified: Sample the center of the bounding box
            let u = Int(object.boundingRegion.midX * CGFloat(CVPixelBufferGetWidth(sceneDepth.depthMap)))
            let v = Int(object.boundingRegion.midY * CGFloat(CVPixelBufferGetHeight(sceneDepth.depthMap)))
            
            CVPixelBufferLockBaseAddress(sceneDepth.depthMap, .readOnly)
            if let baseAddress = CVPixelBufferGetBaseAddress(sceneDepth.depthMap) {
                let width = CVPixelBufferGetWidth(sceneDepth.depthMap)
                let bytesPerRow = CVPixelBufferGetBytesPerRow(sceneDepth.depthMap)
                
                // Assuming Float32 depth (meters)
                if CVPixelBufferGetPixelFormatType(sceneDepth.depthMap) == kCVPixelFormatType_DepthFloat32 {
                    let buffer = baseAddress.assumingMemoryBound(to: Float32.self)
                    let index = v * (bytesPerRow / MemoryLayout<Float32>.size) + u
                    let depthValue = buffer[index]
                    
                    if depthValue > 0 && depthValue < 10.0 { // reasonable scan range
                        assumedDistance = depthValue
                        confidence = 0.8 // High confidence with LiDAR
                    }
                } else if CVPixelBufferGetPixelFormatType(sceneDepth.depthMap) == kCVPixelFormatType_DepthFloat16 {
                    // Swift doesn't have native Float16 representation before iOS 14, but we can do byte manipulation.
                    // For MVP, we'll keep the logic conceptual.
                    assumedDistance = 1.0 // fallback
                }
            }
            CVPixelBufferUnlockBaseAddress(sceneDepth.depthMap, .readOnly)
        }
        
        // Approximate width and height in meters using FOV and distance
        let fovHorizontal: Float = .pi / 3.0 
        let viewWidth = 2.0 * assumedDistance * tan(fovHorizontal / 2.0)
        
        let widthMeters = Float(object.boundingRegion.width) * viewWidth
        let heightMeters = Float(object.boundingRegion.height) * viewWidth // simplify ratio
        
        let estimated = EstimatedSize(
            width: widthMeters,
            height: heightMeters,
            depth: widthMeters, // assume roughly cubic
            distanceToCamera: assumedDistance,
            centerPosition: simd_float3(0, 0, -assumedDistance), // relative to camera
            confidence: confidence 
        )
        
        DispatchQueue.main.async {
            self.currentSize = estimated
            self.strategy = self.determineStrategy(for: estimated)
        }
    }
    
    private func determineStrategy(for size: EstimatedSize) -> ScanStrategy {
        let maxDimension = max(size.width, size.height, size.depth)
        
        if maxDimension < 0.3 {
            return .small
        } else if maxDimension < 1.0 {
            return .medium
        } else if maxDimension < 3.0 {
            return .large
        } else {
            return .veryLarge
        }
    }
}
