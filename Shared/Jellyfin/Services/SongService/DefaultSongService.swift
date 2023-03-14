import Boutique
import Foundation
import JellyfinAPI

final class DefaultSongService: SongService {
    @Stored(in: .songs)
    private var songs: [Song]

    private let client: JellyfinClient

    private var userId = "0f0edfcf31d64740bd577afe8e94b752"

    init(client: JellyfinClient) {
        self.client = client
    }

    private func fetchSongs(for albumId: String?, sortBy: [String]
    ) async throws -> [Song] {
        var requestParameters = JellyfinAPI.Paths.GetItemsParameters(
            userID: self.userId,
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
        do {
            let remoteSongs = try await self.fetchSongs(
                for: nil,
                sortBy: ["Album", "indexNumber"]
            )
            try? await $songs.removeAll().insert(remoteSongs).run()
            return remoteSongs
        } catch {
            return await songs
        }
    }

    // TODO: Add pagination.
    func getSongs(for albumId: String) async throws -> [Song] {
        do {
            let remoteSongs = try await self.fetchSongs(
                for: albumId,
                sortBy: ["indexNumber"]
            )
            try? await $songs.removeAll().insert(remoteSongs).run()
            return remoteSongs
        } catch {
            return await songs
        }
    }

    func toggleFavorite(songId: String) async throws -> Bool {
        let request = JellyfinAPI.Paths.markFavoriteItem(userID: userId, itemID: songId)
        let response = try await client.send(request)
        if let code = response.statusCode {
            return code <= 400
        }

        return false
    }
}
