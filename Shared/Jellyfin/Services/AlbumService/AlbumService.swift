import Foundation
import Combine

protocol AlbumService: ObservableObject {
    func getAlbums(for userId: String) -> AnyPublisher<[Album], AlbumFetchError>
    func getAlbum(by albumId: String) -> AnyPublisher<Album, AlbumFetchError>
}

enum AlbumFetchError: Error {
    case invalid
    case itemsNotFound
    case requestFailed(Error)
}
