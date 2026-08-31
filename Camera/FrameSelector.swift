import Foundation
import ARKit

class FrameSelector {
    private var lastSelectedTime: TimeInterval = 0
    private var lastSelectedTransform: simd_float4x4?
    
    // Configurable thresholds for MVP
    let minTimeInterval: TimeInterval = 0.2 // Max 5 frames per second
    let minTranslationThreshold: Float = 0.05 // 5 cm
    
    func shouldSelect(frame: ARFrame, timestamp: TimeInterval, planner: ScanPlanner?, analyzer: CoverageAnalyzer?) -> Bool {
        // Must have good tracking
        guard frame.camera.trackingState == .normal else {
            return false
        }
        
        // Time check
        guard timestamp - lastSelectedTime >= minTimeInterval else {
            return false
        }
        
        let currentTransform = frame.camera.transform
        
        // Coverage Contribution Check
        var addsCoverage = false
        if let planner = planner, let analyzer = analyzer {
            addsCoverage = analyzer.evaluate(transform: currentTransform, planner: planner)
        } else {
            // Fallback to purely pose-distance based if no intelligent planner exists yet
            addsCoverage = true
        }
        
        // Pose difference check (motion threshold) for redundancy
        var isSufficientlyDifferent = true
        if let lastTransform = lastSelectedTransform {
            let dx = currentTransform.columns.3.x - lastTransform.columns.3.x
            let dy = currentTransform.columns.3.y - lastTransform.columns.3.y
            let dz = currentTransform.columns.3.z - lastTransform.columns.3.z
            let distance = sqrt(dx*dx + dy*dy + dz*dz)
            
            if distance < minTranslationThreshold {
                isSufficientlyDifferent = false
            }
        }
        
        // We select the frame if it adds coverage OR is physically distant enough from the last frame
        if addsCoverage || isSufficientlyDifferent {
            lastSelectedTime = timestamp
            lastSelectedTransform = currentTransform
            return true
        }
        
        return false
    }
    
    func reset() {
        lastSelectedTime = 0
        lastSelectedTransform = nil
    }
}
