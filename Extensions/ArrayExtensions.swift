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

    func nameContains(text: String) -> [Element] {
        guard text.isNotEmpty else { return self }
        return filter { $0.name.containsIgnoreCase(text) }
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

// MARK: - Albums

extension [AlbumDto] {
    enum AlbumFilterBy {
        case artistId(_ id: String)
    }

    func filtered(by method: AlbumFilterBy) -> [AlbumDto] {
        switch method {
        case .artistId(let id):
            return filter { $0.artistId == id }
        }
    }
}

// MARK: - Songs

extension [SongDto] {
    enum SongFilterBy {
        case albumId(_ id: String)
        case albumDisc(num: Int)
    }

    func filtered(by method: SongFilterBy) -> [SongDto] {
        switch method {
        case .albumId(let id):
            return filter { $0.albumId == id }
        case .albumDisc(let num):
            return filter { $0.albumDisc == num }
        }
    }
}

extension [SongDto] {
    enum SongSortBy {
        case index
        case album
        case albumDisc
        case parentId
    }

    func sorted(by method: SongSortBy) -> [SongDto] {
        switch method {
        case .index:
            return sorted { $0.index < $1.index }
        case .album:
            return sorted { ($0.albumId, $0.index, $0.albumDisc) < ($1.albumId, $1.index, $1.albumDisc) }
        case .albumDisc:
            return sorted { $0.albumDisc < $1.albumDisc }
        case .parentId:
            return sorted { $0.albumId < $1.albumId }
        }
    }
}
