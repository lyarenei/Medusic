import Foundation
import Combine
import JellyfinAPI

final class DummyAlbumService: AlbumService {
    func getAlbums() async throws -> [Album] {
        PreviewData.albums
    }

    func getAlbum(by albumId: String) async throws -> Album {
        // swiftlint:disable:next force_unwrapping
        PreviewData.albums.first { $0.id == albumId }!
    }
}
