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
