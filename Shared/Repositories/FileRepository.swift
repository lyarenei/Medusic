import Boutique
import Defaults
import OSLog

final class FileRepository: ObservableObject {
    public static let shared = FileRepository()

    typealias Completion = () -> Void

    @Stored
    var downloadedSongs: [Song]

    private var cacheDirectory: URL
    private let apiClient: ApiClient
    private let logger = Logger.repository
    private var observerRef: NSObjectProtocol?

    var cacheSizeLimit: UInt64

    init(
        downloadedSongsStore: Store<Song> = .downloadedSongs,
        apiClient: ApiClient = .shared
    ) {
        self._downloadedSongs = Stored(in: downloadedSongsStore)
        self.apiClient = apiClient
        self.cacheSizeLimit = Defaults[.maxCacheSize] * 1024 * 1024
        do {
            let cacheUrl = try FileManager.default.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )

            self.cacheDirectory = cacheUrl.appendingPathComponent("Medusic/Downloads", isDirectory: true)
            try FileManager.default.createDirectory(
                at: cacheDirectory,
                withIntermediateDirectories: true,
                attributes: [.protectionKey: "none"]
            )
        } catch {
            fatalError("Could not set file repository: \(error.localizedDescription)")
        }

        self.observerRef = NotificationCenter.default.addObserver(forName: .SongFileDownloaded, object: nil, queue: .main) { event in
            guard let data = event.userInfo,
                  let song = data["song"] as? Song
            else { return }

            Task {
                do {
                    try await downloadedSongsStore.insert(song)
                } catch {
                    self.logger.warning("Failed to mark song \(song.id) as downloaded: \(error.localizedDescription)")
                }
            }
        }

        Task { await checkCacheIntegrity() }
    }

    /// Generate a file URL for a specified song and file extension.
    func generateURL(for song: Song, with ext: String) -> URL {
        cacheDirectory.appendingPathComponent(song.id).appendingPathExtension(ext)
    }

    func getCacheSize() throws -> UInt64 {
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
                logger.warning("Failed to calculate file size: \(error.localizedDescription)")
                throw error
            }
        }

        return totalSize
    }

    func numberOfDownloadedFiles() -> Int {
        let enumerator = FileManager.default.enumerator(at: cacheDirectory, includingPropertiesForKeys: nil)
        if let count = enumerator?.allObjects.count {
            return count
        }

        logger.warning("Failed to get number of files in download cache - provided value is nil")
        return 0
    }

    func downloadedFilesSizeInMB() throws -> Double {
        let totalSizeInBytes = try getCacheSize()
        return Double(totalSizeInBytes) / 1024.0 / 1024.0
    }

    func setCacheSizeLimit(_ sizeInMB: UInt64) {
        logger.debug("Setting cache limit to \(sizeInMB) MB")
        cacheSizeLimit = sizeInMB * 1024 * 1024
    }

    func getLocalOrRemoteUrl(for song: Song) -> URL? {
        guard let fileUrl = getLocalFileUrl(for: song) else {
            let bitrate = getStreamPreferredBitrate(for: song)
            return apiClient.services.mediaService.getStreamUrl(
                item: song.id,
                bitrate: bitrate != nil ? bitrate ?? 0 : nil
            )
        }

        return fileUrl
    }

    /// Get a file URL for a song.
    /// Should be used only for lookups as we can't determine the file extension due to the nature of settings and already downloaded files.
    func getLocalFileUrl(for song: Song) -> URL? {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil, options: [])
            return fileURLs.first { $0.absoluteString.contains(song.id) }
        } catch {
            logger.warning("Could not obtain cache directory contents: \(error.localizedDescription)")
            return nil
        }
    }

    func fileExists(for song: Song) -> Bool {
        getLocalFileUrl(for: song) != nil
    }

    func removeFile(for song: Song) async throws {
        guard let fileURL = getLocalFileUrl(for: song) else {
            logger.warning("File for song \(song.id) does not exist")
            return
        }

        logger.debug("Removing file for song \(song.id)")
        try FileManager.default.removeItem(at: fileURL)
        try await $downloadedSongs.remove(song)
        logger.debug("File for song \(song.id) has been removed")
        await Notifier.emitSongDeleted(song)
    }

    func removeFiles(for songs: [Song]) async throws {
        for song in songs {
            try await removeFile(for: song)
        }
    }

    /// Remove all files in the download cache.
    func removeAllFiles() async throws {
        logger.debug("Will remove all files in file repository")

        let songCount = await downloadedSongs.count
        let fileURLs = try FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil, options: [])

        if songCount != fileURLs.count {
            logger.warning("Downloaded song count (\(songCount)) does not match file count (\(fileURLs))!")
        }

        for fileURL in fileURLs {
            logger.debug("Removing file \(fileURL.debugDescription)")
            try FileManager.default.removeItem(at: fileURL)
        }

        try await $downloadedSongs.removeAll()
    }

    /// Check and fix the integrity of cache.
    func checkCacheIntegrity() async {
        let fileURLs: [URL]
        do {
            fileURLs = try FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil, options: [])
        } catch {
            logger.warning("Download cache integrity check failed: \(error.localizedDescription)")
            return
        }

        let fileIds = Set(fileURLs.map { $0.deletingPathExtension().lastPathComponent })
        let songIds = Set(await downloadedSongs.map(\.id))

        // File exists but no matching song in downloaded store
        let missingFileIds = fileIds.subtracting(songIds)
        for missingFileId in missingFileIds {
            let url = fileURLs.first { $0.deletingPathExtension().lastPathComponent == missingFileId }
            if let url {
                logger.info("Found file for song \(missingFileId), but it is not tracked, removing")
                removeFile(at: url)
            }
        }

        // Song in store but missing file
        let missingSongIds = songIds.subtracting(fileIds)
        for missingSongId in missingSongIds {
            let song = await downloadedSongs.first { $0.id == missingSongId }
            if let song {
                logger.info("Found song \(missingSongId) as downloaded, but no file found, removing")
                await untrackDownloaded(song)
            }
        }

        logger.info("Download cache integrity check finished: found \(missingSongIds.count + missingFileIds.count) errors")
    }

    // MARK: - Internal

    /// Get bitrate for streaming. Returns nil if the setting is to use original bitrate and codec is natively supported.
    private func getStreamPreferredBitrate(for song: Song) -> Int? {
        if Defaults[.streamBitrate] == -1 {
            return song.isNativelySupported ? nil : AppDefaults.fallbackBitrate
        }

        return Defaults[.streamBitrate]
    }

    private func removeFile(at url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            logger.warning("Failed to remove file: \(error.localizedDescription)")
        }
    }

    private func untrackDownloaded(_ song: Song) async {
        do {
            try await $downloadedSongs.remove(song)
        } catch {
            logger.warning("Failed to unmark song \(song.id) as downloaded")
        }
    }
}
