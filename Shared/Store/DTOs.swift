import Foundation
import JellyfinAPI

public struct JellyfinServerInfo {
    public var name: String
    public var version: String
}

public struct Album {
    public var uuid: String
    public var name: String
    public var artistName: String
    public var isDownloaded: Bool = false
    public var isFavorite: Bool = false

    // TODO: remove this and pull songs from api by their parent id
    public var songs: [Song] = []
}

public struct Song {
    public var uuid: String
    public var index: Int
    public var name: String
    public var parentId: String
    public var isDownloaded: Bool = false
    public var isFavorite: Bool = false
}
