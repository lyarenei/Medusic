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

    init(
        jellyfinId: String,
        name: String,
        sortName: String = .empty,
        aboutInfo: String = .empty,
        isFavorite: Bool = false,
        favoriteAt: Date = .distantPast,
        createdAt: Date = .distantPast
    ) {
        self.jellyfinId = jellyfinId
        self.name = name

        let sortNameValue = sortName.isEmpty ? name : sortName
        self.sortName = sortNameValue.lowercased()

        self.aboutInfo = aboutInfo
        self.isFavorite = isFavorite
        self.favoriteAt = favoriteAt
        self.createdAt = createdAt
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
}

extension Album {
    // SwiftData does not support derived attributes yet, so we need to do this.
    var runtime: TimeInterval {
        var runtime: TimeInterval = 10
//        songs.forEach { runtime += $0.runtime }
        return runtime
    }
}

