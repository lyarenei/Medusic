import Foundation

final class MockMediaService: MediaService {
    func stream(item id: String, bitrate: Int32?) async throws -> Data {
        throw MediaServiceError.invalid
    }

    func new_downloadItem(id: String, destination: URL) async throws {
        throw MediaServiceError.invalid
    }
}
