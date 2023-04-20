import AVFoundation

extension AVPlayerItem {
    /// The content URL for this item.
    var url: URL? {
        (asset as? AVURLAsset)?.url
    }

    /// Get the Jellyfin song uuid.
    var songId: String? {
        guard let url else { return nil }
        let matches = url.absoluteString.match("\\w{32}")
        return matches.first?.first
    }

    /// Indicates if this item matches with specified song ID.
    func matches(_ songId: String) -> Bool {
        guard let url else { return false }
        return url.absoluteString.contains(songId)
    }
}
