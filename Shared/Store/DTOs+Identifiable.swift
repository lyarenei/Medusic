import JellyfinAPI

extension Song: Identifiable {
    public var id: String { uuid }
}

extension Album: Identifiable {
    public var id: String { uuid }
}

extension ArtistInfo: Identifiable {
    public var id: String { String(indexNumber!) }
}

extension PlayerQueueItem: Identifiable {
    public var id: String {
        "\(songUuid)_\(orderIndex ?? .max)"
    }
}
