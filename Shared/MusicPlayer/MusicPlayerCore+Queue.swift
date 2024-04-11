import AVFoundation
import Foundation
import OSLog

final class AVJellyPlayerItem: AVPlayerItem {
    var song: Song?
}

extension MusicPlayerCore {
    enum PlayerError: Error {
        case songUrlNotFound
    }

    func enqueue(song: Song, position: EnqueuePosition) {
        enqueueToPlayer(song, position: position)
//        persistPlaybackQueue()
    }

    func enqueue(songs: [Song], position: EnqueuePosition) {
        enqueueToPlayer(songs, position: position)
//        persistPlaybackQueue()
    }

    /// Clear playback queue. Optionally stop playback of current song.
    internal func clearQueue(stopPlayback: Bool = false) {
        if stopPlayback {
            player.removeAllItems()
        } else {
            player.clearNextItems()
        }
    }

    private func enqueueToPlayer(_ songs: [Song], position: EnqueuePosition) {
        do {
            let items = try songs.map(avItemFactory(song:))
            switch position {
            case .last:
                player.append(items: items)
            case .next:
                player.prepend(items: items)
            }

            Logger.player.debug("Songs added to queue: \(songs.map(\.id))")
        } catch {
            Logger.player.error("Failed to add songs to queue: \(songs.map(\.id))")
        }
    }

    /// Enqueue a song to internal player. The song is placed at specified position.
    private func enqueueToPlayer(_ song: Song, position: EnqueuePosition) {
        do {
            let item = try avItemFactory(song: song)
            switch position {
            case .last:
                player.append(item: item)
            case .next:
                player.prepend(item: item)
            }

            Logger.player.debug("Song added to queue: \(song.id)")
        } catch {
            Logger.player.debug("Failed to add song to queue: \(song.id)")
        }
    }

    private func avItemFactory(song: Song) throws -> AVPlayerItem {
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
