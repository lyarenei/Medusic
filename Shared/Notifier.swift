import Foundation

enum Notifier {
    @MainActor
    static func emitSongDownloaded(_ song: SongDto) {
        NotificationCenter.default.post(
            name: .SongFileDownloaded,
            object: nil,
            userInfo: ["song": song]
        )
    }

    @MainActor
    static func emitSongDeleted(_ song: SongDto) {
        NotificationCenter.default.post(
            name: .SongFileDeleted,
            object: nil,
            userInfo: ["song": song]
        )
    }
}
