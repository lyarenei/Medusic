import Foundation
import Boutique
import JellyfinAPI

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

extension Store<SongInfo> {
    static let songs = Store<SongInfo>(
        storage: SQLiteStorageEngine.default(appendingPath: "Songs")
    )
}
