import Foundation

#if DEBUG
// swiftlint:disable all

final class MockArtistService: ArtistService {
    func getArtists(pageSize: Int?, offset: Int?) async throws -> [ArtistDto] {
        PreviewData.artists
    }

    func getArtistById(_ id: String) async throws -> ArtistDto {
        // swiftlint:disable:next force_unwrapping
        PreviewData.artists.first { $0.id == id }!
    }
}

// swiftlint:enable all
#endif
