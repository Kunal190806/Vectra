import SwiftUI

struct BottomControlPanel: View {
    @Binding var isCapturing: Bool
    var action: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            
            // Left Card: Coverage & Tracking
            VStack(alignment: .leading, spacing: 16) {
                // Coverage
                HStack(spacing: 12) {
                    Image(systemName: "circle.dotted")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Coverage")
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                        Text("72%")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.green)
                    }
                }
                
                // Tracking
                HStack(spacing: 12) {
                    Image(systemName: "scope")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Tracking")
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                        Text("Good")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.green)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(white: 0.1).opacity(0.9)))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.1), lineWidth: 1))
            
            // Center Button
            Button(action: action) {
                ZStack {
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .fill(Color.black)
                        .frame(width: 74, height: 74)
                    
                    Circle()
                        .fill(isCapturing ? Color.red.opacity(0.6) : Color(red: 1.0, green: 0.2, blue: 0.2))
                        .frame(width: 68, height: 68)
                    
                    Text(isCapturing ? "STOP\nSCAN" : "START\nSCAN")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Right Card: Tip
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "lightbulb")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("TIP")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.green)
                    Text("Walk around the object slowly for best results.")
                        .font(.system(size: 10))
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(white: 0.1).opacity(0.9)))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.1), lineWidth: 1))
            
        }
        .padding(.horizontal, 16)
    }
}
