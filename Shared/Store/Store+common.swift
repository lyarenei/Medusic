import Boutique
import Foundation
import JellyfinAPI
import SwiftUI

// MARK: - Stores

extension Store<Song> {
    static let songs = Store<Song>(
        storage: SQLiteStorageEngine.default(appendingPath: "Songs")
    )
    static let downloadedSongs = Store<Song>(
        storage: SQLiteStorageEngine.default(appendingPath: "DownloadedSongs")
    )
    static let downloadQueue = Store<Song>(
        storage: SQLiteStorageEngine.default(appendingPath: "DownloadQueue")
    )
}

extension Store<PlayerQueueItem> {
    static let playbackQueue = Store<PlayerQueueItem>(
        storage: SQLiteStorageEngine.default(appendingPath: "PlaybackQueue")
    )
}
