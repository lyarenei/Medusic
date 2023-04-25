import Boutique
import Foundation

final class SongRepository: ObservableObject {
    static let shared = SongRepository(store: .songs)

    @Stored
    var songs: [Song]

    let apiClient: ApiClient

    init(
        store: Store<Song>,
        apiClient: ApiClient = .shared
    ) {
        self._songs = Stored(in: store)
        self.apiClient = apiClient
    }

    /// Refresh the store data with data from service.
    func refresh(for albumId: String? = nil) async throws {
        try await apiClient.performAuth()
        if let album = albumId {
            let remoteSongs = try await apiClient.services.songService.getSongs(for: album)
            let localSongs = await $songs.items.filterByAlbum(id: album)
            try await $songs.remove(localSongs).insert(remoteSongs).run()
        } else {
            let remoteSongs = try await apiClient.services.songService.getSongs()
            try await $songs.removeAll().insert(remoteSongs).run()
        }
    }

    /// Get all songs.
    /// If an album ID is specified, return only the songs for that specified Album.
    func getSongs(ofAlbum albumId: String? = nil) async -> [Song] {
        if let albumId {
            return await $songs.items.filterByAlbum(id: albumId)
        }

        return await $songs.items
    }

    /// Get a specific song form store by specified ID.
    func getSong(by songId: String) async -> Song? {
        await $songs.items.first { $0.uuid == songId }
    }

    /// Set/reset specified song favorite flag.
    func setFavorite(songId: String, isFavorite: Bool) async throws {
        if var song = await getSong(by: songId) {
            try await apiClient.services.mediaService.setFavorite(itemId: songId, isFavorite: isFavorite)
            song.isFavorite = isFavorite
            try await $songs.insert(song)
        } else {
            throw SongRepositoryError.notFound
        }
    }
}

enum SongRepositoryError: Error {
    case notFound
}
