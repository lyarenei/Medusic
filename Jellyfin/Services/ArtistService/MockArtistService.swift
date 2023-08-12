import Foundation

final class MockArtistService: ArtistService {
    func getArtists(pageSize: Int32?, offset: Int32?) async throws -> [Artist] {
        PreviewData.artists
    }

    func getArtistById(_ id: String) async throws -> Artist {
        // swiftlint:disable:next force_unwrapping
        PreviewData.artists.first { $0.id == id }!
    }
}
