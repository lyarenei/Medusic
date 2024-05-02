import Foundation

protocol ArtistService {
    func getArtists(pageSize: Int?, offset: Int?) async throws -> [ArtistDto]
    func getArtistById(_ id: String) async throws -> ArtistDto
}
