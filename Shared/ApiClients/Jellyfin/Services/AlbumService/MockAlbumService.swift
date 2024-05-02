import Combine
import Foundation
import JellyfinAPI

#if DEBUG
// swiftlint:disable all

final class MockAlbumService: AlbumService {
    func getAlbums(pageSize: Int? = nil, offset: Int? = nil) async throws -> [AlbumDto] {
        PreviewData.albums
    }

    func getAlbumById(_ id: String) async throws -> AlbumDto {
        // swiftlint:disable:next force_unwrapping
        PreviewData.albums.first { $0.id == id }!
    }

    func getAlbums(for artist: ArtistDto, pageSize: Int? = nil, offset: Int? = nil) async throws -> [AlbumDto] {
        PreviewData.albums.filtered(by: .artistId(artist.id))
    }
}

// swiftlint:enable all
#endif
