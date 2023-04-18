import Foundation

final class MockMediaService: MediaService {
    func getStreamUrl(item id: String, bitrate: Int32?) async throws -> URL? {
        throw MediaServiceError.invalid
    }

    func new_downloadItem(id: String, destination: URL) async throws {
        throw MediaServiceError.invalid
    }
}
