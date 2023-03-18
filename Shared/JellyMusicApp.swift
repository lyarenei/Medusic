import Defaults
import JellyfinAPI
import Kingfisher
import SFSafeSymbols
import SwiftUI

@main
struct JellyMusicApp: App {
    private var api = ApiClient()

    init() {
        // Memory image never expires.
        Kingfisher.ImageCache.default.memoryStorage.config.expiration = .never

        // Disk image expires in a week.
        Kingfisher.ImageCache.default.diskStorage.config.expiration = .days(7)

        // Limit disk cache size to 1 GB.
        Kingfisher.ImageCache.default.diskStorage.config.sizeLimit = 1000 * 1024 * 1024

        // TODO: if starting in default mode, auth is needed, but where - needs to display error in future

        let songsController = SongsController(store: .songs)

        // TODO: refresh all data stores on start - also would be good to show error to user
        Task {
            do {
                try await songsController.refresh()
            } catch {
                print("Failed to refresh data", error)
            }
        }
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
