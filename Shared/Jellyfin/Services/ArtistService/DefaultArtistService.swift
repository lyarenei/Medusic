import Foundation
import JellyfinAPI

final class DefaultArtistService: ArtistService {
    private let client: JellyfinClient

    init(client: JellyfinClient) {
        self.client = client
    }

    func getArtists(pageSize: Int32? = nil, offset: Int32? = nil) async throws -> [Artist] {
        let params = JellyfinAPI.Paths.GetAlbumArtistsParameters(
            startIndex: offset,
            limit: pageSize,
            fields: nil
        )

        let request = JellyfinAPI.Paths.getAlbumArtists(parameters: params)
        let response = try await client.send(request)

        guard let items = response.value.items else { throw ArtistServiceError.invalidResult }
        return items.compactMap(Artist.init(from:))
    }

    func getArtist(byId: String) async throws -> Artist {
        let params = JellyfinAPI.Paths.GetItemsParameters(ids: [byId])
        let request = JellyfinAPI.Paths.getItems(parameters: params)
        let response = try await client.send(request)

        guard let items = response.value.items else { throw ArtistServiceError.notFound }
        guard items.isNotEmpty else { throw ArtistServiceError.notFound }
        if items.count > 1 { throw ArtistServiceError.tooManyResults }
        guard let artist = Artist(from: items.first) else { throw ArtistServiceError.invalidResult }
        return artist
    }

    enum ArtistServiceError: Error {
        case invalidResult
        case notFound
        case tooManyResults
    }
}
