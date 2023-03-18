import Foundation
import Combine
import JellyfinAPI

final class DummyAlbumService: AlbumService {
    private let albums: [Album]

    init(albums: [Album]) {
        self.albums = albums
    }

    func getAlbums() -> AnyPublisher<[Album], AlbumFetchError> {
        Just(albums)
            .setFailureType(to: AlbumFetchError.self)
            .eraseToAnyPublisher()
    }

    func getAlbum(by albumId: String) -> AnyPublisher<Album, AlbumFetchError> {
        // We are working with hardcoded values here, ! is fine
        Just(albums.first { $0.uuid == albumId }!)
            .setFailureType(to: AlbumFetchError.self)
            .eraseToAnyPublisher()
    }

    func simple_getAlbums() async throws -> [Album] {
        return self.albums
    }

    func simple_getAlbum(by albumId: String) async throws -> Album {
        let album = self.albums.first { $0.uuid == albumId }

        guard let album = album else { throw AlbumFetchError.itemNotFound }
        return album
    }
}
