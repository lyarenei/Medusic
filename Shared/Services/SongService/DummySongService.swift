import Foundation
import JellyfinAPI

final class DummySongService: SongService {
    private let songs: [Song]

    init(songs: [Song]) {
        self.songs = songs
    }

    func getSongs() async throws -> [Song] {
        return self.songs
    }

    // TODO: song needs parent ID field
    func getSongs(for albumId: String) async throws -> [Song] {
        return self.songs
    }
}
