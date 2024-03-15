import Foundation

protocol ArtistService {
    func getArtists(pageSize: Int32?, offset: Int32?) async throws -> [Artist]
    func getArtistById(_ id: String) async throws -> Artist
}
