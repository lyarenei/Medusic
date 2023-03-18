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
    func refresh() async throws {
        let _ = try await self.api.performAuth()
        let remoteSongs = try await self.api.services.songService.getSongs()
        try await self.$songs.removeAll().insert(remoteSongs).run()
    }

    /// Get all songs.
    /// If an album ID is specified, return only the songs for that specified Album.
    func getSongs(ofAlbum albumId: String? = nil) async -> [Song] {
        if let albumId = albumId {
            return await self.$songs.items.getByAlbum(id: albumId)
        }

        return await self.$songs.items
    }

    /// Get a specific song form store by specified ID.
    func getSong(by songId: String) async -> Song? {
        return await self.$songs.items.first {
            $0.uuid == songId
        }
    }
}
