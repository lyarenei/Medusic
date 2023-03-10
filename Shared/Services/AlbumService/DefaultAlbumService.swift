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
    func getAlbums(for userId: String) async throws -> [Album] {
        do {
            var albums: [Album] = []
            let requestParams = JellyfinAPI.Paths.GetItemsParameters(
                userID: userId,
                isRecursive: true,
                includeItemTypes: [.musicAlbum]
            )

            let request = JellyfinAPI.Paths.getItems(parameters: requestParams)
            let response = try await client.send(request)
            albums = response.value.items!.map{Album(from: $0)}
            try? await $albums.removeAll().insert(albums).run()
            return albums
        } catch {
            return await albums
        }
    }
}
