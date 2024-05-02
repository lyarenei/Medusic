import Boutique
import Foundation

extension Store<ArtistDto> {
    static let artists = Store<ArtistDto>(
        storage: SQLiteStorageEngine.default(appendingPath: "Artists")
    )
}

extension Store<Album> {
    static let albums = Store<Album>(
        storage: SQLiteStorageEngine.default(appendingPath: "Albums")
    )
}
