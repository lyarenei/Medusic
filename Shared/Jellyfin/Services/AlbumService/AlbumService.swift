import Foundation
import Combine

protocol AlbumService: ObservableObject {
    func getAlbums() -> AnyPublisher<[Album], AlbumFetchError>
    func getAlbum(by albumId: String) -> AnyPublisher<Album, AlbumFetchError>

    func simple_getAlbums() async throws -> [Album]
    func simple_getAlbum(by albumId: String) async throws -> Album
}

enum AlbumFetchError: Error {
    case invalid
    case itemNotFound
    case itemsNotFound
    case requestFailed(Error)
}
