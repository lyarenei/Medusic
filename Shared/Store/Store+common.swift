import Boutique
import Foundation
import JellyfinAPI
import SwiftUI

extension Store<ArtistDto> {
    static let artists = Store<ArtistDto>(
        storage: SQLiteStorageEngine.default(appendingPath: "Artists")
    )
}

extension Store<AlbumDto> {
    static let albums = Store<AlbumDto>(
        storage: SQLiteStorageEngine.default(appendingPath: "Albums")
    )
}

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
