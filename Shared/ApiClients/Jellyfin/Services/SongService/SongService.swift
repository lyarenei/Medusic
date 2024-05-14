import Foundation

protocol SongService: ObservableObject {
    func getSongs(pageSize: Int?, offset: Int?) async throws -> [SongDto]
    func getSongsForAlbum(_ album: AlbumDto) async throws -> [SongDto]
    func getSongsForAlbum(id albumId: String) async throws -> [SongDto]
}
