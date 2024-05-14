import Boutique
import Foundation

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
