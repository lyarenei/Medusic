import Foundation
import JellyfinAPI

final class MockSongService: SongService {
    func getSongs(pageSize: Int? = nil, offset: Int? = nil) async throws -> [Song] {
        PreviewData.songs
    }

    func getSongsForAlbum(_ album: Album) async throws -> [Song] {
        PreviewData.songs.filtered(by: .albumId(album.id))
    }

    func getSongsForAlbum(id albumId: String) async throws -> [Song] {
        PreviewData.songs.filtered(by: .albumId(albumId))
    }
}
