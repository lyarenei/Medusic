import Foundation

final class MockMediaService: MediaService {
    func getStreamUrl(item id: String, bitrate: Int?) -> URL? {
        nil
    }

    func downloadItem(id: String, destination: URL, bitrate: Int?) async throws {
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
        playbackQueue: [SongDto],
        volume: Int,
        isStreaming: Bool
    ) async throws {
        throw MediaServiceError.invalid
    }

    // swiftlint:disable:next function_parameter_count
    func playbackProgress(
        itemId: String,
        at position: TimeInterval?,
        isPaused: Bool,
        playbackQueue: [SongDto],
        volume: Int,
        isStreaming: Bool
    ) async throws {
        throw MediaServiceError.invalid
    }

    func playbackStopped(itemId: String, at position: TimeInterval?, playbackQueue: [SongDto]) async throws {
        throw MediaServiceError.invalid
    }

    func markAsPlayed(itemId: String) async throws {
        throw MediaServiceError.invalid
    }
}
