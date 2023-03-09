import SwiftUI
import SFSafeSymbols
import Kingfisher
import JellyfinAPI

@main
struct JellyMusicApp: App {
    private let api: API

    init() {
        // TODO
        let jellyfinClient = JellyfinClient(configuration: .init(url: URL(string: "www.google.com")!, client: "", deviceName: "", deviceID: "", version: ""))

        let albumService = DefaultAlbumService(client: jellyfinClient)

        api = .preview // API(albumService: albumService)

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
                HomeView()
                #endif

                #if os(macOS)
                ContentView()
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
