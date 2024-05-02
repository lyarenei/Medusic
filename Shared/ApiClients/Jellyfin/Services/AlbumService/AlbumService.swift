import Foundation

protocol AlbumService: ObservableObject {
    func getAlbums(pageSize: Int?, offset: Int?) async throws -> [Album]
    func getAlbumById(_ id: String) async throws -> Album
    func getAlbums(for artist: ArtistDto, pageSize: Int?, offset: Int?) async throws -> [Album]
}
