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
            Group {
                #if os(iOS)
                HomeScreen()
                #endif

                #if os(macOS)
                MacHomeScreen()
                #endif
            }
            .backport.task {
                // TODO: would be good to show error to user
                do {
                    try await AlbumRepository.shared.refresh()
                    try await SongRepository.shared.refresh()
                } catch {
                    debugPrint("Failed to refresh library: \(error)")
                }
            }
        }

        #if os(macOS)
        Settings {
            MacSettingsView()
        }
        #endif
    }
}
