import AVFoundation
import Foundation

public struct JellyfinServerInfo {
    public var name: String
    public var version: String
}

protocol JellyfinItem: Identifiable, Codable, Equatable {
    var id: String { get }
    var name: String { get }
    var isFavorite: Bool { get }
}

struct Album: JellyfinItem {
    var id: String
    var name: String
    var artistName: String
    var isFavorite: Bool
    var createdAt = Date()
}

struct Song: JellyfinItem {
    var id: String
    var index: Int
    var name: String
    var parentId: String
    var isFavorite: Bool
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
}

struct PlayerQueueItem {
    var songId: String
    var songUrl: URL
    var orderIndex: Int
}
