import SwiftUI

struct QualityReviewView: View {
    let report: QualityReport
    let onAddDetail: () -> Void
    let onContinue: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("SCAN REVIEW")
                .font(.largeTitle)
                .bold()
            
            HStack {
                Text("Overall Quality")
                    .font(.headline)
                Spacer()
                Text(String(format: "%.0f%%", report.overallQuality * 100))
                    .bold()
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            
            Text("Potential Improvements")
                .font(.title2)
                .bold()
                .padding(.top, 10)
            
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(report.weakRegions) { region in
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            VStack(alignment: .leading) {
                                Text("Weak Region Detected")
                                    .font(.headline)
                                Text(region.reasons.map { $0.rawValue }.joined(separator: ", "))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
            }
            
            Spacer()
            
            Text("Would you like to capture more detail to improve this area?")
                .font(.subheadline)
                .multilineTextAlignment(.center)
            
            Button(action: onAddDetail) {
                Text("Add More Detail")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Button(action: onContinue) {
                Text("Continue Anyway")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.3))
                    .foregroundColor(.primary)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}
