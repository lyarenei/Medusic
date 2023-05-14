import Boutique
import Defaults
import OSLog

final class FileRepository: ObservableObject {
    public static let shared = FileRepository()

    typealias Completion = () -> Void

    @Stored
    var downloadedSongs: [Song]

    @Stored
    var downloadQueue: [Song]

    var cacheDirectory: URL
    var cacheSizeLimit: UInt64
    var currentCacheSize: UInt64

    let apiClient: ApiClient
    var downloadTask: Task<Void, Never>?

    init(
        downloadedSongsStore: Store<Song> = .downloadedSongs,
        downloadQueueStore: Store<Song> = .downloadQueue,
        apiClient: ApiClient = .shared
    ) {
        _downloadedSongs = Stored(in: downloadedSongsStore)
        _downloadQueue = Stored(in: downloadQueueStore)
        self.cacheSizeLimit = Defaults[.maxCacheSize] * 1024 * 1024
        self.apiClient = apiClient
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

        self.currentCacheSize = 0
        do {
            self.currentCacheSize = try downloadedFilesSize()
        } catch {
            Logger.repository.error("Could not read current cache size, defaulting to 0")
        }

        startDownloading()
    }

    /// Enqueue song for download.
    func enqueueToDownload(song: Song, startDownload: Bool = true) async throws {
        try await enqueue(song)
        if startDownload {
            startDownloading()
        }
    }

    /// Enqueue multiple songs for download.
    func enqueueToDownload(songs: [Song], startDownload: Bool = true) async throws {
        for song in songs {
            try await enqueue(song)
        }

        if startDownload {
            startDownloading()
        }
    }

    /// Start downloading songs in queue.
    func startDownloading() {
        guard downloadTask == nil else { return }
        downloadTask = Task {
            do {
                try await downloadNextSong()
            } catch {
                Logger.repository.debug("Download failed: \(error.localizedDescription)")
            }
        }
    }

    private func downloadNextSong() async throws {
        if let nextSong = await $downloadQueue.items.sortByAlbum().first {
            do {
                try await downloadSong(nextSong)
            } catch {
                Logger.repository.debug("Song download failed: \(error.localizedDescription)")
                try await downloadNextSong()
                return
            }

            try await dequeue(nextSong)
            try await $downloadedSongs.insert(nextSong)
            currentCacheSize += nextSong.size
            try await downloadNextSong()
        } else {
            downloadTask?.cancel()
            downloadTask = nil
        }
    }

    private func downloadSong(_ song: Song) async throws {
        guard currentCacheSize + song.size <= cacheSizeLimit else {
            Logger.repository.info("Download for song \(song.uuid) cancelled: cache size limit reached")
            return
        }

        let fileExtension = getFileExtension(for: song)
        let outputFileURL = cacheDirectory.appendingPathComponent(song.uuid).appendingPathExtension(fileExtension)
        Logger.repository.debug("Starting download for song \(song.uuid)")
        await reportCurrentDownloadQueue()
        let bitrate = getDownloadPreferredBitrate(for: song)
        try await apiClient.services.mediaService.downloadItem(
            id: song.uuid,
            destination: outputFileURL,
            bitrate: bitrate != nil ? Int32(bitrate ?? 0) : nil
        )
    }

    func getLocalOrRemoteUrl(for song: Song) -> URL? {
        guard let fileUrl = fileURL(for: song) else {
            let bitrate = getStreamPreferredBitrate(for: song)
            return apiClient.services.mediaService.getStreamUrl(
                item: song.uuid,
                bitrate: bitrate != nil ? Int32(bitrate ?? 0) : nil
            )
        }

        return fileUrl
    }

    func fileURL(for song: Song) -> URL? {
        let fileExtension = getFileExtension(for: song)
        let fileURL = cacheDirectory.appendingPathComponent(song.uuid).appendingPathExtension(fileExtension)
        return FileManager.default.fileExists(atPath: fileURL.path) ? fileURL : nil
    }

    func fileExists(for song: Song) -> Bool {
        fileURL(for: song) != nil
    }

    func numberOfDownloadedFiles() -> Int {
        let enumerator = FileManager.default.enumerator(at: cacheDirectory, includingPropertiesForKeys: nil)
        return enumerator?.allObjects.count ?? 0
    }

    func downloadedFilesSizeInMB() throws -> Double {
        let totalSizeInBytes = try downloadedFilesSize()
        return Double(totalSizeInBytes) / 1024.0 / 1024.0
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

    func removeFile(for song: Song) async throws {
        let fileURL = cacheDirectory.appendingPathComponent(song.uuid)
        Logger.repository.debug("Removing file for song \(song.uuid)")
        try FileManager.default.removeItem(at: fileURL)
        try await $downloadedSongs.remove(song)
        Logger.repository.debug("File for song \(song.uuid) has been removed")
    }

    func removeFiles(for songs: [Song]) async throws {
        for song in songs {
            try await removeFile(for: song)
        }
    }

    func removeAllFiles() throws {
        Logger.repository.debug("Will remove all files in file repository")
        let fileURLs = try FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil, options: [])
        for fileURL in fileURLs {
            Logger.repository.debug("Removing file \(fileURL.debugDescription)")
            try FileManager.default.removeItem(at: fileURL)
        }
    }

    func setCacheSizeLimit(_ sizeInMB: UInt64) {
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

    private func enqueue(_ song: Song) async throws {
        try await $downloadQueue.insert(song)
        Logger.repository.debug("Added song \(song.uuid) to download queue")
        await reportCurrentDownloadQueue()
    }

    private func dequeue(_ song: Song) async throws {
        try await $downloadQueue.remove(song)
        Logger.repository.debug("Song \(song.uuid) has been removed from download queue")
        await reportCurrentDownloadQueue()
    }

    private func reportCurrentDownloadQueue() async {
        let queueSize = await $downloadQueue.items.count
        Logger.repository.debug("Current queue size: \(queueSize)")
    }

    private func getFileExtension(for song: Song) -> String {
        if song.isNativelySupported {
            return song.fileExtension
        }

        Logger.repository.debug("File extension \(song.fileExtension) is not supported, falling back to \(AppDefaults.fallbackCodec)")
        return AppDefaults.fallbackCodec
    }

    private func getStreamPreferredBitrate(for song: Song) -> Int? {
        let bitrateSetting = Defaults[.streamBitrate]
        if song.isNativelySupported {
            return bitrateSetting < 0 ? nil : bitrateSetting
        }

        return bitrateSetting < 0 ? AppDefaults.fallbackBitrate : bitrateSetting
    }

    private func getDownloadPreferredBitrate(for song: Song) -> Int? {
        let bitrateSetting = Defaults[.streamBitrate]
        if song.isNativelySupported {
            return bitrateSetting < 0 ? nil : bitrateSetting
        }

        return bitrateSetting < 0 ? AppDefaults.fallbackBitrate : bitrateSetting
    }

    enum FileRepositoryError: Error {
        case cacheDirectoryIsNil
        case cacheSizeLimitExceeded
    }
}
