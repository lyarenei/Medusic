import Foundation
import JellyfinAPI

protocol Unique {
    var uuid: String { get }
}

protocol Downloadable {
    var isDownloaded: Bool { get set }
}

public struct JellyfinServerInfo {
    public var name: String
    public var version: String
}

public struct Album: Unique, Downloadable {
    public var uuid: String
    public var name: String
    public var artistName: String
    public var isDownloaded: Bool = false
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
