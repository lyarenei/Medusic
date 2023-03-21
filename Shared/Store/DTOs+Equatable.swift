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

extension DownloadedMedia: Equatable {
    public static func == (lhs: DownloadedMedia, rhs: DownloadedMedia) -> Bool {
        lhs.id == rhs.id
    }
}

extension ArtistInfo: Equatable {
    public static func == (lhs: ArtistInfo, rhs: ArtistInfo) -> Bool {
        lhs.id == rhs.id
    }
}
