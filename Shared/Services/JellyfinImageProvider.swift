import Foundation
import Kingfisher

struct JellyfinImageDataProvider: ImageDataProvider {
    var cacheKey: String {
        itemId
    }

    private let itemId: String
    private let imageService: any ImageService

    init(itemId: String, imageService: any ImageService) {
        self.itemId = itemId
        self.imageService = imageService
    }

    func data(handler: @escaping (Result<Data, Error>) -> Void) {
        Task {
            do {
                handler(.success(try await imageService.getImage(for: itemId)))
            } catch {
                handler(.failure(error))
            }
        }
    }
}
