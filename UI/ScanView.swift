import SwiftUI
import ARKit

struct ScanView: View {
    @StateObject private var captureManager = VideoCaptureManager.shared
    @StateObject private var fusionEngine   = SensorFusionEngine.shared
    @StateObject private var reconManager   = ReconstructionManager.shared
    @StateObject private var arManager      = ARTrackingManager.shared

    @State private var navigateToProcessing = false
    @State private var guidanceText: String = "Point at object and press record"
    @AppStorage("developerMode") private var isDeveloperMode = false
    @State private var showDiagnostics = false
    @State private var aiResult = ObjectUnderstandingResult(objectType: "--", confidence: 0.0, parts: [])
    
    // UI Toggles
    @State private var showGrid = false
    @State private var autoFocus = true

    var body: some View {
        NavigationStack {
            ZStack {
                // ── Full-screen camera ──
                ARViewContainer().ignoresSafeArea()

                // ── Reticle / Focus points ──
                ReticleView()
                    .frame(width: 280, height: 180)
                    .opacity(captureManager.isCapturing ? 0.8 : 0.3)
                    .animation(.easeInOut(duration: 0.4), value: captureManager.isCapturing)
                
                // ── Screen bounds guides ──
                screenBoundsOverlay
                
                // ── Grid overlay ──
                if showGrid {
                    gridOverlay
                }

                VStack(spacing: 0) {
                    // ────────────────────────────────
                    // TOP HUD (Blackmagic Style)
                    // ────────────────────────────────
                    bmTopBar

                    Spacer()

                    // Developer diagnostics overlay
                    if showDiagnostics && isDeveloperMode {
                        HStack {
                            Spacer()
                            SensorDiagnosticsView()
                                .frame(maxWidth: 200)
                                .padding(.trailing, 16)
                        }
                    }

                    // ────────────────────────────────
                    // BOTTOM TOOLBAR
                    // ────────────────────────────────
                    VStack(spacing: 20) {
                        GuidanceToast(
                            title: arManager.isLowLight ? "Low Light Detected" : guidanceText,
                            subtitle: arManager.isLowLight 
                                ? "Turn on lights for a better 3D scan." 
                                : (captureManager.isCapturing ? "Walk slowly around the object" : "Keep the object centred in the frame"),
                            isWarning: arManager.isLowLight
                        )
                        .padding(.horizontal, 16)
                        .padding(.top, 24)

                        bmBottomBar
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)
                    }
                    .background(
                        LinearGradient(
                            colors: [.black.opacity(0.0), .black.opacity(0.85)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            .onAppear {
                captureManager.startCamera()
                HardwareCapabilityManager.shared.detectCapabilities()
            }
            .navigationDestination(isPresented: $navigateToProcessing) {
                ProcessingView(onComplete: { _ in
                    navigateToProcessing = false
                    fusionEngine.state = .ready
                    captureManager.capturedFramesCount = 0
                })
            }
        }
    }

    // MARK: - Blackmagic Style Top Bar

    private var bmTopBar: some View {
        VStack(spacing: 0) {
            // Status line (Timecode-esque)
            HStack {
                if captureManager.isCapturing {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .scaleEffect(1.2)
                        .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: captureManager.isCapturing)
                    Text("REC")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                } else {
                    Text("STBY")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.5))
                }
                Spacer()
                
                // Mock battery / storage
                HStack(spacing: 4) {
                    Image(systemName: "wifi").font(.system(size: 12))
                    Image(systemName: "battery.100").font(.system(size: 14)).foregroundColor(.green)
                }
                .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 12)
            
            // Parameters line
            HStack(spacing: 20) {
                bmParameter(title: "SENSOR", value: fusionEngine.pipeline == .liDARPro ? "LiDAR" : "CAM", isHighlighted: true)
                bmParameter(title: "FRAMES", value: "\(captureManager.capturedFramesCount)")
                bmParameter(title: "TRACK", value: trackingLabel, valueColor: trackingColor)
                
                // AI Object Detection (Mocked from local state)
                bmParameter(title: "AI DETECT", value: aiResult.objectType == "Scanning…" ? "--" : aiResult.objectType)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 14)
        }
        .background(Color.black.opacity(0.85))
    }

    private func bmParameter(title: String, value: String, valueColor: Color = .white, isHighlighted: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(isHighlighted ? .white : .gray)
                .padding(.horizontal, isHighlighted ? 4 : 0)
                .background(isHighlighted ? Color.blue : Color.clear)
                .cornerRadius(2)
                
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(valueColor)
        }
    }

