import SwiftUI

struct ReticleView: View {
    var body: some View {
        GeometryReader { geometry in
            let cornerLength: CGFloat = 30
            let cornerWidth: CGFloat = 2
            
            Path { path in
                // Top Left
                path.move(to: CGPoint(x: 0, y: cornerLength))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: cornerLength, y: 0))
                
                // Top Right
                path.move(to: CGPoint(x: geometry.size.width - cornerLength, y: 0))
                path.addLine(to: CGPoint(x: geometry.size.width, y: 0))
                path.addLine(to: CGPoint(x: geometry.size.width, y: cornerLength))
                
                // Bottom Right
                path.move(to: CGPoint(x: geometry.size.width, y: geometry.size.height - cornerLength))
                path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                path.addLine(to: CGPoint(x: geometry.size.width - cornerLength, y: geometry.size.height))
                
                // Bottom Left
                path.move(to: CGPoint(x: cornerLength, y: geometry.size.height))
                path.addLine(to: CGPoint(x: 0, y: geometry.size.height))
                path.addLine(to: CGPoint(x: 0, y: geometry.size.height - cornerLength))
            }
            .stroke(Color.white, lineWidth: cornerWidth)
            .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
        }
    }
}
