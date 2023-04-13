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
}

struct Song: JellyfinItem {
    var uuid: String
    var index: Int
    var name: String
    var parentId: String
    var isFavorite: Bool
    var size: UInt64 = 0
}
