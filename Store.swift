import Boutique
import Foundation

extension Store<Artist> {
    static let artists = Store<Artist>(
        storage: SQLiteStorageEngine.default(appendingPath: "Artists")
    )
}

extension Store<Album> {
    static let albums = Store<Album>(
        storage: SQLiteStorageEngine.default(appendingPath: "Albums")
    )
}
