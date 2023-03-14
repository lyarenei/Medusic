import Boutique
import Foundation
import JellyfinAPI
import Combine

final class DefaultAlbumService: AlbumService {
    @Stored(in: .albums)
    private var albums: [Album]

    private let client: JellyfinClient

    private let userId = "0f0edfcf31d64740bd577afe8e94b752"

    init(client: JellyfinClient) {
        self.client = client
    }

    private func fetchAll() -> Future<[Album], AlbumFetchError> {
        return Future<[Album], AlbumFetchError> { [weak self] completion in
            guard let self else { return completion(.failure(AlbumFetchError.invalid)) }
            Task {
                do {
                    let requestParams = JellyfinAPI.Paths.GetItemsParameters(
                        userID: self.userId,
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
    }

    // TODO: Add pagination.
    func getAlbums(for userId: String) -> AnyPublisher<[Album], AlbumFetchError> {
        let remotePublisher = self.fetchAll()
        .handleEvents(receiveOutput: { [weak self] albums in
            guard let self else { return }
            Task {
                try? await self.$albums.removeAll().insert(albums).run()
            }
        })
        .eraseToAnyPublisher()

        let cachePublisher = Future<[Album], AlbumFetchError> { [weak self] completion in
            guard let self else { return completion(.failure(AlbumFetchError.invalid)) }
            Task {
                completion(.success(await self.albums))
            }
        }
        // If the cache is later than remote data, don't send it at all.
        .prefix(untilOutputFrom: remotePublisher)
        .eraseToAnyPublisher()

        return Publishers.Merge(cachePublisher, remotePublisher).eraseToAnyPublisher()
    }
}
