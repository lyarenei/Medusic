import JellyfinAPI

extension SongInfo: Equatable {
    public static func == (lhs: SongInfo, rhs: SongInfo) -> Bool {
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
