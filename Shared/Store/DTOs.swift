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
    var sortName: String { get }
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
    var sortName: String = .empty

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
