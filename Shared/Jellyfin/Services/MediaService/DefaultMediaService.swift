import Defaults
import Foundation
import Get
import JellyfinAPI
import OSLog

final class DefaultMediaService: MediaService {
    private let client: JellyfinClient

    init(client: JellyfinClient) {
        self.client = client
    }

    func getStreamUrl(item id: String, bitrate: Int32? = nil) -> URL? {
        let baseUrl = client.configuration.url.absoluteString
        if let bitrate {
            return URL(string: "\(baseUrl)/Audio/\(id)/stream?audioCodec=aac&audioBitRate=\(bitrate)")
        }

        return URL(string: "\(baseUrl)/Audio/\(id)/stream?static=true")
    }

    func new_downloadItem(id: String, destination: URL) async throws {
        let request = JellyfinAPI.Paths.getAudioStream(itemID: id)
        let delegate = MediaDownloadDelegate(destinationURL: destination)
        Logger.jellyfin.debug("Starting download for item \(id)")
        _ = try await client.download(for: request, delegate: delegate)
    }

    func setFavorite(itemId: String, isFavorite: Bool) async throws {
        guard Defaults[.readOnly] == false else { return }
        var request: Request<UserItemDataDto>
        if isFavorite {
            request = JellyfinAPI.Paths.markFavoriteItem(userID: Defaults[.userId], itemID: itemId)
        } else {
            request = JellyfinAPI.Paths.unmarkFavoriteItem(userID: Defaults[.userId], itemID: itemId)
        }

        _ = try await client.send(request)
    }

    func playbackStarted(itemId: String, at position: TimeInterval? = nil) async throws {
        guard Defaults[.readOnly] == false else { return }
        // TODO: send more fields
        let body = JellyfinAPI.PlaybackStartInfo(
            isPaused: false,
            itemID: itemId,
            playMethod: .directStream,
            playbackStartTimeTicks: position?.ticks,
            positionTicks: position?.ticks
        )

        let request = JellyfinAPI.Paths.reportPlaybackStart(body)
        try await client.send(request)
    }

    func playbackPaused(itemId: String, at position: TimeInterval? = nil) async throws {
        guard Defaults[.readOnly] == false else { return }
        let body = JellyfinAPI.PlaybackStartInfo(
            isPaused: true,
            itemID: itemId,
            playMethod: .directStream,
            playbackStartTimeTicks: position?.ticks,
            positionTicks: position?.ticks
        )

        let request = JellyfinAPI.Paths.reportPlaybackStart(body)
        try await client.send(request)
    }

    func playbackStopped(itemId: String, at position: TimeInterval? = nil) async throws {
        guard Defaults[.readOnly] == false else { return }
        // TODO: send more fields
        let body = JellyfinAPI.PlaybackStopInfo(itemID: itemId, positionTicks: position?.ticks)
        let request = JellyfinAPI.Paths.reportPlaybackStopped(body)
        try await client.send(request)
    }

    func playbackFinished(itemId: String) async throws {
        guard Defaults[.readOnly] == false else { return }
        let request = JellyfinAPI.Paths.markPlayedItem(
            userID: Defaults[.userId],
            itemID: itemId,
            datePlayed: .init()
        )

        _ = try await client.send(request)
    }
}

class MediaDownloadDelegate: NSObject, URLSessionDownloadDelegate {
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
        if let error {
            Logger.jellyfin.debug("Download error: \(error.localizedDescription)")
        }
    }
}
