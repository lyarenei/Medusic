import Boutique
import Foundation

final class AlbumRepository: ObservableObject {
    static let shared = AlbumRepository(store: .albums)

    @Stored
    var albums: [Album]

    let apiClient: ApiClient

    init(
        store: Store<Album>,
        apiClient: ApiClient = .shared
    ) {
        self._albums = Stored(in: store)
        self.apiClient = apiClient
    }

    /// Refresh the store data with data from service.
    func refresh() async throws {
        try await apiClient.performAuth()
        let remoteAlbums = try await self.apiClient.services.albumService.simple_getAlbums()
        try await self.$albums.removeAll().insert(remoteAlbums).run()
    }

    func refresh(albumId: String) async throws {
        try await apiClient.performAuth()
        let remoteAlbum = try await self.apiClient.services.albumService.simple_getAlbum(by: albumId)
        try await $albums.insert(remoteAlbum)
    }

    /// Get all albums.
    func getAlbums() async -> [Album] {
        return await self.$albums.items
    }

    /// Get a specific album form store by its ID.
    func getAlbum(by albumId: String) async -> Album? {
        return await self.$albums.items.first { $0.uuid == albumId }
    }

    /// Get all favorite albums.
    func getFavorite() async -> [Album] {
        return await self.$albums.items.filter { $0.isFavorite }
    }

    /// Set/reset specified album favorite flag.
    func setFavorite(albumId: String, isFavorite: Bool) async throws {
        if var album = await getAlbum(by: albumId) {
            // TODO: API call
            album.isFavorite = isFavorite
            try await $albums.insert(album)
        } else {
            throw AlbumRepositoryError.notFound
        }
    }
}

enum AlbumRepositoryError: Error {
    case notFound
}
