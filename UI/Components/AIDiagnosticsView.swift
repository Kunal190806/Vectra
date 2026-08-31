import SwiftUI

struct AIDiagnosticsView: View {
    let understandingResult: ObjectUnderstandingResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("AI STATUS (Developer Mode)")
                .font(.caption)
                .bold()
                .foregroundColor(.yellow)
            
            HStack {
                Text("Object:")
                Spacer()
                Text(understandingResult.objectType)
                    .bold()
            }
            
            HStack {
                Text("Confidence:")
                Spacer()
                Text(String(format: "%.0f%%", understandingResult.confidence * 100))
                    .bold()
            }
            
            HStack {
                Text("Semantic Regions:")
                Spacer()
                Text("\(understandingResult.parts.count)")
                    .bold()
            }
            
            HStack {
                Text("Next Best View:")
                Spacer()
                Text("Calculated") // Stub
                    .foregroundColor(.green)
                    .bold()
            }
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .foregroundColor(.white)
        .cornerRadius(10)
        .font(.system(.footnote, design: .monospaced))
    }
}
