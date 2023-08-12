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

// MARK: - Environment

private struct SongRepoEnvironmentKey: EnvironmentKey {
    static let defaultValue: SongRepository = .init(store: .songs)
}

extension EnvironmentValues {
    var songRepo: SongRepository {
        get { self[SongRepoEnvironmentKey.self] }
        set { self[SongRepoEnvironmentKey.self] = newValue }
    }
}
