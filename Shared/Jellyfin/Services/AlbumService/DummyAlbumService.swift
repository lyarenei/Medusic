import Foundation
import Combine
import JellyfinAPI

final class DummyAlbumService: AlbumService {
    private let albums: [Album]

    init(albums: [Album]) {
        self.albums = albums
    }

    func simple_getAlbums() async throws -> [Album] {
        albums
    }

    func simple_getAlbum(by albumId: String) async throws -> Album {
        let album = albums.first { $0.uuid == albumId }

        guard let album else { throw AlbumFetchError.itemNotFound }
        return album
    }
}
