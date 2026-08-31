import Foundation
import ARKit
import RealityKit

class HardwareCapabilityManager: ObservableObject {
    static let shared = HardwareCapabilityManager()
    
    private(set) var capabilities: DeviceCapabilities?
    
    private init() {}
    
    func detectCapabilities() -> DeviceCapabilities {
        let supportsARKit = ARConfiguration.isSupported
        let supportsLiDAR = ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh)
        
        // Photogrammetry requires Mac/iPad with Apple Silicon, or iPhone 12 Pro and later.
        let supportsPhotogrammetry = PhotogrammetrySession.isSupported
        
        let hasUltraWide = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) != nil
        let hasTelephoto = AVCaptureDevice.default(.builtInTelephotoCamera, for: .video, position: .back) != nil
        let supportsMultiCamera = AVCaptureMultiCamSession.isMultiCamSupported
        
        let detected = DeviceCapabilities(
            supportsARKit: supportsARKit,
            supportsLiDAR: supportsLiDAR,
            hasUltraWide: hasUltraWide,
            hasTelephoto: hasTelephoto,
            supportsMultiCamera: supportsMultiCamera,
            supportsPhotogrammetry: supportsPhotogrammetry
        )
        
        self.capabilities = detected
        return detected
    }
}
