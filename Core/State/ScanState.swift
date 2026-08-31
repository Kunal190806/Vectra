import Foundation

enum ScanState {
    case idle
    case initializing
    case ready
    case scanning
    case capturing
    case preparing
    case reconstructing
    case completed
    case viewing
    case error(Error)
    case cancelled
    case insufficientData(String)
}
