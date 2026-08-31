import Foundation

struct ReconstructionResult {
    let modelURL: URL
    let processTime: TimeInterval
    let frameCount: Int
    let success: Bool
    let error: Error?
}
