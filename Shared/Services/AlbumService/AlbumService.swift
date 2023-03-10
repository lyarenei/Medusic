import Foundation

protocol AlbumService: ObservableObject {
    func getAlbums(for userId: String) async throws -> [Album]
}
