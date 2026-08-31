import SwiftUI

@main
struct VectraApp: App {
    @AppStorage("developerMode") private var isDeveloperMode = false
    
    init() {
        Logger.shared.log("VECTRA Application Launched", category: .performance)
    }
    
    var body: some Scene {
        WindowGroup {
            TabView {
                ScanView()
                    .tabItem {
                        Image(systemName: "camera.viewfinder")
                        Text("Scan")
                    }
                
                LibraryView()
                    .tabItem {
                        Image(systemName: "square.stack.3d.down.right.fill")
                        Text("Library")
                    }
                
                SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
            }
        }
    }
}
