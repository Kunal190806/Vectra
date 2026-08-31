import Foundation
import ARKit

protocol SensorPipeline {
    var capabilities: DeviceCapabilities { get }
    
    func start()
    func stop()
    
    func processFrame(_ frame: ARFrame) -> SensorCapture?
    
    func captureState() -> SensorCaptureState
}
