import JellyfinAPI

// The ID getter crashes if `indexNumber: nil`,
// so testing is needed to find out if the `indexNumber` can ever be `nil`.

extension SongInfo: Identifiable {
    public var id: String {
        String(indexNumber!)
    }
}

extension AlbumInfo: Identifiable {
    public var id: String {
        String(indexNumber!)
    }
}

extension ArtistInfo: Identifiable {
    public var id: String {
        String(indexNumber!)
    }
}
