import SwiftUI

struct QualityDashboardView: View {
    let report: QualityReport
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("SCAN QUALITY")
                .font(.largeTitle)
                .bold()
            
            VStack(spacing: 15) {
                QualityRow(title: "Geometry", score: report.geometryScore)
                QualityRow(title: "Texture", score: report.textureScore)
                QualityRow(title: "Coverage", score: report.coverageScore)
                QualityRow(title: "Tracking", score: report.trackingScore)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            if !report.weakRegions.isEmpty {
                Text("Potential Issues")
                    .font(.headline)
                    .padding(.top, 10)
                
                ForEach(report.weakRegions) { region in
                    HStack {
                        Text("•")
                        Text(region.reasons.map { $0.rawValue }.joined(separator: ", "))
                    }
                    .font(.subheadline)
                    .foregroundColor(.orange)
                }
            }
        }
        .padding()
    }
}

struct QualityRow: View {
    let title: String
    let score: Float
    
    var textValue: String {
        if score > 0.85 { return "Excellent" }
        if score > 0.6 { return "Good" }
        return "Poor"
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            if title == "Coverage" {
                Text(String(format: "%.0f%%", score * 100))
                    .bold()
            } else {
                Text(textValue)
                    .bold()
                    .foregroundColor(score > 0.6 ? .green : .orange)
            }
        }
    }
}
