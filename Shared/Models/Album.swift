import Foundation
import SwiftData

@Model
final class Album {
    var jellyfinId: String
    var name: String
    var sortName: String
    var aboutInfo: String

    var isFavorite: Bool
    var favoriteAt: Date

    var createdAt: Date

    // Relationships
    var artists: [Artist]
    var songs: [Song]

    init(
        jellyfinId: String,
        name: String,
        sortName: String = .empty,
        aboutInfo: String = .empty,
        isFavorite: Bool = false,
        favoriteAt: Date = .distantPast,
        createdAt: Date = .distantPast,
        artists: [Artist] = [],
        songs: [Song] = []
    ) {
        self.jellyfinId = jellyfinId
        self.name = name

        let sortNameValue = sortName.isEmpty ? name : sortName
        self.sortName = sortNameValue.lowercased()

        self.aboutInfo = aboutInfo
        self.isFavorite = isFavorite
        self.favoriteAt = favoriteAt
        self.createdAt = createdAt
        self.artists = artists
        self.songs = songs
    }
}

extension Album {
    static func predicate(for option: FilterOption) -> Predicate<Album> {
        switch option {
        case .all:
            return #Predicate<Album> { _ in true }
        case .favorite:
            return #Predicate<Album> { $0.isFavorite }
        }
    }

    static func predicate(equals id: String) -> Predicate<Album> {
        #Predicate<Album> { $0.jellyfinId == id }
    }
}

extension Album {
    // SwiftData does not support derived attributes yet, so we need to do this.
    var runtime: TimeInterval {
        var runtime: TimeInterval = 10
        songs.forEach { runtime += $0.runtime }
        return runtime
    }
}
