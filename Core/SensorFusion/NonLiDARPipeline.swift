import Foundation
import ARKit

class NonLiDARPipeline: SensorPipeline {
    var capabilities: DeviceCapabilities
    private var state: SensorCaptureState = .ready
    
    init(capabilities: DeviceCapabilities) {
        self.capabilities = capabilities
    }
    
    func start() {
        state = .capturing
    }
    
    func stop() {
        state = .ready
    }
    
    func processFrame(_ frame: ARFrame) -> SensorCapture? {
        guard state != .error(NSError()) else { return nil }
        
        let capture = SensorCapture(
            timestamp: frame.timestamp,
            cameraFrames: [CameraFrame(cameraID: "main", imageURL: URL(fileURLWithPath: ""))],
            cameraPose: frame.camera.transform,
            depth: nil, // No LiDAR
            trackingState: frame.camera.trackingState
        )
        
        return capture
    }
    
    func captureState() -> SensorCaptureState {
        return state
    }
}
