import SwiftUI
import ARKit

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView(frame: .zero)
        
        // Use the shared session that is managed by ARTrackingManager
        arView.session = ARTrackingManager.shared.session
        
        // Let the view automatically handle the scene lighting
        arView.autoenablesDefaultLighting = true
        
        // You could also assign a delegate if you need to render 3D debug anchors
        // arView.delegate = context.coordinator
        
        return arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        // Nothing to update from SwiftUI state in this MVP
    }
}
