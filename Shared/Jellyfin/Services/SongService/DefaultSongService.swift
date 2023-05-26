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
            fields: [
                .mediaSources,
                .path,
            ],
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
        let remoteSongs = try await fetchSongs(
            for: nil,
            sortBy: ["Album", "indexNumber"]
        )

        return remoteSongs
    }

    // TODO: Add pagination.
    func getSongs(for albumId: String) async throws -> [Song] {
        let remoteSongs = try await fetchSongs(
            for: albumId,
            sortBy: ["indexNumber"]
        )

        return remoteSongs
    }
}
