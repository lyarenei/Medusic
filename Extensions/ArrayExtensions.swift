import Foundation
import OrderedCollections

extension Array {
    /// Convenience indicator for checking if the collection is not empty.
    public var isNotEmpty: Bool { !isEmpty }
}

// MARK: - JellyfinItem

// swiftlint:disable identifier_name
extension Array where Element: JellyfinItem {
    func by(id: String) -> Element? { first { $0.id == id } }

    func filtered(by: FilterOption) -> [Element] {
        switch by {
        case .all:
            return self
        case .favorite:
            return filter(\.isFavorite)
        }
    }

    func sorted(by: SortOption) -> [Element] {
        switch by {
        case .name:
            return sorted { lhs, rhs -> Bool in
                lhs.sortName.lowercased() < rhs.sortName.lowercased()
            }
        case .dateAdded:
            return sorted { lhs, rhs -> Bool in
                lhs.createdAt < rhs.createdAt
            }
        }
    }

    func ordered(by: SortDirection) -> [Element] {
        switch by {
        case .ascending:
            return self
        case .descending:
            return reversed()
        }
    }

    enum GroupOption {
        case firstLetter
    }

    func grouped(by option: GroupOption) -> OrderedDictionary<String, [Element]> {
        switch option {
        default:
            OrderedDictionary(grouping: self) { Element -> String in
                guard let firstLetter = Element.sortName.uppercased().first else { return .empty }
                if firstLetter.isNumber {
                    return "0-9"
                } else if firstLetter.isLetter && firstLetter.isASCII {
                    return String(firstLetter)
                } else {
                    return "Other"
                }
            }
        }
    }
}

// swiftlint:enable identifier_name

extension Array where Element: JellyfinItem {
    @available(*, deprecated, message: "Use filtered(by:) FilterOption")
    var favorite: [Element] { filter(\.isFavorite) }

    @available(*, deprecated, message: "Use sorted(by:) SortOption")
    func sorted(by: UserSortBy) -> [Element] {
        switch by {
        case .name:
            return sorted(by: SortBy.name)
        }
    }
}

extension Array where Element: JellyfinItem {
    enum SortBy {
        case name
    }

    @available(*, deprecated, message: "Use sorted(by:) SortOption")
    func sorted(by: SortBy) -> [Element] {
        switch by {
        case .name:
            return sorted { lhs, rhs -> Bool in
                lhs.sortName.lowercased() < rhs.sortName.lowercased()
            }
        }
    }
}

// MARK: - Albums

extension [Album] {
    @available(*, deprecated, message: "Use filtered(by:)")
    func matching(artistId: String) -> [Album] {
        filter { $0.artistId == artistId }
    }

    @available(*, deprecated, message: "Use sorted(by:) SortOption")
    var consistent: [Album] {
        sorted { lhs, rhs -> Bool in
            lhs.name.lowercased() < rhs.name.lowercased()
        }
    }

    @available(*, deprecated, message: "Use sorted(by:) SortOption")
    var sortedByDateAdded: [Album] {
        sorted { lhs, rhs -> Bool in
            lhs.createdAt > rhs.createdAt
        }
    }
}

extension [Album] {
    enum AlbumFilterBy {
        case artistId(_ id: String)
    }

    func filtered(by method: AlbumFilterBy) -> [Album] {
        switch method {
        case .artistId(let id):
            return filter { $0.artistId == id }
        }
    }
}

// MARK: - Songs

extension [Song] {
    enum SongFilterBy {
        case albumId(_ id: String)
        case albumDisc(num: Int)
    }

    func filtered(by method: SongFilterBy) -> [Song] {
        switch method {
        case .albumId(let id):
            return filter { $0.albumId == id }
        case .albumDisc(let num):
            return filter { $0.albumDisc == num }
        }
    }
}

extension [Song] {
    enum SongSortBy {
        case index
        case albumDisc
    }

    func sorted(by method: SongSortBy) -> [Song] {
        switch method {
        case .index:
            return sorted { $0.index < $1.index }
        case .albumDisc:
            return sorted { $0.albumDisc < $1.albumDisc }
        }
    }
}

extension [Song] {
    /// Sorts songs by album ID, then by their order.
    /// This results in songs being grouped by their albums, and in correct order in that album.
    @available(*, deprecated, message: "Use sorted instead")
    func sortByAlbum() -> [Song] {
        sortByParentId().sortByIndex().sortByAlbumDisc()
    }

    @available(*, deprecated, message: "Use different sort")
    func sortByParentId() -> [Song] {
        sorted { lhs, rhs -> Bool in
            lhs.albumId < rhs.albumId
        }
    }

    @available(*, deprecated, message: "Use sorted instead")
    func sortByIndex() -> [Song] {
        sorted { lhs, rhs -> Bool in
            lhs.index < rhs.index
        }
    }

    @available(*, deprecated, message: "Use sorted instead")
    func sortByAlbumDisc() -> [Song] {
        sorted { lhs, rhs -> Bool in
            lhs.albumDisc < rhs.albumDisc
        }
    }

    /// Get only songs which belong to Album specified by its ID.
    /// These songs are sorted by their order in that album.
    @available(*, deprecated, message: "Use filtered instead")
    func filterByAlbum(id albumId: String) -> [Song] {
        let filteredSongs = filter { song -> Bool in
            song.albumId == albumId
        }

        return filteredSongs.sortByAlbum()
    }

    @available(*, deprecated, message: "Use filtered instead")
    func filterByAlbumDisc(_ discNumber: Int) -> [Song] {
        filter { song -> Bool in
            song.albumDisc == discNumber
        }
    }

    @available(*, deprecated, message: "Use library method")
    func getAlbumDiscCount(albumId: String) -> Int {
        let filteredSongs = filter { song -> Bool in
            song.albumId == albumId
        }

        return filteredSongs.map { song in song.albumDisc }.max() ?? 1
    }

    /// Get song by specified song ID.
    @available(*, deprecated, message: "Use by(id:) instead")
    func getById(_ songId: String) -> Song? {
        first { song -> Bool in
            song.id == songId
        }
    }

    @available(*, deprecated, message: "Use library method")
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
