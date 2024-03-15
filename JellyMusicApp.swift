import Defaults
import Kingfisher
import SwiftUI

@main
struct JellyMusicApp: App {
    @Default(.appColorScheme)
    private var appColorScheme

    init() {
        // Memory image never expires.
        Kingfisher.ImageCache.default.memoryStorage.config.expiration = .never

        // Disk image expires in a week.
        Kingfisher.ImageCache.default.diskStorage.config.expiration = .days(7)

        // Limit disk cache size to 1 GB.
        Kingfisher.ImageCache.default.diskStorage.config.sizeLimit = 1000 * 1024 * 1024

        // Set values for the Jellyfin API client
        Defaults[.deviceName] = UIDevice.current.model
        Defaults[.deviceId] = UIDevice.current.identifierForVendor?.uuidString ?? "no_device_id_available"
    }

    var body: some Scene {
        WindowGroup {
            MainScreen()
                .preferredColorScheme(appColorScheme.asColorScheme)
                .environmentObject(SongRepository(store: .songs))
                .environmentObject(NavigationRouter())
                .environmentObject(
                    LibraryRepository(
                        artistStore: .artists,
                        albumStore: .albums,
                        songStore: .songs,
                        apiClient: .shared
                    )
                )
        }
    }
}
