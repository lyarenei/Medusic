import Foundation
import OSLog

enum Notifier {
    private static let logger = Logger.notifier

    @MainActor
    static func emitSongDownloaded(_ song: SongDto) {
        logger.debug("Emitting SongFileDownloaded notification for song \(song.id)")
        NotificationCenter.default.post(
            name: .SongFileDownloaded,
            object: nil,
            userInfo: ["song": song]
        )
    }

    @MainActor
    static func emitSongDeleted(_ song: SongDto) {
        logger.debug("Emitting SongFileDeleted notification for song \(song.id)")
        NotificationCenter.default.post(
            name: .SongFileDeleted,
            object: nil,
            userInfo: ["song": song]
        )
    }

    @MainActor
    static func emitSongDownloadRequested(_ songId: String) {
        logger.debug("Emitting SongDownloadRequested notification for song \(songId)")
        NotificationCenter.default.post(name: .SongDownloadRequested, object: nil, userInfo: ["songId": songId])
    }
}
