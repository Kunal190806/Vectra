import SwiftUI
import simd

struct ScanDetailView: View {
    let weakRegion: WeakRegion
    let onComplete: () -> Void
    
    // In a full implementation, we'd have a VideoCaptureManager configured 
    // specifically to append to the existing ScanSession rather than overwrite it.
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all) // Camera preview placeholder
            
            VStack {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Targeted Capture")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.black.opacity(0.6))
                .cornerRadius(10)
                .padding(.top, 40)
                
                Spacer()
                
                // AR Guidance UI Overlay
                VStack(spacing: 10) {
                    Text("Move toward the highlighted region")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                    
                    Text(weakRegion.reasons.map { $0.rawValue }.joined(separator: ", "))
                        .foregroundColor(.orange)
                    
                    // Simple mock distance indicator
                    Text(String(format: "Distance: %.1fm", simd_length(weakRegion.center)))
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color.black.opacity(0.8))
                .cornerRadius(10)
                
                Spacer()
                
                Button(action: onComplete) {
                    Text("Finish Detail Capture")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
    }
}
