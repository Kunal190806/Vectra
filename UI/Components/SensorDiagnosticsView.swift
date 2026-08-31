import SwiftUI

struct SensorDiagnosticsView: View {
    @ObservedObject var hardwareManager = HardwareCapabilityManager.shared
    @ObservedObject var fusionEngine = SensorFusionEngine.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("DEVICE")
                .font(.headline)

            if let caps = hardwareManager.capabilities {
                HStack { Text("ARKit"); Spacer(); Text(caps.supportsARKit ? "✓" : "❌") }
                HStack { Text("LiDAR"); Spacer(); Text(caps.supportsLiDAR ? "✓" : "❌") }
                HStack { Text("Ultra Wide"); Spacer(); Text(caps.hasUltraWide ? "✓" : "❌") }
                HStack { Text("Telephoto"); Spacer(); Text(caps.hasTelephoto ? "✓" : "❌") }
            }

            Divider().background(Color.white)

            Text("ACTIVE PIPELINE")
                .font(.headline)
            Text(fusionEngine.pipeline == .liDARPro ? "LiDAR Pro" : "Non-LiDAR")
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            Divider().background(Color.white)

            Text("PIPELINE STATE")
                .font(.headline)
            fusionStateView

            Divider().background(Color.white)

            Text("FRAMES")
                .font(.headline)
            Text("\(fusionEngine.capturedFrames.count) collected")
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .foregroundColor(.green)
        .cornerRadius(10)
        .font(.system(.body, design: .monospaced))
    }

    @ViewBuilder
    private var fusionStateView: some View {
        switch fusionEngine.state {
        case .ready:
            Text("Ready")
        case .capturing:
            Text("Capturing").foregroundColor(.yellow)
        case .processing:
            Text("Processing…").foregroundColor(.orange)
        case .finished:
            Text("Finished ✓").foregroundColor(.green)
        case .error(let err):
            Text("Error: \(err.localizedDescription)").foregroundColor(.red)
        }
    }
}

