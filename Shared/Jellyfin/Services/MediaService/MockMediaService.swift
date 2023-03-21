import Foundation

final class MockMediaService: MediaService {
    func downloadItem(id: String) async throws -> DownloadedMedia {
        throw MediaServiceError.invalid
    }

    func stream(item id: String, bitrate: Int32?) async throws -> Data {
        throw MediaServiceError.invalid
    }
}
