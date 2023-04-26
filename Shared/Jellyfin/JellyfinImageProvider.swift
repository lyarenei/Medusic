import Foundation
import Kingfisher

struct JellyfinImageDataProvider: ImageDataProvider {
    var cacheKey: String {
        itemId
    }

    private let itemId: String
    private let imageService: any ImageService
    private let imageSize: CGSize?

    init(itemId: String, imageService: any ImageService, imageSize: CGSize? = nil) {
        self.itemId = itemId
        self.imageService = imageService
        self.imageSize = imageSize
    }

    func data(handler: @escaping (Result<Data, Error>) -> Void) {
        Task {
            do {
                if let imageSize {
                    try handler(.success(await imageService.getImage(for: itemId, size: imageSize)))
                } else {
                    try handler(.success(await imageService.getImage(for: itemId)))
                }
            } catch {
                handler(.failure(error))
            }
        }
    }
}
