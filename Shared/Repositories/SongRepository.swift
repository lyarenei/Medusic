import Boutique
import Foundation

final class SongRepository: ObservableObject {
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

    func setDownloaded(itemId: String, _ isDownloaded: Bool = true) async throws {
        if var item = await self.getSong(by: itemId) {
            item.isDownloaded = isDownloaded
            try await self.$songs.remove(item).insert(item).run()
            return
        }

        throw SongRepositoryError.notFound
    }
}

enum SongRepositoryError: Error {
    case notFound
}
