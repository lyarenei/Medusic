import Defaults
import Kingfisher
import OSLog
import SwiftUI

@main
struct MedusicApp: App {
    @Default(.appColorScheme)
    private var appColorScheme

    init() {
        // Memory image never expires.
        Kingfisher.ImageCache.default.memoryStorage.config.expiration = .never

        // Disk image expires in a month.
        Kingfisher.ImageCache.default.diskStorage.config.expiration = .days(30)

        // Limit disk cache size to 3 GB.
        Kingfisher.ImageCache.default.diskStorage.config.sizeLimit = 3000 * 1024 * 1024

        // Set values for the Jellyfin API client
        Defaults[.deviceName] = UIDevice.current.model
        Defaults[.deviceId] = UIDevice.current.identifierForVendor?.uuidString ?? "no_device_id_available"
    }

    var body: some Scene {
        WindowGroup {
            IPadMainScreen()
                .preferredColorScheme(appColorScheme.asColorScheme)
                .task { await authorizeClient() }
                .environmentObject(MusicPlayer.shared)
                .environmentObject(ApiClient.shared)
                .environmentObject(LibraryRepository.shared)
                .environmentObject(FileRepository.shared)
                .environmentObject(Downloader.shared)
                .modelContainer(for: [Artist.self, Album.self, Song.self])
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
