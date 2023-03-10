import Foundation


extension Album: Codable {
    enum CodingKeys: String, CodingKey {
        case uuid
        case name
        case artistName
        case isDownloaded
        case isLiked
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.uuid = try container.decode(String.self, forKey: .uuid)
        self.name = try container.decode(String.self, forKey: .name)
        self.artistName = try container.decode(String.self, forKey: .artistName)
        self.isDownloaded = try container.decode(Bool.self, forKey: .isDownloaded)
        self.isLiked = try container.decode(Bool.self, forKey: .isLiked)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(name, forKey: .name)
        try container.encode(artistName, forKey: .artistName)
        try container.encode(isDownloaded, forKey: .isDownloaded)
        try container.encode(isLiked, forKey: .isLiked)
    }
}

extension Song: Codable {
    enum CodingKeys: String, CodingKey {
        case uuid
        case index
        case name
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
