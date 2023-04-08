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
    public var isFavorite: Bool = false
}

public struct Song {
    public var uuid: String
    public var index: Int
    public var name: String
    public var parentId: String
    public var isFavorite: Bool = false
}

public struct DownloadedMedia {
    public var uuid: String
    public var data: Data
}
