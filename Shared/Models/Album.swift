import Foundation
import SwiftData

@Model
final class Album: JellyfinModel {
    var jellyfinId: String
    var name: String
    var sortName: String
    var aboutInfo: String

    var isFavorite: Bool
    var createdAt: Date

    var albumArtist: Artist?

    @Relationship(deleteRule: .cascade, inverse: \Song.album)
    var songs: [Song]

    init(
        jellyfinId: String,
        name: String,
        albumArtist: Artist? = nil,
        sortName: String = .empty,
        aboutInfo: String = .empty,
        isFavorite: Bool = false,
        createdAt: Date = .distantPast,
        artists: [Artist] = [],
        songs: [Song] = []
    ) {
        self.jellyfinId = jellyfinId
        self.name = name
        self.albumArtist = albumArtist

        let sortNameValue = sortName.isEmpty ? name : sortName
        self.sortName = sortNameValue.lowercased()

        self.aboutInfo = aboutInfo
        self.isFavorite = isFavorite
        self.createdAt = createdAt
        self.songs = songs
    }
}

// MARK: - Generic extensions
extension Album: Equatable {
    static func == (lhs: Album, rhs: Album) -> Bool {
        lhs.jellyfinId == rhs.jellyfinId
    }
}

// MARK: - SwiftData query utils
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

    static func fetchBy(_ jellyfinId: String) -> FetchDescriptor<Album> {
        FetchDescriptor(predicate: Album.predicate(equals: jellyfinId))
    }
}

// MARK: - SwiftData derived attributes
extension Album {
    // SwiftData does not support derived attributes yet, so we need to do this.
    var runtime: TimeInterval {
        var runtime: TimeInterval = 0
        songs.forEach { runtime += $0.runtime }
        return runtime
    }
}

// MARK: - Other
extension Album {
    convenience init(from album: AlbumDto) {
        self.init(
            jellyfinId: album.id,
            name: album.name,
            albumArtist: nil,
            sortName: album.sortName.lowercased(),
            aboutInfo: .empty,
            isFavorite: album.isFavorite,
            createdAt: album.createdAt,
            artists: [],
            songs: []
        )
    }
}
