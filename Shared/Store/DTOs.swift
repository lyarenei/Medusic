import AVFoundation
import Foundation

public struct JellyfinServerInfo {
    public var name: String
    public var version: String
}

protocol JellyfinItem: Identifiable, Codable, Equatable {
    var uuid: String { get }
    var name: String { get }
    var isFavorite: Bool { get }
}

struct Album: JellyfinItem {
    var uuid: String
    var name: String
    var artistName: String
    var isFavorite: Bool
    var createdAt = Date()
}

struct Song: JellyfinItem {
    var uuid: String
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
    var songUuid: String
    var songUrl: URL
    var orderIndex: Int
}
