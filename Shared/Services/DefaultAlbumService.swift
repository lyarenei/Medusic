import Foundation
import Boutique
import JellyfinAPI

final class DefaultAlbumService: AlbumService {
    @Stored(in: .albums)
    private var albums: [Album]

    private let client: JellyfinClient

    init(client: JellyfinClient) {
        self.client = client
    }

    // TODO: Add pagination.
    func getAlbums() async throws -> [Album] {
        do {
            var remoteAlbums: [Album] = []
            let params = JellyfinAPI.Paths.GetItemsParameters(
                userID: "0f0edfcf31d64740bd577afe8e94b752",
                isRecursive: true,
                includeItemTypes: [.musicAlbum]
            )

            let req = JellyfinAPI.Paths.getItems(parameters: params)
            let resp = try await client.send(req)
            remoteAlbums = resp.value.items!.map{Album(from: $0)}
            try? await $albums.removeAll().insert(remoteAlbums).run()
            return remoteAlbums
        } catch {
            return await albums
        }
    }
}
