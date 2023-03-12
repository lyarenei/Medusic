import SwiftUI
import SFSafeSymbols
import Kingfisher
import JellyfinAPI

@main
struct JellyMusicApp: App {
    private let api: API

    init() {
        @AppStorage(SettingsKeys.serverUrl)
        var serverUrl = ""

        @AppStorage(SettingsKeys.username)
        var username = ""

        @AppStorage(SettingsKeys.userId)
        var userId = ""

        var connectUrl = URL(string: "http://localhost:8096")!
        if let validServerUrl = URL(string: serverUrl) {
            connectUrl = validServerUrl
        }

        let jellyfinClient = JellyfinClient(configuration: .init(
            url: connectUrl,
            client: "JellyMusic",
            deviceName: UIDevice.current.model,
            deviceID: UIDevice.current.identifierForVendor?.uuidString ?? "missing_id",
            version: "0.0"))

        Task {
            do {
                let resp = try await jellyfinClient.signIn(username: username , password: "aaa")
                if let uid = resp.user?.id {
                    userId = uid
                }
            } catch {
                print("Could not log in to Jellyfin server: \(error)")
            }
        }

        //api = .preview
        api = API(
            albumService: DefaultAlbumService(client: jellyfinClient),
            songService: DefaultSongService(client: jellyfinClient),
            imageService: DefaultImageService(client: jellyfinClient),
            systemService: DefaultSystemService(client: jellyfinClient)
        )

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
        }

        #if os(macOS)
        Settings {
            MacSettingsView()
        }
        #endif
    }
}
