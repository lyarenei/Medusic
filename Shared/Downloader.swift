import Boutique
import Defaults
import Foundation
import OSLog

final class Downloader: ObservableObject {
    static let shared = Downloader()

    @Stored
    var queue: [Song]

    private let apiClient: ApiClient
    private let fileRepo: FileRepository
    private let logger = Logger.downloader
    private var downloadTask: Task<Void, Never>?

    init(
        apiClient: ApiClient = .shared,
        fileRepo: FileRepository = .shared,
        downloadQueueStore: Store<Song> = .downloadQueue
    ) {
        self._queue = Stored(in: downloadQueueStore)
        self.apiClient = apiClient
        self.fileRepo = fileRepo

        startDownloading()
    }

    /// Add a song to download queue.
    func download(_ song: Song, startImmediately: Bool = true) async throws {
        try await download([song], startImmediately: startImmediately)
    }

    /// Add multiple songs to download queue.
    func download(_ songs: [Song], startImmediately: Bool = true) async throws {
        try await enqueue(songs)

        if startImmediately {
            startDownloading()
        }
    }

    /// Start downloading songs in the download queue.
    func startDownloading() {
        guard downloadTask == nil else { return }
        downloadTask = Task {
            do {
                try await downloadNextSong()
            } catch {
                logger.debug("Download failed: \(error.localizedDescription)")
            }
        }
    }

    private func enqueue(_ songs: [Song]) async throws {
        try await $queue.insert(songs)
        logger.debug("Added songs \(songs.map(\.id)) to download queue")

        let count = await queue.count
        logger.debug("Current queue size: \(count)")
    }

    private func dequeue(_ song: Song) async throws {
        try await $queue.remove(song)
        logger.debug("Song \(song.id) has been removed from download queue")

        let count = await queue.count
        logger.debug("Current queue size: \(count)")
    }

    private func downloadNextSong() async throws {
        // Order is not preserved after queue restore => sort by album to prioritize album completion
        // swiftlint:disable:next sorted_first_last
        guard let nextSong = await $queue.items.sorted(by: .album).first else {
            downloadTask?.cancel()
            downloadTask = nil
            return
        }

        do {
            try await downloadSong(nextSong)
        } catch {
            logger.debug("Failed to download song \(nextSong.id): \(error.localizedDescription)")
            try await downloadNextSong()
            return
        }

        try await dequeue(nextSong)
        await Notifier.emitSongDownloaded(nextSong)
        try await downloadNextSong()
    }

    private func downloadSong(_ song: Song) async throws {
        let currentSize = try fileRepo.getTakenSpace()
        guard currentSize + song.size <= fileRepo.cacheSizeLimit else {
            throw DownloaderError.cacheIsFull
        }

        // TODO: yes, this can be also used for determining file extension, this might bite in the future, hehe
        let fileExtension = determineDownloadCodec(for: song)
        let outputFileURL = fileRepo.generateURL(for: song, with: fileExtension)

        logger.debug("Starting download for song \(song.id)")

        let bitrate = getDownloadBitrate(for: song)
        try await apiClient.services.mediaService.downloadItem(
            id: song.id,
            destination: outputFileURL,
            bitrate: bitrate != nil ? bitrate ?? 0 : nil
        )
    }

    private func determineDownloadCodec(for song: Song) -> String {
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
    private func getDownloadBitrate(for song: Song) -> Int? {
        if Defaults[.downloadBitrate] == -1 {
            return song.isNativelySupported ? nil : AppDefaults.fallbackBitrate
        }

        return Defaults[.downloadBitrate]
    }
}

private enum DownloaderError: Error {
    case cacheIsFull
}

extension DownloaderError: LocalizedError {
    var localizedError: String {
        switch self {
        case .cacheIsFull:
            return "Downloaded directory cache is full"
        }
    }
}
