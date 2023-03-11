import Boutique
import Foundation
import JellyfinAPI

final class DefaultSongService: SongService {
    @Stored(in: .songs)
    private var songs: [Song]

    private let client: JellyfinClient

    init(client: JellyfinClient) {
        self.client = client
    }

    private func fetchSongs(
        with userId: String,
        for albumId: String?,
        sortBy: [String]
    ) async throws -> [Song] {
        var requestParameters = JellyfinAPI.Paths.GetItemsParameters(
            userID: userId,
            isRecursive: true,
            includeItemTypes: [.recording],
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
    func getSongs(with userId: String) async throws -> [Song] {
        do {
            let remoteSongs = try await self.fetchSongs(
                with: userId,
                for: nil,
                sortBy: ["parentId", "indexNumber"]
            )
            try? await $songs.removeAll().insert(remoteSongs).run()
            return remoteSongs
        } catch {
            return await songs
        }
    }

    // TODO: Add pagination.
    func getSongs(with userId: String, for albumId: String) async throws -> [Song] {
        do {
            let remoteSongs = try await self.fetchSongs(
                with: userId,
                for: albumId,
                sortBy: ["indexNumber"]
            )
            try? await $songs.removeAll().insert(remoteSongs).run()
            return remoteSongs
        } catch {
            return await songs
        }
    }
}
