import Foundation

final class DummyImageService: ImageService {
    func getImage(for itemId: String) async throws -> Data {
        PlatformImage(named: "album1")!.pngData()!
    }

    func getImage(for itemId: String, size: CGSize) async throws -> Data {
        return try await self.getImage(for: itemId)
    }
}
