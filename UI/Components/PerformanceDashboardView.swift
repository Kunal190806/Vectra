import SwiftUI

struct PerformanceDashboardView: View {
    let report: BenchmarkReport
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text("VECTRA BENCHMARK")
                    .font(.title)
                    .bold()
                
                Group {
                    InfoRow(label: "Device", value: report.deviceName)
                    InfoRow(label: "LiDAR", value: report.hasLiDAR ? "YES" : "NO")
                    InfoRow(label: "Object", value: report.objectCategory)
                }
                
                Divider()
                
                Group {
                    InfoRow(label: "Duration", value: String(format: "%.1fs", report.totalScanDuration))
                    InfoRow(label: "Captured Frames", value: "\(report.totalFramesCaptured)")
                    InfoRow(label: "Selected Frames", value: "\(report.framesSelected)")
                    InfoRow(label: "Reconstruction Time", value: String(format: "%.1fs", report.reconstructionTime))
                    InfoRow(label: "Final Model Size", value: String(format: "%.2f MB", report.finalModelSizeMB))
                }
                
                Divider()
                
                Group {
                    InfoRow(label: "Dimensional Error", value: String(format: "%.2f%%", report.dimensionalErrorPercentage))
                    InfoRow(label: "End Thermal State", value: report.endThermalState)
                    InfoRow(label: "Battery Drain", value: String(format: "%.1f%%", report.batteryDrainPercentage * 100))
                }
            }
            .padding()
            .background(Color.black)
            .foregroundColor(.green) // Terminal style
            .font(.system(.body, design: .monospaced))
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label + ":")
            Spacer()
            Text(value)
                .bold()
        }
    }
}
