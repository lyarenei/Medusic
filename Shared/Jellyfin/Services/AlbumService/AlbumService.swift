import Foundation
import Combine

protocol AlbumService: ObservableObject {
    func getAlbums() async throws -> [Album]
    func getAlbum(by albumId: String) async throws -> Album
}

enum AlbumFetchError: Error {
    case invalid
    case itemNotFound
    case itemsNotFound
    case requestFailed(Error)
}
