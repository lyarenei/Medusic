import Boutique
import Foundation
import JellyfinAPI
import Combine

final class DefaultAlbumService: AlbumService {
    @MainActor
    @Stored(in: .albums)
    private var albums: [Album]

    private let client: JellyfinClient

    init(client: JellyfinClient) {
        self.client = client
    }

    // TODO: Add pagination.
    func getAlbums(for userId: String) -> AnyPublisher<[Album], AlbumFetchError> {
        let cacheSubject = PassthroughSubject<[Album], AlbumFetchError>()

        let remotePublisher = Future { [weak self] completion in
            guard let self else { return completion(.failure(AlbumFetchError.invalid)) }
            Task {
                do {
                    let requestParams = JellyfinAPI.Paths.GetItemsParameters(
                        userID: userId,
                        isRecursive: true,
                        includeItemTypes: [.musicAlbum]
                    )
                    let request = JellyfinAPI.Paths.getItems(parameters: requestParams)
                    let response = try await self.client.send(request)
                    guard let items = response.value.items else { throw AlbumFetchError.itemsNotFound }
                    completion(.success(items.map(Album.init(from:))))
                } catch let error as AlbumFetchError {
                    completion(.failure(error))
                } catch {
                    completion(.failure(.requestFailed(error)))
                }
            }
        }
        .handleEvents(receiveOutput: { albums in
            Task {
                try? await self.$albums.removeAll().insert(albums).run()
            }
        })
        .eraseToAnyPublisher()

        let cachePublisher = cacheSubject
            // If the cache is later than remote data, don't send it at all.
            .prefix(untilOutputFrom: remotePublisher)
            .eraseToAnyPublisher()

        return Publishers.Merge(cachePublisher, remotePublisher).eraseToAnyPublisher()
    }
}
