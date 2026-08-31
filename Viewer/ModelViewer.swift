import SwiftUI
import RealityKit

struct RealityKitView: UIViewRepresentable {
    var modelURL: URL
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
        
        let camera = PerspectiveCamera()
        let cameraAnchor = AnchorEntity(world: .zero)
        cameraAnchor.addChild(camera)
        arView.scene.addAnchor(cameraAnchor)
        
        // Basic orbit logic would go here, but for MVP we load the entity
        do {
            let entity = try Entity.load(contentsOf: modelURL)
            let anchor = AnchorEntity(world: .zero)
            anchor.addChild(entity)
            arView.scene.addAnchor(anchor)
            
            // Adjust camera position based on bounding box
            let bounds = entity.visualBounds(relativeTo: nil)
            let maxDimension = max(bounds.extents.x, bounds.extents.y, bounds.extents.z)
            cameraAnchor.position = [0, 0, maxDimension * 2.0]
            
        } catch {
            print("Failed to load model into RealityKit: \(error)")
        }
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}
