import Kingfisher
import SwiftUI
import SwiftUIBackports

@main
struct JellyMusicApp: App {
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
            MainScreen()
                .environmentObject(AlbumRepository(store: .albums))
                .environmentObject(SongRepository(store: .songs))
        }
    }
}
