import SwiftUI

@main
struct JellyMusicApp: App {
    var body: some Scene {
        WindowGroup {
#if os(iOS)
            HomeView()
#endif
            
#if os(macOS)
            ContentView()
#endif
        }
        
#if os(macOS)
        Settings {
            MacSettingsView()
        }
#endif
    }
}
