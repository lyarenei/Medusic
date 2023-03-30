import Foundation
import JellyfinAPI
import OSLog

final class DefaultMediaService: MediaService {
    private let client: JellyfinClient

    init(client: JellyfinClient) {
        self.client = client
    }

    func downloadItem(id: String) async throws -> DownloadedMedia {
        let request = JellyfinAPI.Paths.getDownload(itemID: id)
        let response = try await client.send(request)
        return DownloadedMedia(uuid: id, data: response.value)
    }

    func stream(item id: String, bitrate: Int32?) async throws -> Data {
        throw MediaServiceError.invalid
    }

    func new_downloadItem(id: String, destination: URL) async throws {
        let request = JellyfinAPI.Paths.getAudioStream(itemID: id)
        let delegate = DownloadDelegate(destinationURL: destination)
        Logger.jellyfin.debug("Starting download for item \(id)")
        let _ = try await client.download(for: request, delegate: delegate)
    }
}

class DownloadDelegate: NSObject, URLSessionDownloadDelegate {
    let destinationURL: URL

    init(destinationURL: URL) {
        self.destinationURL = destinationURL
        super.init()
    }

    func urlSession(_: URLSession, downloadTask _: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            // If a file already exists at the destination URL, remove it.
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }

            // Move the downloaded file from the temporary location to the destination URL.
            try FileManager.default.moveItem(at: location, to: destinationURL)
            Logger.jellyfin.debug("Download completed")
        } catch {
            Logger.jellyfin.debug("Error when processing downloaded file: \(error.localizedDescription)")
            do {
                try FileManager.default.removeItem(at: destinationURL)
            } catch {
                Logger.jellyfin.debug("Failed to remove file: \(error.localizedDescription)")
            }
        }
    }

    func urlSession(_: URLSession, task _: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            Logger.jellyfin.debug("Download error: \(error.localizedDescription)")
        }
    }
}
