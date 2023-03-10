import Foundation
import Boutique
import JellyfinAPI

final class DefaultImageService: ImageService {
    private let client: JellyfinClient

    init(client: JellyfinClient) {
        self.client = client
    }

    func getImage(for itemId: String) async throws -> Data {
        let request = JellyfinAPI.Paths.getItemImage(itemID: itemId, imageType: "Primary")
        return try await client.send(request).value
    }
}
