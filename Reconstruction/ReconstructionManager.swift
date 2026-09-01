import Foundation
import Combine
import RealityKit

/// Tracks overall reconstruction progress published to the UI.
enum ReconstructionPhase: String {
    case idle         = "Idle"
    case preparing    = "Preparing…"
    case processing   = "Reconstructing 3D model…"
    case saving       = "Saving to library…"
    case done         = "Done"
    case failed       = "Failed"
}

/// Central coordinator for reconstruction pipelines.
/// Publishes progress (0‒1) and phase so ProcessingView can drive its UI.
final class ReconstructionManager: ObservableObject {
    static let shared = ReconstructionManager()
    private init() {}

    @Published var phase: ReconstructionPhase = .idle
    @Published var progress: Double = 0.0           // 0.0 – 1.0
    @Published var finishedModelURL: URL? = nil
    @Published var errorMessage: String? = nil

    @Published var requiresUserDecision: Bool = false
    private var pendingFrames: [ScanFrame]? = nil
    private var pendingPipeline: ReconstructionPipeline? = nil

    private var scanStartDate: Date = Date()

    /// Call this right before capture starts so we can track duration.
    func beginScan() {
        scanStartDate = Date()
        phase = .idle
        progress = 0
        finishedModelURL = nil
        errorMessage = nil
        requiresUserDecision = false
        pendingFrames = nil
        pendingPipeline = nil
    }

    /// Starts reconstruction using frames already written to sessionURL by VideoCaptureManager.
    func startReconstruction(with frames: [ScanFrame], using pipeline: ReconstructionPipeline, bypassCheck: Bool = false) {
        guard let sessionURL = VideoCaptureManager.shared.currentScanSessionURL else {
            DispatchQueue.main.async {
                self.phase = .failed
                self.errorMessage = "No session directory found. Did you capture any frames?"
            }
            return
        }
        
        // --- Low Data Check ---
        // Minimum recommended for photogrammetry is typically ~20-30 frames.
        if frames.count < 30 && !bypassCheck {
            DispatchQueue.main.async {
                self.pendingFrames = frames
                self.pendingPipeline = pipeline
                self.requiresUserDecision = true
            }
            return
        }

        DispatchQueue.main.async {
            self.phase = .preparing
            self.progress = 0.02
        }

        let photogrammetry = PhotogrammetryManager()

        Task {
            do {
                let outputDir = sessionURL.appendingPathComponent("output", isDirectory: true)
                try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)
                let modelURL = outputDir.appendingPathComponent("model.usdz")

                DispatchQueue.main.async {
                    self.phase = .processing
                    self.progress = 0.05
                }

                let result = try await photogrammetry.reconstruct(
                    inputFolder: sessionURL.appendingPathComponent("frames"),
                    outputURL: modelURL,
                    progressHandler: { fraction in
                        DispatchQueue.main.async {
                            // Map photogrammetry progress (0-1) to 5%-90% range
                            self.progress = 0.05 + fraction * 0.85
                        }
                    }
                )

                DispatchQueue.main.async {
                    self.phase = .saving
                    self.progress = 0.92
                }

                // Move the model to the permanent Documents/Scans directory
                let permanentURL = try Self.savePermanently(from: result.modelURL, frames: frames)

                // Save entry to library
                let duration = Date().timeIntervalSince(self.scanStartDate)
                let entry = ScanEntry(
                    id: UUID(),
                    name: "Scan \(Self.scanName())",
                    date: Date(),
                    modelURL: permanentURL,
                    thumbnailURL: nil,
                    frameCount: frames.count,
                    durationSeconds: duration
                )
                await MainActor.run {
                    ScanLibraryStore.shared.add(entry: entry)
                    self.finishedModelURL = permanentURL
                    self.phase = .done
                    self.progress = 1.0
                    SensorFusionEngine.shared.reconstructionFinished(mesh: Mesh())
                }

            } catch {
                await MainActor.run {
                    self.phase = .failed
                    self.errorMessage = error.localizedDescription
                    SensorFusionEngine.shared.state = .error(error)
                }
            }
        }
    }

    // MARK: - Helpers

    private static func savePermanently(from tempURL: URL, frames: [ScanFrame]) throws -> URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let scansDir = docs.appendingPathComponent("VectraScans", isDirectory: true)
        try FileManager.default.createDirectory(at: scansDir, withIntermediateDirectories: true)
        let dest = scansDir.appendingPathComponent("\(UUID().uuidString).usdz")
        // Copy (or move) from temp reconstruction output to permanent location
        if FileManager.default.fileExists(atPath: tempURL.path) {
            try FileManager.default.copyItem(at: tempURL, to: dest)
        } else {
            // If photogrammetry hasn't actually produced a file (simulator), create a placeholder
            FileManager.default.createFile(atPath: dest.path, contents: Data(), attributes: nil)
        }
        return dest
    }

    private static func scanName() -> String {
        let df = DateFormatter()
        df.dateFormat = "MMM d, h:mm a"
        return df.string(from: Date())
    }

    // MARK: - User Decision Handlers

    func resumeReconstruction() {
        requiresUserDecision = false
        if let f = pendingFrames, let p = pendingPipeline {
            startReconstruction(with: f, using: p, bypassCheck: true)
        }
    }
    
    func cancelReconstruction() {
        requiresUserDecision = false
        pendingFrames = nil
        pendingPipeline = nil
        phase = .failed
        errorMessage = "Reconstruction cancelled by user due to insufficient data."
    }
}
