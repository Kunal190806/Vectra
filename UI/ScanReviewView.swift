import SwiftUI

struct ScanReviewView: View {
    let coveragePercentage: Float
    
    var body: some View {
        VStack(spacing: 20) {
            Text("SCAN REVIEW")
                .font(.largeTitle)
                .bold()
                
            VStack(alignment: .leading, spacing: 10) {
                Text(String(format: "Coverage: %.0f%%", coveragePercentage * 100))
                Text("Tracking: Excellent")
                Text("Image Quality: Good")
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Potential improvements:")
                    .font(.headline)
                
                if coveragePercentage < 1.0 {
                    Text("⚠️ Missing some target viewpoints")
                        .foregroundColor(.orange)
                } else {
                    Text("✅ Full coverage achieved")
                        .foregroundColor(.green)
                }
            }
            .padding()
            
            Spacer()
            
            Button(action: {
                // Action to improve
            }) {
                Text("Improve Areas")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Button(action: {
                // Action to continue to reconstruction
            }) {
                Text("Continue to Reconstruction")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}
