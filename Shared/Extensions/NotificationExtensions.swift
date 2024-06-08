import Foundation

extension Notification.Name {
    private static let bundle = "org.lyarenei.Medusic"

    static let SongFileDownloaded = Self("\(bundle).SongFileDownloaded")
    static let SongFileDeleted = Self("\(bundle).SongFileDeleted")

    static let SongDownloadRequested = Self("\(bundle).SongDownloadRequested")
    static let SongDownloadCancelled = Self("\(bundle).SongDownloadCancelled")
    static let SongDeleteRequested = Self("\(bundle).SongDeleteRequested")
}
