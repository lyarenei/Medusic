import Foundation

protocol AlbumService: ObservableObject {
    func getAlbums() async throws -> [Album]
}
