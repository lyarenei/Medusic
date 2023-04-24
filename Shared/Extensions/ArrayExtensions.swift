extension Array {
    /// Convenience indicator for checking if the collection is not empty.
    @inlinable
    public var isNotEmpty: Bool { !isEmpty }
}

extension [Song] {
    /// Sorts songs by album ID, then by their order.
    /// This results in songs being grouped by their albums, and in correct order in that album.
    func sortByAlbum() -> [Song] {
        sorted { lhs, rhs -> Bool in
            // Sort by album ID, then by index
            if lhs.parentId < rhs.parentId { return true }
            if lhs.parentId > rhs.parentId { return false }
            if lhs.parentId == rhs.parentId {
                return lhs.index < rhs.index
            }

            return false
        }
    }

    /// Get only songs which belong to Album specified by its ID.
    /// These songs are sorted by their order in that album.
    func filterByAlbum(id albumId: String) -> [Song] {
        let filteredSongs = filter { song -> Bool in
            song.parentId == albumId
        }

        return filteredSongs.sortByAlbum()
    }

    /// Get song by specified song ID.
    func getById(_ songId: String) -> Song? {
        first { song -> Bool in
            song.uuid == songId
        }
    }
}

extension [Album] {
    /// Get album by specified album ID.
    func getById(_ albumId: String) -> Album? {
        first { album -> Bool in
            album.uuid == albumId
        }
    }

    var favorite: [Album] {
        filter(\.isFavorite)
    }

    // TODO: only temporary for consistency, until user can configure sort options
    var consistent: [Album] {
        sorted { lhs, rhs -> Bool in lhs.uuid < rhs.uuid }
    }
}
