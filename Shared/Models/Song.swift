import AVFoundation
import Foundation
import SwiftData

@Model
final class Song: JellyfinModel {
    var jellyfinId: String
    var name: String
    var album: Album
    var albumIndex: Int

    var sortName: String
    var isFavorite: Bool
    var favoriteAt: Date
    var createdAt: Date

    var albumDisc: Int

    // No relationship as we don't have a usecase for tracking songs for artist (at least not yet).
    // And it is probably handled by Jellyfin anyway.
    var artists: [Artist]

    var runtime: TimeInterval
    var fileSize: UInt64
    var fileExtension: String

    init(
        jellyfinId: String,
        name: String,
        album: Album,
        albumIndex: Int,
        sortName: String = .empty,
        isFavorite: Bool = false,
        favoriteAt: Date = .distantPast,
        createdAt: Date = .distantPast,
        albumDisc: Int = 1,
        artists: [Artist] = [],
        runtime: TimeInterval = 0,
        fileSize: UInt64 = 0,
        fileExtension: String = .empty
    ) {
        self.jellyfinId = jellyfinId
        self.name = name
        self.sortName = sortName
        self.isFavorite = isFavorite
        self.favoriteAt = favoriteAt
        self.createdAt = createdAt
        self.albumIndex = albumIndex
        self.albumDisc = albumDisc
        self.artists = artists
        self.album = album
        self.runtime = runtime
        self.fileSize = fileSize
        self.fileExtension = fileExtension
    }

    var isNativelySupported: Bool {
        let types = AVURLAsset.audiovisualTypes()
        let extensions = types.compactMap { type in
            UTType(type.rawValue)?.preferredFilenameExtension
        }

        return extensions.contains { $0 == fileExtension }
    }

    var artistCreditName: String {
        if artists.count > 1 {
            let artistNames = artists.dropLast(1).map(\.name).joined(separator: ", ")
            // swiftlint:disable:next force_unwrapping
            return "\(artistNames) and \(artists.last!.name)"
        }

        return artists.first?.name ?? .empty
    }
}

extension Song: Equatable {
    static func == (lhs: Song, rhs: Song) -> Bool {
        lhs.jellyfinId == rhs.jellyfinId
    }
}

extension Song {
    static func predicate(for option: FilterOption) -> Predicate<Song> {
        switch option {
        case .all:
            return #Predicate<Song> { _ in true }
        case .favorite:
            return #Predicate<Song> { $0.isFavorite }
        }
    }

    static func predicate(equals id: String) -> Predicate<Song> {
        #Predicate<Song> { $0.jellyfinId == id }
    }

    static func fetchBy(_ jellyfinId: String) -> FetchDescriptor<Song> {
        FetchDescriptor(predicate: Song.predicate(equals: jellyfinId))
    }
}
