import Defaults
import JellyfinAPI
import Kingfisher
import SFSafeSymbols
import SwiftUI

@main
struct JellyMusicApp: App {
    private var api = ApiClient()
    private var albumRepo = AlbumRepository(store: .albums)
    private var songRepo = SongRepository(store: .songs)
    private var mediaRepo = MediaRepository(store: .downloadedMedia)

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
            .environment(\.albumRepo, albumRepo)
            .environment(\.songRepo, songRepo)
            .environment(\.mediaRepo, mediaRepo)
            .onAppear { Task(priority: .medium) {
                let albumRepo = AlbumRepository(store: .albums)
                let songRepo = SongRepository(store: .songs)

                // TODO: would be good to show error to user
                do {
                    try await albumRepo.refresh()
                    try await songRepo.refresh()
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
