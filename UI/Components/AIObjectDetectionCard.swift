import SwiftUI

struct AIObjectDetectionCard: View {
    var objectName: String = "Vehicle"
    var confidence: Int = 85
    
    var systemIconName: String {
        switch objectName.lowercased() {
        case "vehicle", "car": return "car.fill"
        case "furniture", "chair": return "chair.lounge.fill"
        case "person": return "person.fill"
        case "device", "electronics": return "desktopcomputer"
        default: return "cube.box.fill"
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon Background
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue)
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: systemIconName)
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                )
            
            // Text Content
            VStack(alignment: .leading, spacing: 2) {
                Text("Object Detected")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.gray)
                
                Text(objectName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                HStack(spacing: 4) {
                    Text("Confidence")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.gray)
                    Text("\(confidence)%")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.green)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(white: 0.1).opacity(0.9))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}
