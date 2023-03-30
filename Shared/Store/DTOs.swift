import Foundation
import JellyfinAPI

protocol Unique {
    var uuid: String { get }
}

public struct JellyfinServerInfo {
    public var name: String
    public var version: String
}

public struct Album: Unique {
    public var uuid: String
    public var name: String
    public var artistName: String
    public var isFavorite: Bool = false

    static func empty() -> Album {
        return Album(uuid: "", name: "", artistName: "")
    }
}

public struct Song: Unique {
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
