import Boutique
import Foundation

extension Store<Artist> {
    static let artists = Store<Artist>(
        storage: SQLiteStorageEngine.default(appendingPath: "Artists")
    )
}
