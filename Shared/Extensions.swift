import Defaults
import SwiftUI

extension Defaults.Keys {
    // Jellyfin settings
    static let serverUrl = Key<String>("serverUrl", default: "")
    static let username = Key<String>("username", default: "")
    static let userId = Key<String>("userId", default: "")

    // App settings
    static let offlineMode = Key<Bool>("offlineMode", default: false)
    static let previewMode = Key<Bool>("previewMode", default: false)
}

extension Array where Element == Album {
    /// Get album by specified album ID.
    func getById(_ albumId: String) -> Album? {
        return self.first(where: { album -> Bool in
            album.uuid == albumId
        })
    }
}

extension Array where Element == Song {
    /// Sorts songs by album ID, then by their order.
    /// This results in songs being grouped by their albums, and in correct order in that album.
    func sortByAlbum() -> [Song] {
        return self.sorted(by: { lhs, rhs -> Bool in
            // Sort by album ID, then by index
            if lhs.parentId < rhs.parentId { return true }
            if lhs.parentId > rhs.parentId { return false }
            if lhs.parentId == rhs.parentId {
                return lhs.index < rhs.index
            }

            return false
        })
    }

    /// Get only songs which belong to Album specified by its ID.
    /// These songs are sorted by their order in that album.
    func getByAlbum(id albumId: String) -> [Song] {
        let filteredSongs = self.filter { song -> Bool in
            song.parentId == albumId
        }

        return filteredSongs.sortByAlbum()
    }
}
