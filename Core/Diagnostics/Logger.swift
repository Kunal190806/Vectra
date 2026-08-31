import Foundation

enum LogCategory: String {
    case hardware = "HARDWARE"
    case capture = "CAPTURE"
    case reconstruction = "RECONSTRUCTION"
    case intelligence = "INTELLIGENCE"
    case performance = "PERFORMANCE"
}

class Logger {
    static let shared = Logger()
    
    private init() {}
    
    func log(_ message: String, category: LogCategory, isError: Bool = false) {
        // In a production app, this would use OSLog or a custom persistence layer
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let level = isError ? "ERROR" : "INFO"
        print("[\(timestamp)] [\(category.rawValue)] [\(level)] \(message)")
    }
}
