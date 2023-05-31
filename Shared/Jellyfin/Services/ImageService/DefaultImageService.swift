import Boutique
import Foundation
import JellyfinAPI

final class DefaultImageService: ImageService {
    private let client: JellyfinClient

    init(client: JellyfinClient) {
        self.client = client
    }

    func getImage(for itemId: String) async throws -> Data {
        let request = JellyfinAPI.Paths.getItemImage(
            itemID: itemId,
            imageType: "Primary"
        )

        return try await client.send(request).value
    }

    func getImage(for itemId: String, size: CGSize) async throws -> Data {
        let parameters = JellyfinAPI.Paths.GetItemImageParameters(
            width: Int32(round(size.width)),
            height: Int32(round(size.height))
        )

        let request = JellyfinAPI.Paths.getItemImage(
            itemID: itemId,
            imageType: "Primary",
            parameters: parameters
        )

        return try await client.send(request).value
    }
}
