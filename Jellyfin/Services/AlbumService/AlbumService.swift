import Foundation

protocol AlbumService: ObservableObject {
    func getAlbums(pageSize: Int32?, offset: Int32?) async throws -> [Album]
    func getAlbumById(_ id: String) async throws -> Album
}
