import Foundation
import simd

class CoverageAnalyzer: ObservableObject {
    @Published var coveragePercentage: Float = 0.0
    
    // Evaluate if a frame's pose satisfies a target viewpoint
    func evaluate(transform: simd_float4x4, planner: ScanPlanner) -> Bool {
        // Extract angle around Y-axis (very simplified for MVP)
        let yaw = atan2(transform.columns.0.z, transform.columns.0.x)
        var addedValue = false
        
        // Check against targets
        for i in 0..<planner.targetViewpoints.count {
            if !planner.targetViewpoints[i].isCaptured {
                let targetAngle = planner.targetViewpoints[i].angle
                
                // Compare angles (handling wrap-around)
                var diff = abs(yaw - targetAngle)
                if diff > .pi {
                    diff = 2.0 * .pi - diff
                }
                
                // If we are within ~15 degrees
                if diff < (.pi / 12.0) {
                    planner.targetViewpoints[i].isCaptured = true
                    addedValue = true
                }
            }
        }
        
        if addedValue {
            updateCoverage(planner: planner)
        }
        
        return addedValue
    }
    
    private func updateCoverage(planner: ScanPlanner) {
        let total = planner.targetViewpoints.count
        guard total > 0 else { return }
        
        let captured = planner.targetViewpoints.filter { $0.isCaptured }.count
        
        DispatchQueue.main.async {
            self.coveragePercentage = Float(captured) / Float(total)
        }
    }
}
