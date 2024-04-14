import AVFoundation
import Foundation
import OSLog

final class AVJellyPlayerItem: AVPlayerItem {
    var song: Song?
}

extension MusicPlayer {
    enum PlayerError: Error {
        case songUrlNotFound
    }

    func enqueue(song: Song, position: EnqueuePosition) {
        enqueue(songs: [song], position: position)
    }

    func enqueue(songs: [Song], position: EnqueuePosition) {
        enqueueToPlayer(songs, position: position)
//        persistPlaybackQueue()
    }

    /// Enqueue a song to internal player. The song is placed at specified position.
    private func enqueueToPlayer(_ songs: [Song], position: EnqueuePosition) {
        do {
            let items = try songs.map(avItemFactory(song:))
            switch position {
            case .last:
                player.append(items: items)
            case .next:
                player.prepend(items: items)
            }

            Task { await updateNextUp() }
            Logger.player.debug("Songs added to queue: \(songs.map(\.id))")
        } catch {
            Logger.player.error("Failed to add songs to player queue: \(songs.map(\.id))")
        }
    }

    /// Clear playback queue. Optionally stop playback of current song.
    internal func clearQueue(stopPlayback: Bool = false) {
        if stopPlayback {
            player.removeAllItems()
        } else {
            player.clearNextItems()
        }

        Task { await updateNextUp() }
    }

    internal func avItemFactory(song: Song) throws -> AVPlayerItem {
        guard let fileUrl = fileRepo.getLocalOrRemoteUrl(for: song) else {
            Logger.player.debug("Could not retrieve an URL for song \(song.id), skipping")
            throw PlayerError.songUrlNotFound
        }

        if !apiClient.isAuthorized {
            Logger.player.warning("Client is not authenticated against server, remote playback may fail!")
        }

        let headers = ["Authorization": apiClient.authHeader]
        let asset = AVURLAsset(url: fileUrl, options: ["AVURLAssetHTTPHeaderFieldsKey": headers])
        let item = AVJellyPlayerItem(asset: asset)
        item.song = song
        subscribeToError(of: item)

        return item
    }

    private func subscribeToError(of item: AVJellyPlayerItem) {
        item.publisher(for: \.error)
            .receive(on: DispatchQueue.global(qos: .background))
            .sink { error in
                guard let error else { return }
                Logger.player.error("Failed to play song: \(error.localizedDescription)")
                Alerts.error("Failed to play song.")
            }
            .store(in: &cancellables)
    }
}
