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
}
