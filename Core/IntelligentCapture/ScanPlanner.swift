import Foundation
import simd

struct TargetViewpoint {
    let id = UUID()
    let angle: Float // Radians around Y axis
    let heightOffset: Float
    let requiredDistance: Float
    var isCaptured: Bool = false
}

class ScanPlanner: ObservableObject {
    @Published var targetViewpoints: [TargetViewpoint] = []
    
    func generatePlan(for size: EstimatedSize, strategy: ScanStrategy) {
        var targets: [TargetViewpoint] = []
        
        let pointCount: Int
        let distance: Float
        
        switch strategy {
        case .small:
            pointCount = 8
            distance = 0.5
        case .medium:
            pointCount = 12
            distance = 1.0
        case .large:
            pointCount = 16
            distance = 2.0
        case .veryLarge:
            pointCount = 24
            distance = 3.0
        }
        
        for i in 0..<pointCount {
            let angle = (Float(i) / Float(pointCount)) * 2.0 * .pi
            let target = TargetViewpoint(
                angle: angle,
                heightOffset: size.height / 2.0, // Aim at middle
                requiredDistance: distance
            )
            targets.append(target)
        }
        
        DispatchQueue.main.async {
            self.targetViewpoints = targets
        }
    }
}
