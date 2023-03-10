import Foundation
import JellyfinAPI

final class DummyAlbumService: AlbumService {
    private let albums: [Album]

    init(albums: [Album]) {
        self.albums = albums
    }

    func getAlbums(for userId: String) async throws -> [Album] {
        albums
    }
}
