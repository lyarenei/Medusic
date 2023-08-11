import Boutique
import Defaults
import Foundation
import JellyfinAPI

final class DefaultAlbumService: AlbumService {
    @Stored(in: .albums)
    private var albums: [Album]

    private let client: JellyfinClient

    init(client: JellyfinClient) {
        self.client = client
    }

    private func requestParams(itemIds: [String]? = nil) -> JellyfinAPI.Paths.GetItemsParameters {
        JellyfinAPI.Paths.GetItemsParameters(
            userID: Defaults[.userId],
            isRecursive: true,
            fields: [.dateCreated],
            includeItemTypes: [.musicAlbum],
            ids: itemIds
        )
    }

    func getAlbums() async throws -> [Album] {
        let request = JellyfinAPI.Paths.getItems(parameters: requestParams())
        let response = try await client.send(request)

        guard let items = response.value.items else { throw AlbumServiceError.invalidResult }
        return items.compactMap(Album.init(from:))
    }

    func getAlbum(by albumId: String) async throws -> Album {
        let requestParams = requestParams(itemIds: [albumId])
        let request = JellyfinAPI.Paths.getItems(parameters: requestParams)
        let response = try await client.send(request)

        guard let items = response.value.items else { throw AlbumServiceError.notFound }
        guard items.isNotEmpty else { throw AlbumServiceError.notFound }
        if items.count > 1 { throw AlbumServiceError.invalidResult }
        guard let album = Album(from: items.first) else { throw AlbumServiceError.invalidResult }
        return album
    }
}
