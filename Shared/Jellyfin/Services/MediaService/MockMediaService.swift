import Foundation

final class MockMediaService: MediaService {
    func getStreamUrl(item id: String, bitrate: Int32?) -> URL? {
        nil
    }

    func new_downloadItem(id: String, destination: URL) async throws {
        throw MediaServiceError.invalid
    }

    func setFavorite(itemId: String, isFavorite: Bool) async throws {
        throw MediaServiceError.invalid
    }

    func playbackStarted(itemId: String) async throws {
        throw MediaServiceError.invalid
    }

    func playbackStopped(itemId: String) async throws {
        throw MediaServiceError.invalid
    }

    func playbackFinished(itemId: String) async throws {
        throw MediaServiceError.invalid
    }
}
