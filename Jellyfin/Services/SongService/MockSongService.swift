import Foundation
import JellyfinAPI

final class MockSongService: SongService {
    func getSongs(pageSize: Int32? = nil, offset: Int32? = nil) async throws -> [Song] {
        PreviewData.songs
    }

    func getSongsForAlbum(_ album: Album) async throws -> [Song] {
        PreviewData.songs.filtered(by: .albumId(album.id))
    }

    func getSongsForAlbum(id albumId: String) async throws -> [Song] {
        PreviewData.songs.filtered(by: .albumId(albumId))
    }
}
