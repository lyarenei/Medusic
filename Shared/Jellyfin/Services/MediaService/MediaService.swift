import Foundation

protocol MediaService: ObservableObject {
    func getStreamUrl(item id: String, bitrate: Int?) -> URL?

    func downloadItem(id: String, destination: URL, bitrate: Int?) async throws
    func setFavorite(itemId: String, isFavorite: Bool) async throws

    // swiftlint:disable:next function_parameter_count
    func playbackStarted(
        itemId: String,
        at position: TimeInterval?,
        isPaused: Bool,
        playbackQueue: [Song],
        volume: Int,
        isStreaming: Bool
    ) async throws

    // swiftlint:disable:next function_parameter_count
    func playbackProgress(
        itemId: String,
        at position: TimeInterval?,
        isPaused: Bool,
        playbackQueue: [Song],
        volume: Int,
        isStreaming: Bool
    ) async throws

    func playbackStopped(itemId: String, at position: TimeInterval?, playbackQueue: [Song]) async throws
    func markAsPlayed(itemId: String) async throws
}

enum MediaServiceError: Error {
    case invalid
    case itemNotFound
}
