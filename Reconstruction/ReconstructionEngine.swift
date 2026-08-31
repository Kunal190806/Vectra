import Foundation

/// Protocol that defines a reconstruction engine capable of processing input frames and producing a mesh/model.
protocol ReconstructionEngine {
    /// Perform reconstruction using the given input folder and write the result to outputURL.
    /// - Parameters:
    ///   - inputFolder: Directory containing captured frames and depth data.
    ///   - outputURL: Destination file URL for the generated model.
    /// - Returns: A `ReconstructionResult` describing the outcome.
    func reconstruct(inputFolder: URL, outputURL: URL) async throws -> ReconstructionResult
}
