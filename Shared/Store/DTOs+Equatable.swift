import JellyfinAPI

extension PlayerQueueItem: Equatable {
    public static func == (lhs: PlayerQueueItem, rhs: PlayerQueueItem) -> Bool {
        lhs.id == rhs.id
    }
}
