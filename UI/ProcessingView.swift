import SwiftUI

struct ProcessingView: View {
    @StateObject private var manager = ReconstructionManager.shared
    @Environment(\.dismiss) private var dismiss

    // Callback when finished so ScanView can navigate to library
    var onComplete: ((URL) -> Void)? = nil

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(red: 0.04, green: 0.04, blue: 0.10),
                         Color(red: 0.08, green: 0.08, blue: 0.18)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Icon
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 120, height: 120)
                    Circle()
                        .trim(from: 0, to: manager.progress)
                        .stroke(
                            AngularGradient(
                                colors: [Color(red: 0.3, green: 0.5, blue: 1.0),
                                         Color(red: 0.5, green: 0.3, blue: 1.0)],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 5, lineCap: .round)
                        )
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.4), value: manager.progress)

                    Image(systemName: phaseIcon)
                        .font(.system(size: 40, weight: .light))
                        .foregroundColor(.white)
                }

                VStack(spacing: 12) {
                    Text("VECTRA")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(red: 0.4, green: 0.5, blue: 1.0))
                        .tracking(4)

                    Text(manager.phase.rawValue)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .animation(.easeInOut, value: manager.phase.rawValue)

                    Text("\(Int(manager.progress * 100))%")
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .animation(.easeInOut(duration: 0.3), value: manager.progress)
                }

                // Progress bar
                VStack(spacing: 8) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(LinearGradient(
                                    colors: [Color(red: 0.3, green: 0.5, blue: 1.0),
                                             Color(red: 0.5, green: 0.3, blue: 1.0)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .frame(width: geo.size.width * manager.progress, height: 6)
                                .animation(.easeInOut(duration: 0.4), value: manager.progress)
                        }
                    }
                    .frame(height: 6)
                    .padding(.horizontal, 40)

                    // Phase steps
                    HStack(spacing: 4) {
                        ForEach(["Prep", "Reconstruct", "Save"], id: \.self) { step in
                            let active = stepActive(step)
                            Text(step)
                                .font(.system(size: 10, weight: active ? .bold : .regular))
                                .foregroundColor(active ? Color(red: 0.4, green: 0.6, blue: 1.0) : .gray)
                            if step != "Save" {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 20, height: 1)
                            }
                        }
                    }
                }

                // Error state
                if manager.phase == .failed, let msg = manager.errorMessage {
                    VStack(spacing: 12) {
                        Text("Reconstruction failed")
                            .font(.headline)
                            .foregroundColor(.red)
                        Text(msg)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        Button("Go Back") { dismiss() }
                            .padding(.horizontal, 32)
                            .padding(.vertical, 12)
                            .background(Color.red.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }

                Spacer()
            }
        }
        .onChange(of: manager.phase) { _, newPhase in
            if newPhase == .done, let url = manager.finishedModelURL {
                onComplete?(url)
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert("Not Enough Information", isPresented: $manager.requiresUserDecision) {
            Button("Rescan (Cancel)", role: .cancel) {
                manager.cancelReconstruction()
            }
            Button("Proceed Anyway") {
                manager.resumeReconstruction()
            }
        } message: {
            Text("This scan doesn't have enough frames (info) for a high-quality 3D model. Do you want to rescan it or try reconstructing it anyway?")
        }
    }

    private var phaseIcon: String {
        switch manager.phase {
        case .idle, .preparing:    return "cube.transparent"
        case .cloudZipping:        return "doc.zipper"
        case .cloudUpload:         return "icloud.and.arrow.up"
        case .cloudProcess:        return "server.rack"
        case .cloudDownload:       return "icloud.and.arrow.down"
        case .processing:          return "cpu"
        case .saving:              return "arrow.down.circle"
        case .done:                return "checkmark.circle"
        case .failed:              return "xmark.circle"
        }
    }

    private func stepActive(_ step: String) -> Bool {
        switch step {
        case "Prep":        return manager.phase == .preparing || manager.phase == .cloudZipping
        case "Reconstruct": return manager.phase == .processing || manager.phase == .cloudUpload || manager.phase == .cloudProcess || manager.phase == .cloudDownload
        case "Save":        return manager.phase == .saving || manager.phase == .done
        default:            return false
        }
    }
}
