import Foundation
import ARKit
import Combine

class ARTrackingManager: NSObject, ObservableObject {
    static let shared = ARTrackingManager()
    
    let session = ARSession()
    
    @Published var trackingState: ARCamera.TrackingState = .notAvailable
    @Published var currentTransform: simd_float4x4 = matrix_identity_float4x4
    @Published var isLowLight: Bool = false
    
    override private init() {
        super.init()
        session.delegate = self
    }
    
    func startTracking() {
        let configuration = ARWorldTrackingConfiguration()
        
        // Enable plane detection for size estimation raycasting
        configuration.planeDetection = [.horizontal, .vertical]
        
        // Determine capabilities
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            configuration.sceneReconstruction = .mesh
        }
        
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
            configuration.frameSemantics.insert(.sceneDepth)
            if ARWorldTrackingConfiguration.supportsFrameSemantics(.smoothedSceneDepth) {
                configuration.frameSemantics.insert(.smoothedSceneDepth)
            }
        }
        
        // Run session
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func stopTracking() {
        session.pause()
    }
}

extension ARTrackingManager: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        DispatchQueue.main.async {
            self.trackingState = frame.camera.trackingState
            self.currentTransform = frame.camera.transform
            
            // Detect low light conditions
            if let lightEstimate = frame.lightEstimate {
                // ambientIntensity around 1000 is neutral. Below ~400 is getting dark for photogrammetry.
                self.isLowLight = lightEstimate.ambientIntensity < 400
            } else {
                self.isLowLight = false
            }
        }
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        DispatchQueue.main.async {
            self.trackingState = camera.trackingState
        }
    }
}
