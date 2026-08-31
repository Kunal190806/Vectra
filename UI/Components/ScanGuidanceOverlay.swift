import SwiftUI

struct ScanGuidanceOverlay: View {
    @ObservedObject var planner: ScanPlanner
    @ObservedObject var coverage: CoverageAnalyzer
    @ObservedObject var estimator: SpatialExtentEstimator
    
    var body: some View {
        VStack {
            HStack {
                Text(String(format: "Coverage: %.0f%%", coverage.coveragePercentage * 100))
                    .font(.headline)
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                
                Spacer()
                
                if let size = estimator.currentSize {
                    Text(String(format: "Size: %.1fm", size.width))
                        .font(.subheadline)
                        .padding()
                        .background(Color.black.opacity(0.6))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.top, 50)
            .padding(.horizontal)
            
            Spacer()
            
            // Basic text guidance based on next uncaptured target
            if let nextTarget = planner.targetViewpoints.first(where: { !$0.isCaptured }) {
                Text("Move to next target position")
                    .font(.title2)
                    .bold()
                    .padding()
                    .background(Color.blue.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.bottom, 20)
            } else if planner.targetViewpoints.count > 0 {
                Text("Scan Complete!")
                    .font(.title)
                    .bold()
                    .padding()
                    .background(Color.green.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.bottom, 20)
            } else {
                Text("Analyzing Scene...")
                    .font(.title3)
                    .padding()
                    .background(Color.orange.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.bottom, 20)
            }
        }
    }
}
