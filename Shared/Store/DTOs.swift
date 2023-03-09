import Foundation
import JellyfinAPI

public struct Album: Codable {

    public var uuid: String
    public var name: String
    public var artistName: String

    enum CodingKeys: String, CodingKey {
        case uuid
        case name
        case artistName
    }

    public init(
        uuid: String,
        name: String,
        artistName: String
    ) {
        self.uuid = uuid
        self.name = name
        self.artistName = artistName
    }

    public init(from item: BaseItemDto) {
        if let albumId = item.id {
            self.uuid = albumId
        } else {
            self.uuid = ""
        }

        if let albumName = item.name {
            self.name = albumName
        } else {
            self.name = ""
        }

        if let name = item.albumArtist {
            self.artistName = name
        } else {
            self.artistName = ""
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.uuid = try container.decode(String.self, forKey: .uuid)
        self.name = try container.decode(String.self, forKey: .name)
        self.artistName = try container.decode(String.self, forKey: .artistName)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(name, forKey: .name)
        try container.encode(artistName, forKey: .artistName)
    }
}


public struct Song: Codable {

    public var uuid: String
    public var index: Int
    public var name: String

    enum CodingKeys: String, CodingKey {
        case uuid
        case index
        case name
    }

    public init(from item: BaseItemDto) {
        if let songId = item.id {
            self.uuid = songId
        } else {
            self.uuid = ""
        }

        if let index = item.indexNumber {
            self.index = Int(index)
        } else {
            self.index = 0
        }

        if let songName = item.name {
            self.name = songName
        } else {
            self.name = ""
        }
    }

    public init(
        uuid: String,
        index: Int,
        name: String
    ) {
        self.uuid = uuid
        self.index = index
        self.name = name
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.uuid = try container.decode(String.self, forKey: .uuid)
        self.index = try container.decode(Int.self, forKey: .index)
        self.name = try container.decode(String.self, forKey: .name)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(index, forKey: .index)
        try container.encode(name, forKey: .name)
    }
}
