import Boutique
import Foundation
import JellyfinAPI
import SwiftUI

// MARK: - Stores

extension Store<SongDto> {
    static let songs = Store<SongDto>(
        storage: SQLiteStorageEngine.default(appendingPath: "Songs")
    )
    static let downloadedSongs = Store<SongDto>(
        storage: SQLiteStorageEngine.default(appendingPath: "DownloadedSongs")
    )
    static let downloadQueue = Store<SongDto>(
        storage: SQLiteStorageEngine.default(appendingPath: "DownloadQueue")
    )
}

extension Store<PlayerQueueItem> {
    static let playbackQueue = Store<PlayerQueueItem>(
        storage: SQLiteStorageEngine.default(appendingPath: "PlaybackQueue")
    )
}
