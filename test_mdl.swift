import Foundation
import ModelIO

func generateDummyUSDZ(at url: URL) {
    let mesh = MDLMesh(
        boxWithExtent: [0.2, 0.2, 0.2],
        segments: [1, 1, 1],
        inwardNormals: false,
        geometryType: .triangles,
        allocator: nil
    )
    let asset = MDLAsset()
    asset.add(mesh)
    do {
        try asset.export(to: url)
        print("Success")
    } catch {
        print(error)
    }
}
generateDummyUSDZ(at: URL(fileURLWithPath: "test.usdz"))
