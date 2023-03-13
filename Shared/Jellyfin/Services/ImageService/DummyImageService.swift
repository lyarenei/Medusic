import Foundation

final class DummyImageService: ImageService {
    func getImage(for itemId: String) async throws -> Data {
        PlatformImage(named: "album1")!.pngData()!
    }
}
