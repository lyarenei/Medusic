import Foundation
import SwiftData

@Model
final class Artist: JellyfinModel {
    var jellyfinId: String
    var name: String
    var sortName: String
    var aboutInfo: String

    var isFavorite: Bool
    var favoriteAt: Date

    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Album.albumArtist)
    var albums: [Album]

    init(
        jellyfinId: String,
        name: String,
        sortName: String = .empty,
        aboutInfo: String = .empty,
        isFavorite: Bool = false,
        favoriteAt: Date = .distantPast,
        createdAt: Date = .distantPast,
        albums: [Album] = []
    ) {
        self.jellyfinId = jellyfinId
        self.name = name

        let sortNameValue = sortName.isEmpty ? name : sortName
        self.sortName = sortNameValue.lowercased()

        self.aboutInfo = aboutInfo
        self.isFavorite = isFavorite
        self.favoriteAt = favoriteAt
        self.createdAt = createdAt
        self.albums = albums
    }
}

// MARK: - Generic extensions
extension Artist: Equatable {
    static func == (lhs: Artist, rhs: Artist) -> Bool {
        lhs.jellyfinId == rhs.jellyfinId
    }
}

// MARK: - SwiftData query utils
extension Artist {
    static func predicate(for option: FilterOption) -> Predicate<Artist> {
        switch option {
        case .all:
            return #Predicate<Artist> { _ in true }
        case .favorite:
            return #Predicate<Artist> { $0.isFavorite }
        }
    }

    static func predicate(equals id: String) -> Predicate<Artist> {
        #Predicate<Artist> { $0.jellyfinId == id }
    }

    static func fetchBy(_ jellyfinId: String) -> FetchDescriptor<Artist> {
        FetchDescriptor(predicate: Artist.predicate(equals: jellyfinId))
    }
}

// MARK: - SwiftData derived attributes
extension Artist {
    // SwiftData does not support derived attributes yet, so we need to do this.
    var runtime: TimeInterval {
        var runtime: TimeInterval = 0
        albums.forEach { runtime += $0.runtime }
        return runtime
    }
}

// MARK: - Other

extension Artist {
    convenience init(from artist: ArtistDto, albums: [Album] = []) {
        self.init(
            jellyfinId: artist.id,
            name: artist.name,
            sortName: artist.sortName.lowercased(),
            aboutInfo: artist.about,
            isFavorite: artist.isFavorite,
            favoriteAt: .distantPast,
            createdAt: artist.createdAt,
            albums: albums
        )
    }
}
