import Boutique
import Foundation
import JellyfinAPI
import SwiftUI

// MARK: - Stores

extension Store<Album> {
    static let albums = Store<Album>(
        storage: SQLiteStorageEngine.default(appendingPath: "Albums")
    )
}

extension Store<ArtistInfo> {
    static let artists = Store<ArtistInfo>(
        storage: SQLiteStorageEngine.default(appendingPath: "Artists")
    )
}

extension Store<Song> {
    static let songs = Store<Song>(
        storage: SQLiteStorageEngine.default(appendingPath: "Songs")
    )
}

extension Store<DownloadedMedia> {
    static let downloadedMedia = Store<DownloadedMedia>(
        storage: DiskStorageEngine(directory: .caches(appendingPath: "DownloadedMedia"))
    )
}

// MARK: - Environment

private struct AlbumRepoEnvironmentKey: EnvironmentKey {
    static let defaultValue: AlbumRepository = .init(store: .albums)
}

private struct SongRepoEnvironmentKey: EnvironmentKey {
    static let defaultValue: SongRepository = .init(store: .songs)
}

private struct DownloadedMediaRepoEnvironmentKey: EnvironmentKey {
    static let defaultValue: MediaRepository = .init(store: .downloadedMedia)
}

extension EnvironmentValues {
    var albumRepo: AlbumRepository {
        get { self[AlbumRepoEnvironmentKey.self] }
        set { self[AlbumRepoEnvironmentKey.self] = newValue }
    }

    var songRepo: SongRepository {
        get { self[SongRepoEnvironmentKey.self] }
        set { self[SongRepoEnvironmentKey.self] = newValue }
    }

    var mediaRepo: MediaRepository {
        get { self[DownloadedMediaRepoEnvironmentKey.self] }
        set { self[DownloadedMediaRepoEnvironmentKey.self] = newValue }
    }
}
