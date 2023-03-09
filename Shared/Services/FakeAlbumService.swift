import Foundation
import JellyfinAPI

final class FakeAlbumService: AlbumService {
    private let albums: [AlbumInfo]

    init(albums: [AlbumInfo]) {
        self.albums = albums
    }

    func getAlbums() async throws -> [AlbumInfo] {
        albums
    }
}
