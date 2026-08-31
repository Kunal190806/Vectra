import SwiftUI

struct GuidanceToast: View {
    var title: String = "Move closer"
    var subtitle: String = "Keep the object in the frame"
    var isWarning: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(isWarning ? .orange : .green)
            Text(subtitle)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.75))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.black.opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isWarning ? Color.orange.opacity(0.4) : Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}
