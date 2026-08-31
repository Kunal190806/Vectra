import Foundation

struct BenchmarkReport {
    let deviceName: String
    let hasLiDAR: Bool
    let objectCategory: String
    
    let totalScanDuration: TimeInterval
    let totalFramesCaptured: Int
    let framesSelected: Int
    let supplementalFrames: Int
    
    let reconstructionTime: TimeInterval
    let finalModelSizeMB: Double
    let dimensionalErrorPercentage: Double
    
    let endThermalState: String
    let batteryDrainPercentage: Float
}

class BenchmarkManager {
    static let shared = BenchmarkManager()
    
    private var scanStartTime: Date?
    private var framesCaptured: Int = 0
    private var batteryStart: Float = 1.0 // Mock 100%
    
    private init() {}
    
    func startTracking() {
        scanStartTime = Date()
        framesCaptured = 0
        // In reality, read from UIDevice.current.batteryLevel
    }
    
    func trackFrame() {
        framesCaptured += 1
    }
    
    func generateReport(objectCategory: String, framesSelected: Int, reconstructionTime: TimeInterval, modelSizeMB: Double) -> BenchmarkReport {
        let duration = Date().timeIntervalSince(scanStartTime ?? Date())
        
        // Mocked metrics for MVP
        let batteryDrain: Float = 0.05 // 5% drain mock
        let dimensionalError = 0.8 // 0.8% error mock
        
        return BenchmarkReport(
            deviceName: "iPhone Pro (Simulated)",
            hasLiDAR: true,
            objectCategory: objectCategory,
            totalScanDuration: duration,
            totalFramesCaptured: framesCaptured,
            framesSelected: framesSelected,
            supplementalFrames: 0,
            reconstructionTime: reconstructionTime,
            finalModelSizeMB: modelSizeMB,
            dimensionalErrorPercentage: dimensionalError,
            endThermalState: "Nominal",
            batteryDrainPercentage: batteryDrain
        )
    }
}
