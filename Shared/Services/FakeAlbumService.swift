import Foundation
import JellyfinAPI

final class FakeAlbumService: AlbumService {
    private let albums: [Album]

    init(albums: [Album]) {
        self.albums = albums
    }

    func getAlbums() async throws -> [Album] {
        albums
    }
}
