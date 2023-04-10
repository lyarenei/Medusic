import Combine
import Foundation
import OSLog

final class FileRepository: ObservableObject {
    public static let shared = FileRepository()

    typealias Completion = () -> Void

    var cacheDirectory: URL
    var cacheSizeLimit: Int

    @Published
    var downloadQueue: [String]
    var isDownloading: Bool
    let apiClient: ApiClient

    init(cacheSizeLimitInMB: Int = 1000) {
        self.cacheSizeLimit = cacheSizeLimitInMB * 1024 * 1024
        self.downloadQueue = []
        self.isDownloading = false
        self.apiClient = ApiClient()
        do {
            let cacheUrl = try FileManager.default.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )

            self.cacheDirectory = cacheUrl.appendingPathComponent("JellyMusic/Downloads", isDirectory: true)
            try FileManager.default.createDirectory(
                at: cacheDirectory,
                withIntermediateDirectories: true,
                attributes: [.protectionKey: "none"]
            )
        } catch {
            fatalError("Could not set up app cache: \(error.localizedDescription)")
        }
    }

    /// Enqueue song for download.
    func enqueueToDownload(songId: String, startDownload: Bool = true) {
        enqueue(songId)
        if startDownload { startDownloading() }
    }

    /// Enqueue multiple songs for download.
    func enqueueToDownload(songIds: [String], startDownload: Bool = true) {
        for id in songIds { enqueue(id) }
        if startDownload { startDownloading() }
    }

    /// Start downloading songs in queue.
    func startDownloading() {
        if !isDownloading {
            downloadNextSong()
        }
    }

    private func downloadNextSong() {
        if let nextSong = downloadQueue.first {
            downloadSong(nextSong) {
                self.dequeue(nextSong)
                self.downloadNextSong()
            }
        } else {
            isDownloading = false
        }
    }

    private func downloadSong(_ songId: String, completion: Completion?) {
        Task(priority: .background) {
            let outputFileURL = cacheDirectory.appendingPathComponent(songId)
            Logger.repository.debug("Starting download for item \(songId)")
            Logger.repository.debug("Current queue size size: \(self.downloadQueue.count)")
            do {
                try await apiClient.services.mediaService.new_downloadItem(id: songId, destination: outputFileURL)
            } catch {
                Logger.repository.debug("Item download failed: \(error.localizedDescription)")
            }

            completion?()
        }
    }

    func fileURL(for songId: String) -> URL? {
        let fileURL = cacheDirectory.appendingPathComponent(songId)
        return FileManager.default.fileExists(atPath: fileURL.path) ? fileURL : nil
    }

    func numberOfDownloadedFiles() -> Int {
        let enumerator = FileManager.default.enumerator(at: cacheDirectory, includingPropertiesForKeys: nil)
        return enumerator?.allObjects.count ?? 0
    }

    func downloadedFilesSizeInMB() throws -> Double {
        let totalSizeInBytes = try downloadedFilesSize()
        let totalSizeInMB = Double(totalSizeInBytes) / 1024.0 / 1024.0
        return totalSizeInMB
    }

    private func downloadedFilesSize() throws -> UInt64 {
        var totalSize: UInt64 = 0
        let enumerator = FileManager.default.enumerator(
            at: cacheDirectory,
            includingPropertiesForKeys: [.fileSizeKey],
            options: []
        )

        while let fileURL = enumerator?.nextObject() as? URL {
            do {
                let fileAttributes = try fileURL.resourceValues(forKeys: [.fileSizeKey])
                totalSize += UInt64(fileAttributes.fileSize ?? 0)
            } catch {
                Logger.repository.debug("Failed to calculate file size: \(error.localizedDescription)")
                throw error
            }
        }

        return totalSize
    }

    func removeFile(songId: String) throws {
        let fileURL = cacheDirectory.appendingPathComponent(songId)
        Logger.repository.debug("Removig file for item \(songId)")
        try FileManager.default.removeItem(at: fileURL)
        Logger.repository.debug("File for item \(songId) has been removed")
    }

    func removeAllFiles() throws {
        Logger.repository.debug("Will remove all files in file repository")
        let fileURLs = try FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil, options: [])
        for fileURL in fileURLs {
            Logger.repository.debug("Removing file \(fileURL.debugDescription)")
            try FileManager.default.removeItem(at: fileURL)
        }
    }

    func setCacheSizeLimit(_ sizeInMB: Int) {
        Logger.repository.debug("Setting cache limit to \(sizeInMB) MB")
        cacheSizeLimit = sizeInMB * 1024 * 1024
    }

    func checkCacheSizeLimit() throws {
        let currentSize = try downloadedFilesSize()
        if currentSize > cacheSizeLimit {
            throw FileRepositoryError.cacheSizeLimitExceeded
        }
    }

    // MARK: - Internal

    private func enqueue(_ songId: String) {
        downloadQueue.append(songId)
        Logger.repository.debug("Added item \(songId) to queue")
        Logger.repository.debug("Current queue size: \(self.downloadQueue.count)")
    }

    private func dequeue(_ songId: String) {
        guard let idx = downloadQueue.firstIndex(of: songId) else { return }
        downloadQueue.remove(at: idx)
        Logger.repository.debug("Item \(songId) has been removed from queue")
        Logger.repository.debug("Current queue size: \(self.downloadQueue.count)")
    }

    enum FileRepositoryError: Error {
        case cacheDirectoryIsNil
        case cacheSizeLimitExceeded
    }
}
