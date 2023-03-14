import Foundation
import JellyfinAPI

final class DummySongService: SongService {
    private var songs: [Song]

    init(songs: [Song]) {
        self.songs = songs
    }

    func getSongs() async throws -> [Song] {
        return self.songs
    }

    func getSongs(for albumId: String) async throws -> [Song] {
        return self.songs.filter { $0.parentId == albumId }
    }

    func toggleFavorite(songId: String) async throws -> Bool {
        if let idx = self.songs.firstIndex(where: { $0.uuid == songId }) {
            self.songs[idx].isFavorite.toggle()
            return true
        }

        return false
    }
}
