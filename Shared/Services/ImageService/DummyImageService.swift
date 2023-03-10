import Foundation

final class DummyImageService: ImageService {
    func getImage(for itemId: String) async throws -> Optional<Data> {
        return nil
    }
}
