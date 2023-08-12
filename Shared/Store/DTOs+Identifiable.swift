import JellyfinAPI

extension PlayerQueueItem: Identifiable {
    public var id: String {
        "\(songId)_\(orderIndex)"
    }
}
