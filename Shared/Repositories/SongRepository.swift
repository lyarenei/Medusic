import Boutique
import Foundation

final class SongRepository: ObservableObject {
    static let shared = SongRepository(store: .songs)

    @Stored
    var songs: [Song]

    private let api: ApiClient

    init(store: Store<Song>) {
        self._songs = Stored(in: store)
        self.api = ApiClient()
    }

    /// Refresh the store data with data from service.
    func refresh(for albumId: String? = nil) async throws {
        let _ = try await self.api.performAuth()
        if let album = albumId {
            let remoteSongs = try await self.api.services.songService.getSongs(for: album)
            let localSongs = await self.$songs.items.filterByAlbum(id: album)
            try await self.$songs.remove(localSongs).insert(remoteSongs).run()
        } else {
            let remoteSongs = try await self.api.services.songService.getSongs()
            try await self.$songs.removeAll().insert(remoteSongs).run()
        }
    }

    /// Get all songs.
    /// If an album ID is specified, return only the songs for that specified Album.
    func getSongs(ofAlbum albumId: String? = nil) async -> [Song] {
        if let albumId = albumId {
            return await self.$songs.items.filterByAlbum(id: albumId)
        }

        return await self.$songs.items
    }

    /// Get a specific song form store by specified ID.
    func getSong(by songId: String) async -> Song? {
        return await self.$songs.items.first {
            $0.uuid == songId
        }
    }

    /// Set/reset specified song favorite flag.
    func setFavorite(songId: String, isFavorite: Bool) async throws {
        if var song = await getSong(by: songId) {
            // TODO: API call
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
