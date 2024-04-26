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
                logger.debug("Failed to calculate file size: \(error.localizedDescription)")
                throw error
            }
        }

        return totalSize
    }

    func numberOfDownloadedFiles() -> Int {
        let enumerator = FileManager.default.enumerator(at: cacheDirectory, includingPropertiesForKeys: nil)
        return enumerator?.allObjects.count ?? 0
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
        await emitSongDeletedNotification(for: song)
    }

    func removeFiles(for songs: [Song]) async throws {
        for song in songs {
            try await removeFile(for: song)
        }
    }

    func removeAllFiles() async throws {
        logger.debug("Will remove all files in file repository")
        let fileURLs = try FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil, options: [])
        for fileURL in fileURLs {
            logger.debug("Removing file \(fileURL.debugDescription)")
            try FileManager.default.removeItem(at: fileURL)
        }

        try await $downloadedSongs.removeAll()
    }

    // MARK: - Internal

    private func getStreamPreferredBitrate(for song: Song) -> Int? {
        let bitrateSetting = Defaults[.streamBitrate]
        if song.isNativelySupported {
            return bitrateSetting < 0 ? nil : bitrateSetting
        }

        return bitrateSetting < 0 ? AppDefaults.fallbackBitrate : bitrateSetting
    }
}

extension FileRepository {
    @MainActor
    private func emitSongDeletedNotification(for song: Song) {
        NotificationCenter.default.post(
            name: .SongFileDeleted,
            object: nil,
            userInfo: ["song": song]
        )
    }
}
