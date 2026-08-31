import Foundation

class ScanCompletionEngine {
    
    // Determines if the scan has gathered enough information to stop
    func isScanComplete(report: QualityReport) -> Bool {
        // AI Heuristic: Stop if overall quality is high and no critical weak regions remain
        
        let hasCriticalWeakness = report.weakRegions.contains { $0.severity == .critical || $0.severity == .high }
        
        if report.coverageScore > 0.90 && report.geometryScore > 0.85 && !hasCriticalWeakness {
            return true
        }
        
        return false
    }
}
