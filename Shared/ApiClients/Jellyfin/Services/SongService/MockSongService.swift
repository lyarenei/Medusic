import Foundation
import JellyfinAPI

#if DEBUG
// swiftlint:disable all

final class MockSongService: SongService {
    func getSongs(pageSize: Int? = nil, offset: Int? = nil) async throws -> [SongDto] {
        PreviewData.songs
    }

    func getSongsForAlbum(_ album: AlbumDto) async throws -> [SongDto] {
        PreviewData.songs.filtered(by: .albumId(album.id))
    }

    func getSongsForAlbum(id albumId: String) async throws -> [SongDto] {
        PreviewData.songs.filtered(by: .albumId(albumId))
    }
}

// swiftlint:enable all
#endif
