import Foundation
import ARKit
import Combine

/// Represents the two possible reconstruction pipelines.
enum ReconstructionPipeline {
    case liDARPro
    case nonLiDAR
}

enum FusionState {
    case ready          // waiting for capture
    case capturing      // frames incoming
    case processing     // reconstruction running
    case finished(Mesh) // placeholder type for finished mesh
    case error(Error)
}

/// Simple placeholder for a reconstructed mesh.
struct Mesh {}

final class SensorFusionEngine: ObservableObject {
    static let shared = SensorFusionEngine()
    private init() {
        // Choose pipeline based on device capabilities.
        if HardwareCapabilityManager.shared.capabilities?.supportsLiDAR == true {
            pipeline = .liDARPro
        } else {
            pipeline = .nonLiDAR
        }
    }
    
    // MARK: - Published State
    @Published var pipeline: ReconstructionPipeline
    @Published var state: FusionState = .ready
    @Published var capturedFrames: [ScanFrame] = []
    @Published var capturedFramesCount: Int = 0
    
    private let maxFrames = 150
    private var cancellables = Set<AnyCancellable>()
    
    /// Called by ScanView when frames should be ingested (after scan stops, or in real-time).
    func ingest(frames newFrames: [ScanFrame]) {
        // Transition from .ready to .capturing if needed
        if case .ready = state { state = .capturing }
        // Only accept frames while capturing
        guard case .capturing = state else { return }
        
        capturedFrames.append(contentsOf: newFrames)
        if capturedFrames.count > maxFrames {
            capturedFrames.removeFirst(capturedFrames.count - maxFrames)
        }
        capturedFramesCount = capturedFrames.count
        // Start reconstruction once we have enough frames
        if capturedFrames.count >= 10 {
            startProcessing()
        }
    }
    
    private func startProcessing() {
        state = .processing
        // Hand off frames to the reconstruction manager.
        ReconstructionManager.shared.startReconstruction(with: capturedFrames, using: pipeline)
    }
    
    /// Called by ReconstructionManager when a mesh is ready.
    func reconstructionFinished(mesh: Mesh) {
        state = .finished(mesh)
        // Trigger AI analysis.
        SpatialIntelligenceEngine.shared.analyze(mesh: mesh)
    }
}
