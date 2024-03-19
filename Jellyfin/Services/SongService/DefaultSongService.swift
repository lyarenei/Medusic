import Defaults
import JellyfinAPI

final class DefaultSongService: SongService {
    private let client: JellyfinClient

    init(client: JellyfinClient) {
        self.client = client
    }

    func getSongs(pageSize: Int? = nil, offset: Int? = nil) async throws -> [Song] {
        try await fetchSongs(limit: pageSize, startIndex: offset)
    }

    func getSongsForAlbum(_ album: Album) async throws -> [Song] {
        try await fetchSongs(for: album.id)
    }

    func getSongsForAlbum(id albumId: String) async throws -> [Song] {
        try await fetchSongs(for: albumId)
    }

    private func fetchSongs(
        for albumId: String? = nil,
        limit: Int? = nil,
        startIndex: Int? = nil
    ) async throws -> [Song] {
        var params = JellyfinAPI.Paths.GetItemsParameters()
        params.userID = Defaults[.userId]
        params.isRecursive = true
        params.parentID = albumId
        params.fields = [.mediaSources, .path]
        params.includeItemTypes = [.audio]
        params.limit = limit
        params.startIndex = startIndex

        let request = JellyfinAPI.Paths.getItems(parameters: params)
        let response = try await client.send(request)
        guard let items = response.value.items else { throw ServiceError.invalidResult }
        return items.compactMap(Song.init(from:))
    }
}
