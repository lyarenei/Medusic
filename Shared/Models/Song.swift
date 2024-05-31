import AVFoundation
import Foundation
import SwiftData

@Model
final class Song: JellyfinItemModel {
    var jellyfinId: String
    var name: String
    var sortName: String
    var isFavorite: Bool
    var createdAt: Date

    var album: Album?
    var albumIndex: Int
    var albumDisc: Int

    var artists: [Artist]

    var runtime: TimeInterval
    var fileSize: UInt64
    var fileExtension: String
    var isDownloaded: Bool

    init(
        jellyfinId: String,
        name: String,
        sortName: String = .empty,
        isFavorite: Bool = false,
        createdAt: Date = .distantPast,
        album: Album? = nil,
        albumIndex: Int = 1,
        albumDisc: Int = 1,
        artists: [Artist] = [],
        runtime: TimeInterval = 0,
        fileSize: UInt64 = 0,
        fileExtension: String = .empty,
        isDownloaded: Bool = false
    ) {
        self.jellyfinId = jellyfinId
        self.name = name
        self.sortName = sortName
        self.isFavorite = isFavorite
        self.createdAt = createdAt
        self.album = album
        self.albumIndex = albumIndex
        self.albumDisc = albumDisc
        self.artists = artists
        self.runtime = runtime
        self.fileSize = fileSize
        self.fileExtension = fileExtension
        self.isDownloaded = isDownloaded
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

// MARK: - Generic extensions
extension Song: Equatable {
    static func == (lhs: Song, rhs: Song) -> Bool {
        lhs.jellyfinId == rhs.jellyfinId
    }
}

// MARK: - SwiftData query utils
extension Song {
    static func predicate(for option: FilterOption, contains text: String = .empty) -> Predicate<Song> {
        switch option {
        case .all:
            if text.isEmpty { return #Predicate<Song> { _ in true } }
            return #Predicate<Song> { $0.name.localizedStandardContains(text)}
        case .favorite:
            if text.isEmpty { return #Predicate<Song> { $0.isFavorite } }
            return #Predicate<Song> { $0.isFavorite && $0.name.localizedStandardContains(text)}
        }
    }

    static func predicate(equals id: String) -> Predicate<Song> {
        #Predicate<Song> { $0.jellyfinId == id }
    }

    static func fetchBy(_ jellyfinId: String) -> FetchDescriptor<Song> {
        FetchDescriptor(predicate: Song.predicate(equals: jellyfinId))
    }
}

// MARK: - Other
extension Song {
    convenience init(from song: SongDto, album: Album? = nil, artists: [Artist] = []) {
        self.init(
            jellyfinId: song.id,
            name: song.name,
            sortName: song.sortName.lowercased(),
            isFavorite: song.isFavorite,
            createdAt: song.createdAt,
            album: album,
            albumIndex: song.index,
            albumDisc: song.albumDisc,
            artists: artists,
            runtime: song.runtime,
            fileSize: song.size,
            fileExtension: song.fileExtension
        )
    }
}
