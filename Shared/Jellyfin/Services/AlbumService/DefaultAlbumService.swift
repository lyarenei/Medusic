import Boutique
import Combine
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
        return JellyfinAPI.Paths.GetItemsParameters(
            userID: Defaults[.userId],
            isRecursive: true,
            fields: [.dateCreated],
            includeItemTypes: [.musicAlbum],
            ids: itemIds
        )
    }

    private func fetchAll() -> Future<[Album], AlbumFetchError> {
        return Future<[Album], AlbumFetchError> { [weak self] completion in
            guard let self else { return completion(.failure(AlbumFetchError.invalid)) }
            Task {
                do {
                    let request = JellyfinAPI.Paths.getItems(parameters: self.requestParams())
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

    private func fetchOne(by albumId: String) -> Future<Album, AlbumFetchError> {
        return Future<Album, AlbumFetchError> { [weak self] completion in
            guard let self else { return completion(.failure(AlbumFetchError.invalid)) }
            Task {
                do {
                    let requestParams = self.requestParams(itemIds: [albumId])
                    let request = JellyfinAPI.Paths.getItems(parameters: requestParams)
                    let response = try await self.client.send(request)
                    guard let items = response.value.items else { throw AlbumFetchError.itemNotFound }
                    completion(.success(Album(from: items[0])))
                } catch let error as AlbumFetchError {
                    completion(.failure(error))
                } catch {
                    completion(.failure(.requestFailed(error)))
                }
            }
        }
    }

    // TODO: Add pagination.
    func getAlbums() -> AnyPublisher<[Album], AlbumFetchError> {
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

    func getAlbum(by albumId: String) -> AnyPublisher<Album, AlbumFetchError> {
        let remotePublisher = self.fetchOne(by: albumId)
            .handleEvents(receiveOutput: { [weak self] album in
                guard let self else { return }
                Task {
                    try? await self.$albums.remove(album).insert(album).run()
                }
            })
            .eraseToAnyPublisher()

        let cachePublisher = Future<Album, AlbumFetchError> { [weak self] completion in
            guard let self else { return completion(.failure(AlbumFetchError.invalid)) }
            Task {
                if let album = await self.albums.getById(albumId) {
                    return completion(.success(album))
                }

                return completion(.failure(AlbumFetchError.itemNotFound))
            }
        }
        // If the cache is later than remote data, don't send it at all.
        .prefix(untilOutputFrom: remotePublisher)
        .eraseToAnyPublisher()

        return Publishers.Merge(cachePublisher, remotePublisher).eraseToAnyPublisher()
    }

    func simple_getAlbums() async throws -> [Album] {
        let request = JellyfinAPI.Paths.getItems(parameters: self.requestParams())
        let response = try await self.client.send(request)
        guard let items = response.value.items else { throw AlbumFetchError.itemsNotFound }
        return items.map(Album.init(from:))
    }

    func simple_getAlbum(by albumId: String) async throws -> Album {
        let requestParams = self.requestParams(itemIds: [albumId])
        let request = JellyfinAPI.Paths.getItems(parameters: requestParams)
        let response = try await self.client.send(request)
        guard let items = response.value.items else { throw AlbumFetchError.itemNotFound }
        return Album(from: items[0])
    }
}
