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
            .onAppear { Task(priority: .medium) {
                // TODO: to be removed once every fetch will do auth itself
                do {
                    let isOk = try await api.performAuth()
                    guard isOk else { print("Login failed"); return }
                } catch {
                    print("Login failed", error)
                }

                let songsController = SongsRepository(store: .songs)

                // TODO: refresh all data stores on start - also would be good to show error to user
                do {
                    try await songsController.refresh()
                } catch {
                    print("Failed to refresh data", error)
                }
            }}
        }

        #if os(macOS)
        Settings {
            MacSettingsView()
        }
        #endif
    }
}
