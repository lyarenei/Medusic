import Foundation

protocol SongService: ObservableObject {
    func getSongs(pageSize: Int?, offset: Int?) async throws -> [Song]
    func getSongsForAlbum(_ album: Album) async throws -> [Song]
    func getSongsForAlbum(id albumId: String) async throws -> [Song]
}
