import Foundation
import OSLog

enum Notifier {
    private static let logger = Logger.notifier

    @MainActor
    static func emitSongDownloaded(_ songId: String, path: URL) {
        logger.debug("Emitting SongFileDownloaded notification for song \(songId)")
        NotificationCenter.default.post(name: .SongFileDownloaded, object: nil, userInfo: ["songId": songId, "path": path])
    }

    @MainActor
    static func emitSongDeleted(_ songId: String) {
        logger.debug("Emitting SongFileDeleted notification for song \(songId)")
        NotificationCenter.default.post(name: .SongFileDeleted, object: nil, userInfo: ["songId": songId])
    }
}
