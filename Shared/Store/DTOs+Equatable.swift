import JellyfinAPI

extension SongInfo: Equatable {
    public static func == (lhs: SongInfo, rhs: SongInfo) -> Bool {
        lhs.id == rhs.id
    }
}

extension AlbumInfo: Equatable {
    public static func == (lhs: AlbumInfo, rhs: AlbumInfo) -> Bool {
        lhs.id == rhs.id
    }
}

extension ArtistInfo: Equatable {
    public static func == (lhs: ArtistInfo, rhs: ArtistInfo) -> Bool {
        lhs.id == rhs.id
    }
}
