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

    func getAlbums(pageSize: Int? = nil, offset: Int? = nil) async throws -> [Album] {
        var params = requestParams()
        params.startIndex = offset
        params.limit = pageSize

        let request = JellyfinAPI.Paths.getItems(parameters: params)
        let response = try await client.send(request)

        guard let items = response.value.items else { throw ServiceError.invalidResult }
        return items.compactMap(Album.init(from:))
    }

    func getAlbumById(_ id: String) async throws -> Album {
        let requestParams = requestParams(itemIds: [id])
        let request = JellyfinAPI.Paths.getItems(parameters: requestParams)
        let response = try await client.send(request)

        guard let items = response.value.items else { throw ServiceError.notFound }
        guard items.isNotEmpty else { throw ServiceError.notFound }
        if items.count > 1 { throw ServiceError.invalidResult }
        guard let album = Album(from: items.first) else { throw ServiceError.invalidResult }
        return album
    }
}
