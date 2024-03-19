import Foundation

protocol ArtistService {
    func getArtists(pageSize: Int?, offset: Int?) async throws -> [Artist]
    func getArtistById(_ id: String) async throws -> Artist
}
