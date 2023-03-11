import Boutique
import Foundation
import JellyfinAPI

final class DefaultAlbumService: AlbumService {
    @Stored(in: .albums)
    private var albums: [Album]

    private let client: JellyfinClient

    init(client: JellyfinClient) {
        self.client = client
    }

    // TODO: Add pagination.
    func getAlbums(for userId: String) async throws -> [Album] {
        let requestParams = JellyfinAPI.Paths.GetItemsParameters(
            userID: userId,
            isRecursive: true,
            includeItemTypes: [.musicAlbum]
        )

        let request = JellyfinAPI.Paths.getItems(parameters: requestParams)

        do {
            var remoteAlbums: [Album] = []
            let response = try await client.send(request)
            remoteAlbums = response.value.items!.map { Album(from: $0) }
            try? await $albums.removeAll().insert(remoteAlbums).run()
            return remoteAlbums
        } catch {
            return await albums
        }
    }
}
