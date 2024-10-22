import Boutique
import Defaults
import OSLog

final class FileRepository: ObservableObject {
    public static let shared = FileRepository()

    @Stored
    var songs: [SongDto]

    private var cacheDirectory: URL
    private(set) var cacheSizeLimit: UInt64
    private let apiClient: ApiClient
    private let logger: Logger
    private var observerRef: NSObjectProtocol?
    private var cancellables: Cancellables

    init(
        songsStore: Store<SongDto> = .songs,
        apiClient: ApiClient = .shared,
        logger: Logger = .library
    ) {
        self._songs = Stored(in: songsStore)
        self.apiClient = apiClient
        self.logger = logger
        self.cacheSizeLimit = Defaults[.maxCacheSize] * 1024 * 1024
        self.cancellables = []

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
            fatalError("Could not create downloads folder: \(error.localizedDescription)")
        }

        Task { try? await checkIntegrity() }
    }

    /// Generate a file URL for a specified song and file extension.
    func generateFileURL(for song: SongDto, with ext: String) -> URL {
        cacheDirectory.appendingPathComponent(song.id).appendingPathExtension(ext)
    }

    /// Calculates currently taken space by downloaded songs. Value is in bytes.
    func getTakenSpace() throws -> UInt64 {
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
                logger.warning("Failed to get file size: \(error.localizedDescription)")
                throw error
            }
        }

        return totalSize
    }

    func downloadedSongsCount() -> Int {
        let enumerator = FileManager.default.enumerator(at: cacheDirectory, includingPropertiesForKeys: nil)
        if let count = enumerator?.allObjects.count {
            return count
        }

        logger.warning("Failed to get count of downloaded songs - provided value is nil")
        return 0
    }

    func getTakenSpaceInMB() throws -> Double {
        do {
            let totalSizeInBytes = try getTakenSpace()
            return Double(totalSizeInBytes) / 1024.0 / 1024.0
        } catch {
            throw FileRepositoryError.takenSpaceFailure
        }
    }

    func setMaxSize(to sizeInMB: UInt64) {
        cacheSizeLimit = sizeInMB * 1024 * 1024
    }

    func getLocalOrRemoteUrl(for song: SongDto) -> URL? {
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
    func getLocalFileUrl(for song: SongDto) -> URL? {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil, options: [])
            return fileURLs.first { $0.absoluteString.contains(song.id) }
        } catch {
            logger.warning("Could not obtain directory contents: \(error.localizedDescription)")
            return nil
        }
    }

    func fileExists(for song: SongDto) -> Bool {
        getLocalFileUrl(for: song) != nil
    }

    func removeFile(for songId: String) async throws {
        guard let song = await songs.by(id: songId) else {
            logger.warning("Song \(songId) does not exist")
            throw LibraryRepositoryError.notFound
        }

        guard let fileURL = getLocalFileUrl(for: song) else {
            logger.warning("File for song \(songId) does not exist")
            throw FileRepositoryError.notFound
        }

        logger.debug("Removing file for song \(songId)")
        do {
            try FileManager.default.removeItem(at: fileURL)
            await Notifier.emitSongDeleted(songId)
        } catch let error as NSError {
            let reason = error.localizedFailureReason ?? "unknown reason"
            logger.debug("File removal for song \(songId) failed: \(error.localizedDescription) - \(reason)")
            throw FileRepositoryError.removeFailed(reason: error.localizedFailureReason ?? "unknown reason")
        } catch {
            logger.debug("File removal for song \(songId) failed: \(error.localizedDescription)")
            throw FileRepositoryError.removeFailed(reason: "unknown reason")
        }
    }

    func removeFiles(for songs: [SongDto]) async throws {
        for song in songs {
            try await removeFile(for: song.id)
        }
    }

    /// Remove all files in the download cache.
    func removeAllFiles() async throws {
        logger.debug("Will remove all files in file repository")

        let downloadedSongs = await songs.filtered(by: .downloaded)
        try await removeFiles(for: downloadedSongs)

        let fileURLs = try FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil, options: [])
        if fileURLs.isEmpty {
            return
        }

        logger.debug("Removing leftover files caused by inconsistency")
        for fileURL in fileURLs {
            logger.debug("Removing file \(fileURL.debugDescription)")
            try? FileManager.default.removeItem(at: fileURL)
        }
    }

    /// Check if songs in the store have a matching file and vice-versa.
    /// If there is a mismatch, it is assumed that something went wrong and the file/song is deleted.
    /// A mismatch may typically happen when an item is re-added to Jellyfin => this generates a new UUID for it.
    func checkIntegrity() async throws {
        logger.info("Starting integrity check of downloaded songs")

        var fixedErrors = 0
        let fileURLs: [URL]
        do {
            fileURLs = try FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil, options: [])
        } catch {
            logger.warning("Integrity check failed: \(error.localizedDescription)")
            throw FileRepositoryError.integrityCheckFailed(reason: "Could not get contents of directory")
        }

        let fileIds = Set(fileURLs.map { $0.deletingPathExtension().lastPathComponent })
        let songIds = Set(await songs.filtered(by: .downloaded).map(\.id))

        // File exists but song is not marked as downloaded - remove such file
        let missingFileIds = fileIds.subtracting(songIds)
        for missingFileId in missingFileIds {
            let url = fileURLs.first { $0.deletingPathExtension().lastPathComponent == missingFileId }
            if let url {
                logger.info("Found file for song \(missingFileId), but song is not marked as downloaded, removing file")
                if removeFile(at: url) {
                    fixedErrors += 1
                }
            } else {
                logger.debug("Could not get URL for file matching ID \(missingFileId)")
            }
        }

        // Song is marked as downloaded, but the expected file is not found - unmark song as downloaded
        let missingSongIds = songIds.subtracting(fileIds)
        for missingSongId in missingSongIds {
            logger.info("Found song \(missingSongId) as downloaded, but no file found, removing")
            if await untrackDownloaded(songId: missingSongId) {
                fixedErrors += 1
            }
        }

        let totalCount = missingSongIds.count + missingFileIds.count
        logger.info("Download cache integrity check finished: found \(totalCount) mismatches, fixed \(fixedErrors) mismatches")
        if totalCount != fixedErrors {
            throw FileRepositoryError.integrityCheckFailed(reason: "One or more mismatches were not fixed")
        }
    }

    // MARK: - Internal

    /// Get bitrate for streaming. Returns nil if the setting is to use original bitrate and codec is natively supported.
    private func getStreamPreferredBitrate(for song: SongDto) -> Int? {
        if Defaults[.streamBitrate] == -1 {
            return song.isNativelySupported ? nil : AppDefaults.fallbackBitrate
        }

        return Defaults[.streamBitrate]
    }

    private func removeFile(at url: URL) -> Bool {
        do {
            try FileManager.default.removeItem(at: url)
            return true
        } catch {
            logger.warning("Failed to remove file: \(error.localizedDescription)")
        }

        return false
    }

    private func untrackDownloaded(songId: String) async -> Bool {
        guard var song = await songs.by(id: songId) else {
            logger.debug("Song with ID \(songId) does not exist")
            return false
        }

        song.isDownloaded = false

        do {
            try await $songs.insert(song)
            return true
        } catch {
            logger.warning("Failed to unmark song \(songId) as downloaded")
        }

        return false
    }
}
