import SwiftUI
import SFSafeSymbols
import Kingfisher
import JellyfinAPI
import Defaults

@main
struct JellyMusicApp: App {
    private var api: ApiClient

    init() {
        // Memory image never expires.
        Kingfisher.ImageCache.default.memoryStorage.config.expiration = .never

        // Disk image expires in a week.
        Kingfisher.ImageCache.default.diskStorage.config.expiration = .days(7)

        // Limit disk cache size to 1 GB.
        Kingfisher.ImageCache.default.diskStorage.config.sizeLimit = 1000 * 1024 * 1024

        api = ApiClient()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                #if os(iOS)
                HomeScreen()
                #endif

                #if os(macOS)
                MacHomeScreen()
                #endif
            }
            .environment(\.api, api)
        }

        #if os(macOS)
        Settings {
            MacSettingsView()
        }
        #endif
    }
}
