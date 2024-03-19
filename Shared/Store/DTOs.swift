import AVFoundation
import Foundation

public struct JellyfinServerInfo {
    public var name: String
    public var version: String
}

protocol JellyfinItem: Identifiable, Codable, Equatable, Hashable {
    var id: String { get }
    var name: String { get }
    var isFavorite: Bool { get }
    var sortName: String { get }
}

struct PlayerQueueItem {
    var songId: String
    var songUrl: URL
    var orderIndex: Int
}
