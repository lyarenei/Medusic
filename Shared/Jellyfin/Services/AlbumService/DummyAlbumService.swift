import Foundation
import Combine
import JellyfinAPI

final class DummyAlbumService: AlbumService {
    private let albums: [Album]

    init(albums: [Album]) {
        self.albums = albums
    }

    func getAlbums(for userId: String) -> AnyPublisher<[Album], AlbumFetchError> {
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
}
