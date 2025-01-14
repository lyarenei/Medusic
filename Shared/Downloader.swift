import Boutique
import Defaults
import Foundation
import OSLog

final class Downloader: ObservableObject {
    static let shared = Downloader()

    @Stored
    var downloadQueue: [SongDto]

    @Stored
    var songs: [SongDto]

    private let apiClient: ApiClient
    private let fileRepo: FileRepository
    private let logger: Logger
    private var downloadTask: Task<Void, Never>?
    private var cancellables: Cancellables
    private var currentDownload: String?

    init(
        apiClient: ApiClient = .shared,
        fileRepo: FileRepository = .shared,
        logger: Logger = .downloader,
        downloadQueueStore: Store<SongDto> = .downloadQueue,
        songStore: Store<SongDto> = .songs
    ) {
        self.apiClient = apiClient
        self.fileRepo = fileRepo
        self.logger = logger
        self._downloadQueue = Stored(in: downloadQueueStore)
        self._songs = Stored(in: songStore)
        self.cancellables = []

        startDownloading()
    }

    /// Add a song to download queue.
    @available(*, deprecated, message: "Use songId method")
    func download(_ song: SongDto, startImmediately: Bool = true) async throws {
        try await download([song], startImmediately: startImmediately)
    }

    /// Add multiple songs to download queue.
    @available(*, deprecated, message: "Use songId method")
    func download(_ songs: [SongDto], startImmediately: Bool = true) async throws {
        try await enqueue(songs)

        if startImmediately {
            startDownloading()
        }
    }

    /// Add a song to download queue.
    func download(songId: String, startImmediately: Bool = true) async throws {
        try await download(songIds: [songId], startImmediately: startImmediately)
    }

    /// Add multiple songs to download queue.
    func download(songIds: [String], startImmediately: Bool = true) async throws {
        try await enqueue(songIds: songIds)

        if startImmediately {
            startDownloading()
        }
    }

    /// Start downloading songs in the download queue.
    func startDownloading() {
        guard downloadTask == nil else {
            logger.info("Download is already in progress")
            return
        }

        downloadTask = Task {
            do {
                try await downloadNextSong()
            } catch {
                logger.info("Download failed: \(error.localizedDescription)")
                Alerts.error("Download failed", reason: error.localizedDescription)
            }
        }
    }

    func cancelDownload(songId: String) async throws {
        // TODO: Implementation
    }

    func cancelAll() async throws {
        guard downloadTask != nil else { return }
        do {
            try await $downloadQueue.removeAll()
        } catch {
            logger.warning("Cancelling downloads failed: \(error.localizedDescription)")
            throw DownloaderError.cancelFailed(reason: "Failed to update download queue")
        }

        downloadTask?.cancel()
        downloadTask = nil
    }

    @available(*, deprecated, message: "Use variant accepting song IDs")
    private func enqueue(_ songs: [SongDto]) async throws {
        do {
            try await $downloadQueue.insert(songs)
            logger.debug("Added songs \(songs.map(\.id)) to download queue")

            let count = await downloadQueue.count
            logger.debug("Current queue size: \(count)")
        } catch {
            throw DownloaderError.downloadFailed(reason: "Failed to enqueue download(s)")
        }
    }

    private func enqueue(songIds: [String]) async throws {
        let songsToDownload = await songs.by(ids: songIds)
        do {
            try await $downloadQueue.insert(songsToDownload)
            logger.debug("Added songs \(songsToDownload.map(\.id)) to download queue")

            let count = await downloadQueue.count
            logger.debug("Current queue size: \(count)")
        } catch {
            throw DownloaderError.downloadFailed(reason: "Failed to enqueue download(s)")
        }
    }

    private func dequeue(_ song: SongDto) async throws {
        do {
            try await $downloadQueue.remove(song)
            logger.debug("Song \(song.id) has been removed from download queue")

            let count = await downloadQueue.count
            logger.debug("Current queue size: \(count)")
        } catch {
            logger.debug("Failed to dequeue download: \(error.localizedDescription)")
            throw DownloaderError.downloadFailed(reason: "Failed to remove download request from queue")
        }
    }

    private func downloadNextSong() async throws {
        // Order is not preserved after queue restore => sort by album to prioritize album completion
        // swiftlint:disable:next sorted_first_last
        guard let nextSong = await $downloadQueue.items.sorted(by: .album).first else {
            downloadTask?.cancel()
            downloadTask = nil
            return
        }

        let fileExtension = determineFileExtension(for: nextSong)
        let outputFileURL = fileRepo.generateFileURL(for: nextSong, with: fileExtension)

        do {
            try await downloadSong(nextSong, to: outputFileURL)
            try await dequeue(nextSong)
            await Notifier.emitSongDownloaded(nextSong.id, path: outputFileURL)
        } catch {
            try await downloadNextSong()
            return
        }

        try await downloadNextSong()
    }

    private func downloadSong(_ song: SongDto, to destination: URL) async throws {
        let currentSize = try fileRepo.getTakenSpace()
        guard currentSize + song.size <= fileRepo.cacheSizeLimit else {
            throw DownloaderError.downloadFailed(reason: "No free space left")
        }

        logger.debug("Starting download for song \(song.id)")

        let bitrate = getDownloadBitrate(for: song)
        do {
            try await apiClient.services.mediaService.downloadItem(
                id: song.id,
                destination: destination,
                bitrate: bitrate != nil ? bitrate ?? 0 : nil
            )
        } catch {
            logger.warning("Download for song \(song.id) failed: \(error.localizedDescription)")
            throw DownloaderError.downloadFailed(reason: "Error when downloading the file")
        }
    }

    private func determineFileExtension(for song: SongDto) -> String {
        guard Defaults[.downloadBitrate] == -1 else {
            logger.debug("Using \(AppDefaults.fallbackCodec) codec due to bitrate setting")
            return AppDefaults.fallbackCodec
        }

        if song.isNativelySupported {
            return song.fileExtension
        }

        Logger.repository.debug("File extension \(song.fileExtension) is not supported, will use \(AppDefaults.fallbackCodec) codec")
        return AppDefaults.fallbackCodec
    }

    /// Get a target bitrate of a downloaded song.
    private func getDownloadBitrate(for song: SongDto) -> Int? {
        if Defaults[.downloadBitrate] == -1 {
            return song.isNativelySupported ? nil : AppDefaults.fallbackBitrate
        }

        return Defaults[.downloadBitrate]
    }
}
