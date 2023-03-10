import Foundation
import Boutique
import JellyfinAPI

final class DefaultImageService: ImageService {
    private let client: JellyfinClient

    init(client: JellyfinClient) {
        self.client = client
    }

    func getImage(for itemId: String) async throws -> Optional<Data> {
        do {
            let req = JellyfinAPI.Paths.getItemImage(itemID: itemId, imageType: "Primary")
            let resp = try await client.send(req)
            return try resp.value.toData()
        } catch {
            return nil
        }
    }
}
