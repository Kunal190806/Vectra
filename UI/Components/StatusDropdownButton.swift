import SwiftUI

struct StatusDropdownButton: View {
    var action: () -> Void
    var isOpen: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "cube.box")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                
                Text("OPEN STATUS")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                
                Image(systemName: isOpen ? "chevron.up" : "chevron.down")
                    .font(.system(size: 10))
                    .foregroundColor(.green)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(white: 0.1).opacity(0.9))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
