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
        let remoteAlbums = try await apiClient.services.albumService.getAlbums()
        try await $albums.removeAll().insert(remoteAlbums).run()
    }

    func refresh(albumId: String) async throws {
        try await apiClient.performAuth()
        let remoteAlbum = try await apiClient.services.albumService.getAlbum(by: albumId)
        try await $albums.insert(remoteAlbum)
    }

    /// Get all albums.
    func getAlbums() async -> [Album] {
        await $albums.items
    }

    /// Get a specific album form store by its ID.
    func getAlbum(by albumId: String) async -> Album? {
        await $albums.items.first { $0.uuid == albumId }
    }

    /// Get all favorite albums.
    func getFavorite() async -> [Album] {
        await $albums.items.favorite
    }

    /// Set/reset specified album favorite flag.
    func setFavorite(albumId: String, isFavorite: Bool) async throws {
        if var album = await getAlbum(by: albumId) {
            try await apiClient.services.mediaService.setFavorite(itemId: albumId, isFavorite: isFavorite)
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
