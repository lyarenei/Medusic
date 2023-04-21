import Foundation

final class MockMediaService: MediaService {
    func getStreamUrl(item id: String, bitrate: Int32?) -> URL? {
        nil
    }

    func new_downloadItem(id: String, destination: URL) async throws {
        throw MediaServiceError.invalid
    }
}
