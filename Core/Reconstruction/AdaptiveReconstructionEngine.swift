import Foundation
import RealityKit

protocol AdaptiveReconstructionEngine {
    func generatePreview(sessionURL: URL) async throws -> URL
    func analyze(previewURL: URL) async throws -> QualityReport
    func generateFinal(sessionURL: URL) async throws -> URL
}

enum AdaptiveReconstructionState {
    case idle
    case preparing
    case buildingPreview
    case analyzing
    case reviewRequired(QualityReport)
    case buildingFinal
    case finished(URL)
    case error(Error)
}

class VectraAdaptiveEngine: ObservableObject, AdaptiveReconstructionEngine {
    @Published var state: AdaptiveReconstructionState = .idle
    
    private let photogrammetryManager = PhotogrammetryManager()
    private let meshAnalyzer = MeshAnalyzer()
    
    func runAdaptiveLoop(sessionURL: URL) {
        Task {
            do {
                // 1. Preview
                DispatchQueue.main.async { self.state = .buildingPreview }
                let previewURL = try await generatePreview(sessionURL: sessionURL)
                
                // 2. Analyze
                DispatchQueue.main.async { self.state = .analyzing }
                let report = try await analyze(previewURL: previewURL)
                
                // 3. Review (Pause loop for user)
                DispatchQueue.main.async {
                    if report.weakRegions.isEmpty {
                        // If perfect, proceed to final (rare)
                        self.proceedToFinal(sessionURL: sessionURL)
                    } else {
                        // Ask user
                        self.state = .reviewRequired(report)
                    }
                }
            } catch {
                DispatchQueue.main.async { self.state = .error(error) }
            }
        }
    }
    
    func proceedToFinal(sessionURL: URL) {
        Task {
            do {
                DispatchQueue.main.async { self.state = .buildingFinal }
                let finalURL = try await generateFinal(sessionURL: sessionURL)
                
                DispatchQueue.main.async { self.state = .finished(finalURL) }
            } catch {
                DispatchQueue.main.async { self.state = .error(error) }
            }
        }
    }
    
    func generatePreview(sessionURL: URL) async throws -> URL {
        let outputURL = sessionURL.appendingPathComponent("preview.usdz")
        let result = try await photogrammetryManager.reconstruct(inputFolder: sessionURL, outputURL: outputURL)
        return result.modelURL
    }
    
    func analyze(previewURL: URL) async throws -> QualityReport {
        // In MVP, we only analyze mesh geometry
        let regions = meshAnalyzer.analyzeMesh(at: previewURL)
        
        let report = QualityReport(
            overallQuality: regions.isEmpty ? 0.95 : 0.70,
            coverageScore: 0.8,
            geometryScore: regions.isEmpty ? 0.9 : 0.6,
            textureScore: 0.85,
            trackingScore: 1.0,
            weakRegions: regions
        )
        return report
    }
    
    func generateFinal(sessionURL: URL) async throws -> URL {
        let outputURL = sessionURL.appendingPathComponent("final.usdz")
        let result = try await photogrammetryManager.reconstruct(inputFolder: sessionURL, outputURL: outputURL)
        return result.modelURL
    }
}
