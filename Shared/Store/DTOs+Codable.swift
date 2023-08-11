import Foundation

extension Song: Codable {
    enum CodingKeys: String, CodingKey {
        case id
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
        self.id = try container.decode(String.self, forKey: .id)
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
        try container.encode(id, forKey: .id)
        try container.encode(index, forKey: .index)
        try container.encode(name, forKey: .name)
        try container.encode(parentId, forKey: .parentId)
        try container.encode(isFavorite, forKey: .isFavorite)
        try container.encode(runtime, forKey: .runtime)
        try container.encode(albumDisc, forKey: .albumDisc)
        try container.encode(fileExtension, forKey: .fileExtension)
    }
}

extension PlayerQueueItem: Codable {
    enum CodingKeys: String, CodingKey {
        case songId
        case songUrl
        case orderIndex
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.songId = try container.decode(String.self, forKey: .songId)
        self.songUrl = try container.decode(URL.self, forKey: .songUrl)
        self.orderIndex = try container.decode(Int.self, forKey: .orderIndex)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(songId, forKey: .songId)
        try container.encode(songUrl, forKey: .songUrl)
        try container.encode(orderIndex, forKey: .orderIndex)
    }
}
