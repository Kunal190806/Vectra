import SwiftUI

struct TopStatusIndicator: View {
    var statusText: String = "SCANNING READY"
    var isReady: Bool = true
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(isReady ? Color.green : Color.orange)
                .frame(width: 8, height: 8)
            
            Text(statusText)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.6))
        )
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}
