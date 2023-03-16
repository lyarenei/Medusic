import Foundation
import Combine

protocol AlbumService: ObservableObject {
    func getAlbums() -> AnyPublisher<[Album], AlbumFetchError>
    func getAlbum(by albumId: String) -> AnyPublisher<Album, AlbumFetchError>
}

enum AlbumFetchError: Error {
    case invalid
    case itemNotFound
    case itemsNotFound
    case requestFailed(Error)
}
