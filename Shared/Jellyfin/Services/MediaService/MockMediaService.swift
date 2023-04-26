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

    // swiftlint:disable:next function_parameter_count
    func playbackStarted(
        itemId: String,
        at position: TimeInterval?,
        isPaused: Bool,
        playbackQueue: [Song],
        volume: Int32,
        isStreaming: Bool
    ) async throws {
        throw MediaServiceError.invalid
    }

    // swiftlint:disable:next function_parameter_count
    func playbackProgress(
        itemId: String,
        at position: TimeInterval?,
        isPaused: Bool,
        playbackQueue: [Song],
        volume: Int32,
        isStreaming: Bool
    ) async throws {
        throw MediaServiceError.invalid
    }

    func playbackStopped(itemId: String, at position: TimeInterval?, playbackQueue: [Song]) async throws {
        throw MediaServiceError.invalid
    }

    func playbackFinished(itemId: String) async throws {
        throw MediaServiceError.invalid
    }
}
