import Foundation

extension Notification.Name {
    private static let bundle = "org.lyarenei.Medusic"

    static let AlbumDownloaded = Self("\(bundle).AlbumDownloaded")
    static let SongFileDownloaded = Self("\(bundle).SongFileDownloaded")
    static let SongFileDeleted = Self("\(bundle).SongFileDeleted")
}
