import Defaults
import Foundation
import JellyfinAPI
import OSLog
import SimpleKeychain
import SwiftUI

final class ApiClient: ObservableObject {
    static let shared = ApiClient()

    #if DEBUG

    @Published
    private(set) var services: ApiServices = .preview

    init(previewEnabled: Bool = Defaults[.previewMode]) {
        setMode(previewEnabled)
    }

    private func setMode(_ isPreview: Bool) {
        if isPreview {
            usePreviewMode()
            return
        }

        useDefaultMode()
    }

    /// Use preview mode of the client with mocked data. Does not persist any changes.
    func usePreviewMode() {
        services = .preview
        Logger.jellyfin.debug("Using preview mode for API client")
    }

    #else

    @Published
    private(set) var services: ApiServices

    init(previewEnabled: Bool = false) {
        // swiftlint:disable:next force_unwrapping
        var serverUrl = URL(string: "http://localhost:8096")!
        if let configuredServerUrl = URL(string: Defaults[.serverUrl]) {
            serverUrl = configuredServerUrl
        }

        let jellyfinClient = JellyfinClient(configuration: .init(
            url: serverUrl,
            client: "JellyMusic",
            deviceName: Defaults[.deviceName],
            deviceID: Defaults[.deviceId],
            version: "0.0"
        ))

        self.services = ApiServices(
            albumService: DefaultAlbumService(client: jellyfinClient),
            songService: DefaultSongService(client: jellyfinClient),
            imageService: DefaultImageService(client: jellyfinClient),
            systemService: DefaultSystemService(client: jellyfinClient),
            mediaService: DefaultMediaService(client: jellyfinClient),
            artistService: DefaultArtistService(client: jellyfinClient)
        )
    }

    private func setMode(_ isPreview: Bool) {
        useDefaultMode()
    }

    #endif

    func getServerStatus() async -> ServerStatus {
        do {
            let isOk = try await services.systemService.ping()
            return isOk ? .online : .offline
        } catch {
            return .unknown
        }
    }

    /// Use default mode of the client which connects to the configured server.
    func useDefaultMode() {
        // swiftlint:disable:next force_unwrapping
        var serverUrl = URL(string: "http://localhost:8096")!
        if let configuredServerUrl = URL(string: Defaults[.serverUrl]) {
            serverUrl = configuredServerUrl
        }

        let jellyfinClient = JellyfinClient(configuration: .init(
            url: serverUrl,
            client: "JellyMusic",
            deviceName: Defaults[.deviceName],
            deviceID: Defaults[.deviceId],
            version: "0.0"
        ))

        services = ApiServices(
            albumService: DefaultAlbumService(client: jellyfinClient),
            songService: DefaultSongService(client: jellyfinClient),
            imageService: DefaultImageService(client: jellyfinClient),
            systemService: DefaultSystemService(client: jellyfinClient),
            mediaService: DefaultMediaService(client: jellyfinClient),
            artistService: DefaultArtistService(client: jellyfinClient)
        )

        Logger.jellyfin.debug("Using default mode for API client")
    }

    /// Authorize against Jellyfin server with stored credentials.
    func performAuth() async throws {
        Defaults[.userId] = .empty
        let keychain = SimpleKeychain()
        let password = try? keychain.string(forKey: "password")
        guard let userPass = password else {
            throw ApiClientError.noPassword
        }

        let userId = try await services.systemService.logIn(
            username: Defaults[.username],
            password: userPass
        )

        if userId.isEmpty {
            throw ApiClientError.loginFailed
        }

        Defaults[.userId] = userId
    }

    func getImageDataProvider(itemId: String) -> JellyfinImageDataProvider {
        JellyfinImageDataProvider(
            itemId: itemId,
            imageService: services.imageService
        )
    }

    var isAuthorized: Bool {
        services.systemService.isAuthorized
    }

    var authHeader: String {
        services.systemService.authorizationHeader
    }
}

struct ApiServices {
    let albumService: any AlbumService
    let songService: any SongService
    let imageService: any ImageService
    let systemService: any SystemService
    let mediaService: any MediaService
    let artistService: any ArtistService
}

#if DEBUG
// swiftlint:disable all

extension ApiServices {
    static var preview: ApiServices {
        ApiServices(
            albumService: MockAlbumService(),
            songService: MockSongService(),
            imageService: DummyImageService(),
            systemService: MockSystemService(),
            mediaService: MockMediaService(),
            artistService: MockArtistService()
        )
    }
}

// swiftlint:enable all
#endif

enum ApiClientError: Error {
    case noPassword
    case loginFailed
}
