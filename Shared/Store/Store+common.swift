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

extension Store<Song> {
    static let songs = Store<Song>(
        storage: SQLiteStorageEngine.default(appendingPath: "Songs")
    )
}
