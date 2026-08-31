import Foundation
import simd

enum WeakRegionSeverity {
    case low
    case medium
    case high
    case critical
}

enum WeakRegionReason: String {
    case insufficientCoverage = "Insufficient Coverage"
    case lowGeometryDensity = "Sparse Geometry"
    case meshHole = "Mesh Hole Detected"
    case poorTexture = "Poor Texture Quality"
    case blur = "Motion Blur"
    case lowFeatureDensity = "Low Feature Density"
    case depthUnavailable = "Depth Unavailable"
    case reconstructionInconsistency = "Geometric Inconsistency"
}

struct BoundingBox {
    var min: SIMD3<Float>
    var max: SIMD3<Float>
}

struct WeakRegion: Identifiable {
    let id = UUID()
    let center: SIMD3<Float>
    let bounds: BoundingBox
    let severity: WeakRegionSeverity
    let confidence: Float // 0.0 to 1.0
    let reasons: [WeakRegionReason]
    let representativeFrameURL: URL? // Used to show evidence
}

struct QualityReport {
    let overallQuality: Float // 0.0 to 1.0
    let coverageScore: Float
    let geometryScore: Float
    let textureScore: Float
    let trackingScore: Float
    let weakRegions: [WeakRegion]
}
