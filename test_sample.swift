import RealityKit
import Foundation

func test() {
    if #available(iOS 17.0, *) {
        let sample = PhotogrammetrySample(id: 1, image: try! CGImage(empty: true)!)
        print(sample)
    }
}
