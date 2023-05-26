import Foundation
import JellyfinAPI

final class DummySongService: SongService {
    private var songs: [Song]

    init(songs: [Song]) {
        self.songs = songs
    }

    func getSongs() async throws -> [Song] {
        songs
    }

    func getSongs(for albumId: String) async throws -> [Song] {
        songs.filter { $0.parentId == albumId }
    }

    func toggleFavorite(songId: String) async throws -> Bool {
        if let idx = songs.firstIndex(where: { $0.uuid == songId }) {
            songs[idx].isFavorite.toggle()
            return true
        }

        return false
    }
}
