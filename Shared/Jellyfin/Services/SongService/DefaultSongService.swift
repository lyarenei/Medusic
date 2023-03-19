import Defaults
import JellyfinAPI

final class DefaultSongService: SongService {
    private let client: JellyfinClient

    init(client: JellyfinClient) {
        self.client = client
    }

    private func fetchSongs(
        for albumId: String? = nil,
        sortBy: [String]? = nil
    ) async throws -> [Song] {
        var requestParameters = JellyfinAPI.Paths.GetItemsParameters(
            userID: Defaults[.userId],
            isRecursive: true,
            includeItemTypes: [.audio],
            sortBy: sortBy
        )

        if let id = albumId {
            requestParameters.parentID = id
        }

        let request = JellyfinAPI.Paths.getItems(parameters: requestParameters)
        let response = try await client.send(request)
        return response.value.items!.map { Song(from: $0) }
    }

    // TODO: Add pagination.
    func getSongs() async throws -> [Song] {
        let remoteSongs = try await self.fetchSongs(
            for: nil,
            sortBy: ["Album", "indexNumber"]
        )

        return remoteSongs
    }

    // TODO: Add pagination.
    func getSongs(for albumId: String) async throws -> [Song] {
        let remoteSongs = try await self.fetchSongs(
            for: albumId,
            sortBy: ["indexNumber"]
        )

        return remoteSongs
    }

    func toggleFavorite(songId: String) async throws -> Bool {
        let request = JellyfinAPI.Paths.markFavoriteItem(
            userID: Defaults[.userId],
            itemID: songId
        )

        let response = try await client.send(request)
        if let code = response.statusCode {
            return code <= 400
        }

        return false
    }
}
