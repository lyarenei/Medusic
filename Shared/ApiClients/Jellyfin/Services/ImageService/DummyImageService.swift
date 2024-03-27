import Foundation

final class DummyImageService: ImageService {
    func getImage(for itemId: String) async throws -> Data {
        // swiftlint:disable:next force_unwrapping
        PlatformImage(named: "album1")!.pngData()!
    }

    func getImage(for itemId: String, size: CGSize) async throws -> Data {
        try await getImage(for: itemId)
    }
}
