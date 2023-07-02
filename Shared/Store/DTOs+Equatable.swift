import JellyfinAPI

extension Song: Equatable {
    public static func == (lhs: Song, rhs: Song) -> Bool {
        lhs.id == rhs.id
    }
}

extension Album: Equatable {
    public static func == (lhs: Album, rhs: Album) -> Bool {
        lhs.id == rhs.id
    }
}

extension ArtistInfo: Equatable {
    public static func == (lhs: ArtistInfo, rhs: ArtistInfo) -> Bool {
        lhs.id == rhs.id
    }
}

extension PlayerQueueItem: Equatable {
    public static func == (lhs: PlayerQueueItem, rhs: PlayerQueueItem) -> Bool {
        lhs.id == rhs.id
    }
}
