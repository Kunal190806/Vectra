import Foundation
import Vision
import CoreImage
import Combine

struct DetectedObject {
    let boundingRegion: CGRect // Normalized coordinates (0...1)
    let confidence: Float
    let timestamp: TimeInterval
}

enum ObjectTrackingState {
    case searching
    case detected
    case tracking
    case uncertain
    case lost
}

class ObjectDetector: ObservableObject {
    @Published var trackingState: ObjectTrackingState = .searching
    @Published var primaryObject: DetectedObject?
    
    private let objectnessRequest = VNGenerateObjectnessBasedSaliencyImageRequest()
    private var lastProcessTime: TimeInterval = 0
    private let processInterval: TimeInterval = 0.2 // Process 5 frames per second
    
    func processFrame(_ pixelBuffer: CVPixelBuffer, timestamp: TimeInterval) {
        // Throttle processing
        guard timestamp - lastProcessTime > processInterval else { return }
        lastProcessTime = timestamp
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        
        do {
            try handler.perform([objectnessRequest])
            
            if let result = objectnessRequest.results?.first as? VNSaliencyImageObservation {
                let salientObjects = result.salientObjects ?? []
                
                // Find largest salient object (likely our primary target)
                if let largestObject = salientObjects.max(by: { $0.boundingBox.area < $1.boundingBox.area }) {
                    
                    // Simple confidence based on area (just as a placeholder heuristic)
                    let area = Float(largestObject.boundingBox.area)
                    let confidence = min(area * 5.0, 1.0)
                    
                    let detected = DetectedObject(
                        boundingRegion: largestObject.boundingBox,
                        confidence: confidence,
                        timestamp: timestamp
                    )
                    
                    DispatchQueue.main.async {
                        self.primaryObject = detected
                        self.trackingState = .tracking
                    }
                } else {
                    DispatchQueue.main.async {
                        self.trackingState = .lost
                    }
                }
            }
        } catch {
            print("Vision request failed: \(error)")
        }
    }
}

extension CGRect {
    var area: CGFloat {
        return width * height
    }
}
