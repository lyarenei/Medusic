import Defaults
import JellyfinAPI

final class DefaultSongService: SongService {
    private let client: JellyfinClient
    private let pageSize = 100

    init(client: JellyfinClient) {
        self.client = client
    }

    private func fetchSongs(for albumId: String? = nil, sortBy: [String]? = nil) async throws -> [Song] {
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
        if let items = response.value.items {
            return items.map { Song(from: $0) }
        }

        throw SongServiceError.noData
    }

    // TODO: Add pagination.
    func getSongs() async throws -> [Song] {
        try await fetchSongs(
            for: nil,
            sortBy: ["Album", "indexNumber"]
        )
    }

    // TODO: Add pagination.
    func getSongs(for albumId: String) async throws -> [Song] {
        try await fetchSongs(
            for: albumId,
            sortBy: ["indexNumber"]
        )
    }
}
