import Foundation

extension Array {
    /// Convenience indicator for checking if the collection is not empty.
    @inlinable
    public var isNotEmpty: Bool { !isEmpty }
}

extension [Song] {
    /// Sorts songs by album ID, then by their order.
    /// This results in songs being grouped by their albums, and in correct order in that album.
    func sortByAlbum() -> [Song] {
        sortByParentId().sortByIndex().sortByAlbumDisc()
    }

    func sortByParentId() -> [Song] {
        sorted { lhs, rhs -> Bool in
            lhs.parentId < rhs.parentId
        }
    }

    func sortByIndex() -> [Song] {
        sorted { lhs, rhs -> Bool in
            lhs.index < rhs.index
        }
    }

    func sortByAlbumDisc() -> [Song] {
        sorted { lhs, rhs -> Bool in
            lhs.albumDisc < rhs.albumDisc
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

    func filterByAlbumDisc(_ discNumber: Int) -> [Song] {
        filter { song -> Bool in
            song.albumDisc == discNumber
        }
    }

    func getAlbumDiscCount(albumId: String) -> Int {
        let filteredSongs = filter { song -> Bool in
            song.parentId == albumId
        }

        return filteredSongs.map { song in song.albumDisc }.max() ?? 1
    }

    /// Get song by specified song ID.
    func getById(_ songId: String) -> Song? {
        first { song -> Bool in
            song.uuid == songId
        }
    }

    func getRuntime(for albumId: String? = nil) -> TimeInterval {
        var totalRuntime: TimeInterval = 0
        if let albumId {
            filterByAlbum(id: albumId).forEach { totalRuntime += $0.runtime }
        } else {
            forEach { totalRuntime += $0.runtime }
        }

        return totalRuntime
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
