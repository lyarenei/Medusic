import Foundation
import Combine
import JellyfinAPI

final class MockAlbumService: AlbumService {
    func getAlbums(pageSize: Int? = nil, offset: Int? = nil) async throws -> [Album] {
        PreviewData.albums
    }

    func getAlbumById(_ id: String) async throws -> Album {
        // swiftlint:disable:next force_unwrapping
        PreviewData.albums.first { $0.id == id }!
    }
}
