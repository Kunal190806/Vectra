import Foundation
import AVFoundation

class CameraManager: ObservableObject {
    static let shared = CameraManager()
    
    @Published var isCameraAuthorized = false
    
    private init() {}
    
    func checkPermissions(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.isCameraAuthorized = true
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.isCameraAuthorized = granted
                    completion(granted)
                }
            }
        default:
            self.isCameraAuthorized = false
            completion(false)
        }
    }
}
