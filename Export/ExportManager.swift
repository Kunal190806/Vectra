import Foundation
import UIKit
import QuickLook

enum ExportFormat: String {
    case usdz = "usdz"
    case obj = "obj"
    case stl = "stl"
}

struct ExportConfiguration {
    let quality: OptimizationLevel
    let format: ExportFormat
}

class ExportManager: ObservableObject {
    static let shared = ExportManager()
    
    private init() {}
    
    func export(modelURL: URL, configuration: ExportConfiguration = ExportConfiguration(quality: .original, format: .usdz)) {
        // Use document picker to strictly prompt the user for a save location in the Files app
        let documentPicker = UIDocumentPickerViewController(forExporting: [modelURL])
        
        // Find the topmost view controller to present the picker
        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            
            var topVC = rootVC
            while let presentedVC = topVC.presentedViewController {
                topVC = presentedVC
            }
            
            topVC.present(documentPicker, animated: true, completion: nil)
        }
    }
}
