import Foundation
import ARKit
import CoreImage

class VideoCaptureManager: ObservableObject {
    static let shared = VideoCaptureManager()
    
    private let arManager = ARTrackingManager.shared
    private let frameSelector = FrameSelector()
    private let context = CIContext()
    
    // Intelligent Capture Components
    let objectDetector = ObjectDetector()
    let spatialEstimator = SpatialExtentEstimator()
    let scanPlanner = ScanPlanner()
    let coverageAnalyzer = CoverageAnalyzer()
    
    @Published var isCapturing = false
    @Published var capturedFramesCount = 0
    
    var currentScanSessionURL: URL?
    var framesDirectory: URL?
    
    private(set) var capturedFrames: [ScanFrame] = []

    /// Public accessor for the fusion engine to consume after scan stops.
    var exposedFrames: [ScanFrame] { capturedFrames }
    
    init() {}
    
    func startCamera() {
        // Start AR tracking without resetting if it's already running
        // This is called when the view appears.
        arManager.startTracking()
    }
    
    func startCapture(sessionID: String = UUID().uuidString) {
        setupDirectories(for: sessionID)
        frameSelector.reset()
        capturedFrames.removeAll()
        capturedFramesCount = 0
        isCapturing = true
    }
    
    func stopCapture() {
        isCapturing = false
        arManager.stopTracking()
        saveMetadata()
    }
    
    func processFrame(_ frame: ARFrame) {
        let timestamp = frame.timestamp
        
        // 1. Process Object Detection on periodic basis (independent of capture)
        objectDetector.processFrame(frame.capturedImage, timestamp: timestamp)
        
        // 2. If we detected an object, update spatial estimate (and planning)
        if let primaryObject = objectDetector.primaryObject, spatialEstimator.currentSize == nil {
            spatialEstimator.updateEstimation(with: primaryObject, frame: frame)
            
            // Once we have a size, generate plan
            if let size = spatialEstimator.currentSize {
                scanPlanner.generatePlan(for: size, strategy: spatialEstimator.strategy)
            }
        }
        
        guard isCapturing else { return }
        
        // 3. Evaluate if we should select the frame using intelligent frame selector
        if frameSelector.shouldSelect(frame: frame, timestamp: timestamp, planner: scanPlanner, analyzer: coverageAnalyzer) {
            save(frame: frame)
        }
    }
    
    var depthDirectory: URL?
    
    private func setupDirectories(for sessionID: String) {
        let fileManager = FileManager.default
        let tempDir = fileManager.temporaryDirectory
        let sessionDir = tempDir.appendingPathComponent("ScanSession_\(sessionID)", isDirectory: true)
        let framesDir = sessionDir.appendingPathComponent("frames", isDirectory: true)
        let depthDir = sessionDir.appendingPathComponent("depth", isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: framesDir, withIntermediateDirectories: true, attributes: nil)
            try fileManager.createDirectory(at: depthDir, withIntermediateDirectories: true, attributes: nil)
            self.currentScanSessionURL = sessionDir
            self.framesDirectory = framesDir
            self.depthDirectory = depthDir
        } catch {
            print("Failed to create scan directories: \(error)")
        }
    }
    
    private func save(frame: ARFrame) {
        guard let framesDir = framesDirectory else { return }
        
        let frameCount = capturedFrames.count
        let fileName = String(format: "frame_%04d.jpg", frameCount)
        let fileURL = framesDir.appendingPathComponent(fileName)
        
        // Depth
        var depthFrameData: DepthFrame? = nil
        if let sceneDepth = frame.sceneDepth, let depthDir = depthDirectory {
            let depthFileName = String(format: "depth_%04d.tiff", frameCount)
            let depthURL = depthDir.appendingPathComponent(depthFileName)
            let depthCIImage = CIImage(cvPixelBuffer: sceneDepth.depthMap)
            
            // TIFF preserves floats
            do {
                try context.writeTIFFRepresentation(of: depthCIImage, to: depthURL, format: .L16, colorSpace: CGColorSpace(name: CGColorSpace.linearGray)!, options: [:])
                
                depthFrameData = DepthFrame(
                    url: depthURL,
                    width: CVPixelBufferGetWidth(sceneDepth.depthMap),
                    height: CVPixelBufferGetHeight(sceneDepth.depthMap),
                    format: CVPixelBufferGetPixelFormatType(sceneDepth.depthMap),
                    accuracy: 1.0
                )
            } catch {
                print("Failed to save depth: \(error)")
            }
        }
        
        // Convert CVPixelBuffer to JPEG
        let ciImage = CIImage(cvPixelBuffer: frame.capturedImage)
        if let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) {
            do {
                try context.writeJPEGRepresentation(of: ciImage, to: fileURL, colorSpace: colorSpace, options: [:])
                
                let scanFrame = ScanFrame(
                    imageURL: fileURL,
                    depthData: depthFrameData,
                    timestamp: frame.timestamp,
                    cameraTransform: frame.camera.transform,
                    intrinsics: frame.camera.intrinsics,
                    trackingState: frame.camera.trackingState
                )
                
                DispatchQueue.main.async {
                    self.capturedFrames.append(scanFrame)
                    self.capturedFramesCount = self.capturedFrames.count
                }
            } catch {
                print("Failed to save frame: \(error)")
            }
        }
    }
    
    private func saveMetadata() {
        // Serialization placeholder
    }
}