    // MARK: - Bottom Toolbar

    private var bmBottomBar: some View {
        HStack {
            // Left Tools (Grid only)
            HStack(spacing: 24) {
                Button(action: { showGrid.toggle() }) {
                    Image(systemName: "grid")
                        .font(.system(size: 20))
                        .foregroundColor(showGrid ? .blue : .white)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Record Button
            Button(action: handleScanButton) {
                ZStack {
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 72, height: 72)
                    
                    if captureManager.isCapturing {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.red)
                            .frame(width: 28, height: 28)
                    } else {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 60, height: 60)
                    }
                }
            }
            
            // Right Tools (Focus / Diagnostics only)
            HStack(spacing: 24) {
                if isDeveloperMode {
                    Button(action: { showDiagnostics.toggle() }) {
                        Image(systemName: showDiagnostics ? "chart.bar.xaxis" : "chart.bar")
                            .font(.system(size: 20))
                            .foregroundColor(showDiagnostics ? .blue : .white)
                    }
                } else {
                     Button(action: { autoFocus.toggle() }) {
                         VStack(spacing: 2) {
                             Image(systemName: "viewfinder")
                                 .font(.system(size: 20))
                                 .foregroundColor(autoFocus ? .blue : .white)
                             Text(autoFocus ? "AF" : "MF")
                                 .font(.system(size: 8, weight: .bold))
                                 .foregroundColor(autoFocus ? .blue : .white)
                         }
                     }
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
    
    // MARK: - Overlays
    
    private var screenBoundsOverlay: some View {
        ZStack {
            // Safe area outlines like a camera viewfinder
            Rectangle()
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                .padding(20)
                
            // Crosshairs center
            Path { path in
                let size: CGFloat = 10
                path.move(to: CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY - size))
                path.addLine(to: CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY + size))
                path.move(to: CGPoint(x: UIScreen.main.bounds.midX - size, y: UIScreen.main.bounds.midY))
                path.addLine(to: CGPoint(x: UIScreen.main.bounds.midX + size, y: UIScreen.main.bounds.midY))
            }
            .stroke(Color.white.opacity(0.4), lineWidth: 1)
        }
        .allowsHitTesting(false)
    }
    
    private var gridOverlay: some View {
        GeometryReader { geo in
            Path { path in
                let w = geo.size.width
                let h = geo.size.height
                
                path.move(to: CGPoint(x: w / 3, y: 0))
                path.addLine(to: CGPoint(x: w / 3, y: h))
                
                path.move(to: CGPoint(x: 2 * w / 3, y: 0))
                path.addLine(to: CGPoint(x: 2 * w / 3, y: h))
                
                path.move(to: CGPoint(x: 0, y: h / 3))
                path.addLine(to: CGPoint(x: w, y: h / 3))
                
                path.move(to: CGPoint(x: 0, y: 2 * h / 3))
                path.addLine(to: CGPoint(x: w, y: 2 * h / 3))
            }
            .stroke(Color.white.opacity(0.2), lineWidth: 1)
        }
        .allowsHitTesting(false)
    }

    // MARK: - Actions

    private func handleScanButton() {
        if captureManager.isCapturing {
            captureManager.stopCapture()
            let frames = captureManager.exposedFrames
            let pipeline = fusionEngine.pipeline
            reconManager.beginScan()
            navigateToProcessing = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                reconManager.startReconstruction(with: frames, using: pipeline)
            }
        } else {
            fusionEngine.state = .capturing
            reconManager.beginScan()
            captureManager.startCapture()
            guidanceText = "Walk slowly around the object"
        }
    }

    // MARK: - Computed helpers

    private var trackingLabel: String {
        switch arManager.trackingState {
        case .normal:                          return "GOOD"
        case .limited(.initializing):         return "INIT"
        case .limited(.relocalizing):         return "RELOC"
        case .limited(.insufficientFeatures): return "LOW DTL"
        case .limited(.excessiveMotion):      return "FAST"
        case .notAvailable:                   return "N/A"
        default:                              return "LMTD"
        }
    }

    private var trackingColor: Color {
        switch arManager.trackingState {
        case .normal: return .white
        case .notAvailable: return .red
        default: return .orange
        }
    }
}

