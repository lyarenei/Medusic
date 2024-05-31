import Foundation
import OSLog
import SwiftData

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
    static func emitFavoriteStatusChanged(itemId: PersistentIdentifier, jellyfinId: String, isFavorite: Bool) {
        logger.debug("Emitting FavoriteStatusChanged notification for \(itemId.entityName), jellyfinId: \(jellyfinId), isFavorite: \(isFavorite)")
        NotificationCenter.default.post(
            name: .FavoriteStatusChanged,
            object: nil,
            userInfo: ["itemId": itemId, "jellyfinId": jellyfinId, "isFavorite": isFavorite]
        )
    }
}
