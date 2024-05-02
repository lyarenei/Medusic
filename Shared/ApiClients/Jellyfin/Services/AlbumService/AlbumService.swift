import Foundation

protocol AlbumService: ObservableObject {
    func getAlbums(pageSize: Int?, offset: Int?) async throws -> [AlbumDto]
    func getAlbumById(_ id: String) async throws -> AlbumDto
    func getAlbums(for artist: ArtistDto, pageSize: Int?, offset: Int?) async throws -> [AlbumDto]
}
