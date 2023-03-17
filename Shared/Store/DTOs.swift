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

    static func empty() -> Album {
        return Album(uuid: "", name: "", artistName: "")
    }
}

public struct Song {
    public var uuid: String
    public var index: Int
    public var name: String
    public var parentId: String
    public var isDownloaded: Bool = false
    public var isFavorite: Bool = false
}
