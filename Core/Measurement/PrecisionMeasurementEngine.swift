import Foundation
import simd

enum MeasurementSource {
    case reconstructedGeometry
    case LiDAR
    case ARKit
    case fused
}

struct MeasurementResult {
    let value: Double
    let unit: UnitLength
    let confidence: Float // 0 to 1
    let source: MeasurementSource
}

class PrecisionMeasurementEngine {
    
    // Calculates the Euclidean distance between two points in 3D space
    func distance(between pointA: SIMD3<Float>, and pointB: SIMD3<Float>, source: MeasurementSource = .reconstructedGeometry) -> MeasurementResult {
        let diff = pointA - pointB
        let length = simd_length(diff)
        
        // MVP: Assume basic confidence heuristics based on source
        var confidence: Float = 0.5
        if source == .LiDAR { confidence = 0.95 }
        if source == .fused { confidence = 0.99 }
        if source == .reconstructedGeometry { confidence = 0.85 }
        
        return MeasurementResult(
            value: Double(length),
            unit: .meters,
            confidence: confidence,
            source: source
        )
    }
    
    // Basic automatic bounding box dimensions
    func boundingDimensions(for minBounds: SIMD3<Float>, maxBounds: SIMD3<Float>) -> (width: MeasurementResult, height: MeasurementResult, depth: MeasurementResult) {
        let extents = maxBounds - minBounds
        
        let w = MeasurementResult(value: Double(extents.x), unit: .meters, confidence: 0.8, source: .reconstructedGeometry)
        let h = MeasurementResult(value: Double(extents.y), unit: .meters, confidence: 0.8, source: .reconstructedGeometry)
        let d = MeasurementResult(value: Double(extents.z), unit: .meters, confidence: 0.8, source: .reconstructedGeometry)
        
        return (w, h, d)
    }
}
