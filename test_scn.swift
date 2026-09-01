import Foundation
import SceneKit

func generateDummyUSDZ(at url: URL) {
    let scene = SCNScene()
    let box = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0.02)
    box.firstMaterial?.diffuse.contents = NSColor.blue
    let node = SCNNode(geometry: box)
    scene.rootNode.addChildNode(node)
    
    let success = scene.write(to: url, options: nil, delegate: nil, progressHandler: nil)
    print("Success: \(success)")
}
generateDummyUSDZ(at: URL(fileURLWithPath: "test2.usdz"))
