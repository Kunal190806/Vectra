import SwiftUI

struct SettingsView: View {
    // App Storage for settings persistence
    @AppStorage("scanQuality") private var scanQuality: String = "High"
    @AppStorage("useLiDAR") private var useLiDAR: Bool = true
    @AppStorage("audioFeedback") private var audioFeedback: Bool = true
    @AppStorage("autoExport") private var autoExport: Bool = false
    @AppStorage("developerMode") private var isDeveloperMode: Bool = false
    
    let scanQualities = ["Standard", "High", "Ultra (RAW)"]

    var body: some View {
        NavigationStack {
            Form {
                // ── Scan Preferences ──
                Section {
                    Picker("Scan Quality", selection: $scanQuality) {
                        ForEach(scanQualities, id: \.self) {
                            Text($0)
                        }
                    }
                    
                    Toggle("Use LiDAR Sensor", isOn: $useLiDAR)
                    Toggle("Audio Feedback", isOn: $audioFeedback)
                } header: {
                    Text("Capture")
                } footer: {
                    Text("Ultra quality requires significantly more processing time and storage space.")
                }
                
                // ── Workflow ──
                Section {
                    Toggle("Auto-Export on Completion", isOn: $autoExport)
                } header: {
                    Text("Workflow")
                }
                
                // ── Advanced / Dev ──
                Section {
                    Toggle("Developer Mode", isOn: $isDeveloperMode)
                        .tint(.red)
                    
                    if isDeveloperMode {
                        NavigationLink("Debug Logs") {
                            Text("Debug Logs View (Not Implemented)")
                        }
                        Button("Reset AR Session") {
                            // Stub for AR reset
                        }
                        .foregroundColor(.red)
                    }
                } header: {
                    Text("Advanced")
                }
                
                // ── About ──
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0 (Build 42)")
                            .foregroundColor(.gray)
                    }
                    
                    Button("Clear Scan Cache") {
                        // Action to clear temp files
                    }
                    .foregroundColor(.red)
                } header: {
                    Text("About VECTRA")
                }
            }
            .navigationTitle("Settings")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }
}
