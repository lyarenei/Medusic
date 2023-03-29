import Foundation
import OSLog

class FileRepository {
    public static let shared = FileRepository()

    private let cacheDirectory: URL
    private var cacheSizeLimit: Int

    private var poolSize: Int
    private var downloadSemaphore: DispatchSemaphore
    private var downloadQueue: [String]

    private var apiClient: ApiClient

    init(
        poolSize: Int = 3,
        cacheSizeLimitInMB: Int = 1000
    ) {
        self.poolSize = poolSize
        self.downloadSemaphore = DispatchSemaphore(value: poolSize)
        self.downloadQueue = []
        self.cacheSizeLimit = cacheSizeLimitInMB * 1024 * 1024

        let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        self.cacheDirectory = cacheURL.appendingPathComponent("JellyMusic/Downloads", isDirectory: true)

        do {
            try FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            Logger.repository.debug("Failed to create directory for downloads: \(error.localizedDescription)")
        }

        self.apiClient = ApiClient()
        self.initPool()
    }

    @discardableResult
    func enqueueToDownload(itemId: String) -> URL {
        enqueue(item: itemId)
        DispatchQueue.global(qos: .background).async {
            self.downloadSemaphore.wait()
            Task(priority: .background) {
                defer { self.downloadSemaphore.signal() }
                let outputFileURL = self.cacheDirectory.appendingPathComponent(itemId)
                do {
                    try await self.apiClient.services.mediaService.new_downloadItem(id: itemId, destination: outputFileURL)
                } catch {
                    Logger.repository.debug("Item download failed: \(error.localizedDescription)")
                }
            }
        }

        return self.cacheDirectory.appendingPathComponent(itemId)
    }

    func fileURL(for itemId: String) -> URL? {
        let fileURL = cacheDirectory.appendingPathComponent(itemId)
        return FileManager.default.fileExists(atPath: fileURL.path) ? fileURL : nil
    }

    func numberOfDownloadedFiles() -> Int {
        let enumerator = FileManager.default.enumerator(at: cacheDirectory, includingPropertiesForKeys: nil)
        return enumerator?.allObjects.count ?? 0
    }

    func downloadedFilesSizeInMB() -> Double {
        let totalSizeInBytes = downloadedFilesSize()
        let totalSizeInMB = Double(totalSizeInBytes) / 1024.0 / 1024.0
        return totalSizeInMB
    }

    private func downloadedFilesSize() -> UInt64 {
        var totalSize: UInt64 = 0

        let enumerator = FileManager.default.enumerator(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey], options: [])
        while let fileURL = enumerator?.nextObject() as? URL {
            do {
                let fileAttributes = try fileURL.resourceValues(forKeys: [.fileSizeKey])
                totalSize += UInt64(fileAttributes.fileSize ?? 0)
            } catch {
                print("Error calculating file size: \(error.localizedDescription)")
            }
        }

        return totalSize
    }

    func removeFile(itemId: String) throws {
        let fileURL = cacheDirectory.appendingPathComponent(itemId)
        try FileManager.default.removeItem(at: fileURL)
    }

    func removeAllFiles() throws {
        let fileURLs = try FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil, options: [])
        for fileURL in fileURLs {
            try FileManager.default.removeItem(at: fileURL)
        }
    }

    func setPoolSize(_ newPoolSize: Int) throws {
        guard newPoolSize > 0 else {
            Logger.repository.debug("Invalid pool size \(newPoolSize): cannot be less than 0")
            throw DownloadManagerError.invalidPoolSize
        }

        DispatchQueue.global(qos: .background).async {
            // Wait for all active downloads to finish before updating the pool size
            for _ in 0 ..< self.poolSize {
                self.downloadSemaphore.wait()
            }

            // Update the pool size and semaphore
            self.poolSize = newPoolSize
            self.downloadSemaphore = DispatchSemaphore(value: newPoolSize)

            // Signal the semaphore for the new pool size
            self.initPool()
        }
    }

    func setCacheSizeLimit(_ sizeInMB: Int) {
        cacheSizeLimit = sizeInMB * 1024 * 1024
    }

    func checkCacheSizeLimit() throws {
        let currentSize = downloadedFilesSize()
        if currentSize > cacheSizeLimit {
            throw DownloadManagerError.cacheSizeLimitExceeded
        }
    }

    // MARK: - Internal

    private func initPool() {
        Logger.repository.debug("Setting pool size to \(self.poolSize)")
        for _ in 0 ..< self.poolSize {
            self.downloadSemaphore.signal()
        }
    }

    private func enqueue(item id: String) {
        downloadQueue.append(id)
        Logger.repository.debug("Added item \(id) to queue")
        Logger.repository.debug("Current queue size: \(self.downloadQueue.count)")
    }

    enum DownloadManagerError: Error {
        case cacheSizeLimitExceeded
        case invalidPoolSize
    }
}
