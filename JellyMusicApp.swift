import Defaults
import Kingfisher
import OSLog
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
                .task { await authorizeClient() }
                .environmentObject(SongRepository(store: .songs))
                .environmentObject(NavigationRouter())
                .environmentObject(ApiClient.shared)
                .environmentObject(LibraryRepository.shared)
        }
    }

    private func authorizeClient() async {
        guard isConfigured() else { return }
        do {
            try await ApiClient.shared.performAuth()
            Logger.library.debug("API client successfully authorized")
        } catch {
            Logger.library.warning("Server authentication failed: \(error.localizedDescription)")
            Alerts.info("Failed to log in to server")
        }
    }

    private func isConfigured() -> Bool {
        Defaults[.serverUrl].isNotEmpty && Defaults[.username].isNotEmpty
    }
}
