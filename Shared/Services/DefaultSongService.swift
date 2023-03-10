import Foundation
import Boutique
import JellyfinAPI

final class DefaultSongService: SongService {
    @Stored(in: .songs)
    private var songs: [Song]

    private let client: JellyfinClient

    init(client: JellyfinClient) {
        self.client = client
    }

    // TODO: Add pagination.
    func getSongs() async throws -> [Song] {
        do {
            var remoteSongs: [Song] = []
            let params = JellyfinAPI.Paths.GetItemsParameters(
                userID: "0f0edfcf31d64740bd577afe8e94b752",
                isRecursive: true,
                includeItemTypes: [.recording],
                sortBy: ["indexNumber"]
            )

            let req = JellyfinAPI.Paths.getItems(parameters: params)
            let resp = try await client.send(req)
            remoteSongs = resp.value.items!.map{Song(from: $0)}
            try? await $songs.removeAll().insert(remoteSongs).run()
            return remoteSongs
        } catch {
            return await songs
        }
    }

    // TODO: Add pagination.
    func getSongs(for albumId: String) async throws -> [Song] {
        do {
            var remoteSongs: [Song] = []
            let params = JellyfinAPI.Paths.GetItemsParameters(
                userID: "0f0edfcf31d64740bd577afe8e94b752",
                isRecursive: true,
                parentID: albumId,
                includeItemTypes: [.recording],
                sortBy: ["indexNumber"]
            )

            let req = JellyfinAPI.Paths.getItems(parameters: params)
            let resp = try await client.send(req)
            remoteSongs = resp.value.items!.map{Song(from: $0)}
            try? await $songs.removeAll().insert(remoteSongs).run()
            return remoteSongs
        } catch {
            return await songs
        }
    }
}
