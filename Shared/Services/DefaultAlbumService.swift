import Foundation
import Boutique
import JellyfinAPI

final class DefaultAlbumService: AlbumService {
    @Stored(in: .albums)
    private var albums: [AlbumInfo]

    private let client: JellyfinClient

    init(client: JellyfinClient) {
        self.client = client
    }

    // TODO: Add pagination.
    func getAlbums() async throws -> [AlbumInfo] {
        do {
            // TODO: Get [AlbumInfo] from backend.
            let remoteAlbums: [AlbumInfo] = []
            try? await $albums.removeAll().insert(remoteAlbums).run()
            return remoteAlbums
        } catch {
            return await albums
        }
    }
}
