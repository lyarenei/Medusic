import Foundation

final class MockMediaService: MediaService {
    func download(item id: String) async throws -> Data {
        throw MediaServiceError.invalid
    }

    func stream(item id: String, bitrate: Int32?) async throws -> Data {
        throw MediaServiceError.invalid
    }
}
