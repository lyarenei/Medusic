import Foundation

extension Album: Codable {
    enum CodingKeys: String, CodingKey {
        case uuid
        case name
        case artistName
        case isFavorite
        case createdAt
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.uuid = try container.decode(String.self, forKey: .uuid)
        self.name = try container.decode(String.self, forKey: .name)
        self.artistName = try container.decode(String.self, forKey: .artistName)
        self.isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(name, forKey: .name)
        try container.encode(artistName, forKey: .artistName)
        try container.encode(isFavorite, forKey: .isFavorite)
        try container.encode(createdAt, forKey: .createdAt)
    }
}

extension Song: Codable {
    enum CodingKeys: String, CodingKey {
        case uuid
        case index
        case name
        case parentId
        case isFavorite
        case runtime
        case albumDisc
        case fileExtension
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.uuid = try container.decode(String.self, forKey: .uuid)
        self.index = try container.decode(Int.self, forKey: .index)
        self.name = try container.decode(String.self, forKey: .name)
        self.parentId = try container.decode(String.self, forKey: .parentId)
        self.isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
        self.runtime = try container.decode(TimeInterval.self, forKey: .runtime)
        self.albumDisc = try container.decode(Int.self, forKey: .albumDisc)
        self.fileExtension = try container.decode(String.self, forKey: .fileExtension)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(index, forKey: .index)
        try container.encode(name, forKey: .name)
        try container.encode(parentId, forKey: .parentId)
        try container.encode(isFavorite, forKey: .isFavorite)
        try container.encode(runtime, forKey: .runtime)
        try container.encode(albumDisc, forKey: .albumDisc)
        try container.encode(fileExtension, forKey: .fileExtension)
    }
}
