import Foundation

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
