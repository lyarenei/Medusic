import JellyfinAPI

// The ID getter crashes if `indexNumber: nil`,
// so testing is needed to find out if the `indexNumber` can ever be `nil`.

extension Song: Identifiable {
    public var id: String {
        self.uuid
    }
}

extension Album: Identifiable {
    public var id: String {
        self.uuid
    }
}

extension DownloadedMedia: Identifiable {
    public var id: String {
        self.uuid
    }
}

extension ArtistInfo: Identifiable {
    public var id: String {
        String(indexNumber!)
    }
}
