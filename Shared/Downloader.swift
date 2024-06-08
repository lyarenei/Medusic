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

        NotificationCenter.default.publisher(for: .SongDownloadRequested)
            .sink { [weak self] event in
                guard let self,
                      let data = event.userInfo,
                      let songId = data["songId"] as? String
                else { return }
                self.logger.debug("Received download request for song \(songId)")
                Task {
                    guard let song = await self.songs.by(id: songId) else { return }
                    do {
                        try await self.download(song, startImmediately: true)
                    } catch {
                        self.logger.debug("Faild to enqueue song \(songId) for download: \(error.localizedDescription)")
                    }
                }
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: .SongDownloadCancelled)
            .sink { [weak self] event in
                guard let self,
                      let data = event.userInfo,
                      let songId = data["songId"] as? String
                else { return }
                self.logger.debug("Received download cancel for song \(songId)")
                Task {
                    guard let song = await self.songs.by(id: songId) else { return }
                    do {
                        // TODO: cancel when song is currently downloading
                        try await self.dequeue(song)
                    } catch {
                        self.logger.debug("Faild to cancel download for song \(songId): \(error.localizedDescription)")
                    }
                }
            }
            .store(in: &cancellables)

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
        try await enqueue(songs)

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

    private func enqueue(_ songs: [SongDto]) async throws {
        do {
            try await $downloadQueue.insert(songs)
            logger.debug("Added songs \(songs.map(\.id)) to download queue")

            let count = await downloadQueue.count
            logger.debug("Current queue size: \(count)")
        } catch {
            throw DownloaderError.enqueueFailed
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
            throw DownloaderError.enqueueFailed
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
            throw DownloaderError.dequeueFailed
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

        // TODO: yes, this can be also used for determining file extension, this might bite in the future, hehe
        let fileExtension = determineDownloadCodec(for: nextSong)
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
            throw DownloaderError.cacheIsFull
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
            throw DownloaderError.fileDownloadFailed
        }
    }

    private func determineDownloadCodec(for song: SongDto) -> String {
        guard Defaults[.downloadBitrate] == -1 else {
            logger.debug("Using \(AppDefaults.fallbackCodec) codec due to bitrate setting")
            return AppDefaults.fallbackCodec
        }

        if song.isNativelySupported {
            // TODO: should probably get codec from mediainfo
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

private enum DownloaderError: Error {
    case cacheIsFull
    case fileDownloadFailed
    case enqueueFailed
    case dequeueFailed
}

extension DownloaderError: LocalizedError {
    var localizedError: String {
        switch self {
        case .cacheIsFull:
            return "Downloaded directory cache is full."
        case .fileDownloadFailed:
            return "File download failed."
        case .enqueueFailed:
            return "Failed to add download to queue."
        case .dequeueFailed:
            return "Failed to remove download from queue."
        }
    }
}
