import Foundation

protocol SongService: ObservableObject {
    func getSongs(pageSize: Int32?, offset: Int32?) async throws -> [Song]
    func getSongsForAlbum(_ album: Album) async throws -> [Song]
    func getSongsForAlbum(id albumId: String) async throws -> [Song]
}

extension SongService {
    func getSongs(pageSize: Int32? = nil, offset: Int32? = nil) async throws -> [Song] {
        try await getSongs(pageSize: pageSize, offset: pageSize)
    }
}
