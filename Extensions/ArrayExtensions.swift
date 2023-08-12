import Foundation

extension Array {
    /// Convenience indicator for checking if the collection is not empty.
    public var isNotEmpty: Bool { !isEmpty }
}

extension Array where Element: JellyfinItem {
    func by(id: String) -> Element? {
        first { $0.id == id }
    }

    // swiftlint:disable:next identifier_name
    func sorted(by: SortBy) -> [Element] {
        switch by {
        case .name:
            return sorted { lhs, rhs -> Bool in
                lhs.sortName.lowercased() < rhs.sortName.lowercased()
            }
        }
    }

    var favorite: [Element] {
        filter(\.isFavorite)
    }
}

extension [Album] {
    /// Select albums
    func matching(artistId: String) -> [Album] {
        filter { $0.artistId == artistId }
    }

    @available(*, deprecated, message: "Use sort by name")
    var consistent: [Album] {
        sorted { lhs, rhs -> Bool in
            lhs.name.lowercased() < rhs.name.lowercased()
        }
    }

    var sortedByDateAdded: [Album] {
        sorted { lhs, rhs -> Bool in
            lhs.createdAt > rhs.createdAt
        }
    }
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
            song.id == songId
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