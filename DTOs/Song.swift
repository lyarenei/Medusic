import AVFoundation
import Foundation
import JellyfinAPI

struct Song: JellyfinItem {
    var id: String
    var name: String
    var isFavorite: Bool
    var sortName: String
    var createdAt = Date.now

    var index: Int
    var albumId: String
    var artistNames: [String]
    var size: UInt64 = 0
    var runtime: TimeInterval
    var albumDisc = 0
    var fileExtension: String

    var isNativelySupported: Bool {
        let types = AVURLAsset.audiovisualTypes()
        let extensions = types.compactMap { type in
            UTType(type.rawValue)?.preferredFilenameExtension
        }

        return extensions.contains { $0 == fileExtension }
    }

    var artistCreditName: String {
        if artistNames.count > 1 {
            let artists = artistNames.dropLast(1).joined(separator: ", ")
            // swiftlint:disable:next force_unwrapping
            return "\(artists) and \(artistNames.last!)"
        }

        return artistNames.joined()
    }
}

extension Song: Equatable {
    static func == (lhs: Song, rhs: Song) -> Bool {
        lhs.id == rhs.id
    }
}

extension Song {
    init?(from item: BaseItemDto?) {
        guard let item,
              let id = item.id,
              let name = item.name,
              let albumId = item.albumID
        else { return nil }

        self.id = id
        self.name = name
        self.isFavorite = item.userData?.isFavorite ?? false
        self.sortName = item.sortName ?? name
        self.createdAt = item.dateCreated ?? .now

        self.index = item.indexNumber ?? 0
        self.albumId = albumId
        self.artistNames = item.artists ?? []
        self.size = {
            guard let sources = item.mediaSources else { return 0 }
            var sum: UInt64 = 0
            for source in sources {
                sum += UInt64(source.size ?? 0)
            }

            return sum
        }()
        self.runtime = item.runTimeTicks?.timeInterval ?? 0
        self.albumDisc = item.parentIndexNumber ?? 0
        self.fileExtension = {
            guard let path = item.path else { return .empty }
            guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return .empty }
            guard let url = URL(string: encodedPath) else { return .empty }
            return url.pathExtension
        }()
    }
}
