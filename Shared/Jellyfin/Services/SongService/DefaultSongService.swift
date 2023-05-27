import Defaults
import JellyfinAPI

final class DefaultSongService: SongService {
    private let client: JellyfinClient

    init(client: JellyfinClient) {
        self.client = client
    }

    private func fetchSongs(for albumId: String? = nil, sortBy: [String]? = nil) async throws -> [Song] {
        let requestParameters = JellyfinAPI.Paths.GetItemsParameters(
            userID: Defaults[.userId],
            isRecursive: true,
            parentID: albumId,
            fields: [
                .mediaSources,
                .path,
            ],
            includeItemTypes: [.audio],
            sortBy: sortBy
        )

        let request = JellyfinAPI.Paths.getItems(parameters: requestParameters)
        let response = try await client.send(request)
        guard let items = response.value.items else { throw SongServiceError.noData }
        return items.map(Song.init(from:))
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
