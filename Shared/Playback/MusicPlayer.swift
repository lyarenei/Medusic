import AVFoundation
import Foundation
import OSLog
import SwiftUI

@MainActor
final class MusicPlayer: ObservableObject {
    public static let shared = MusicPlayer()

    var player: AVQueuePlayer = .init()
    var api: ApiClient = .init()
    var songRepo: SongRepository

    @Published
    var currentSong: Song?

    @Published
    var isPlaying = false

    @Published
    var currentTime: TimeInterval = 0

    private var currentItemObserver: NSKeyValueObservation?

    init(
        preview: Bool = false,
        songRepo: SongRepository = .shared
    ) {
        self.songRepo = songRepo
        guard !preview else { return }

        let timeInterval = CMTime(seconds: 0.2, preferredTimescale: .max)
        player.addPeriodicTimeObserver(forInterval: timeInterval, queue: .main) { curTime in
            self.setCurrentTime(curTime.seconds)
        }

        self.currentItemObserver = player.observe(\.currentItem, options: [.new, .old]) { _, _ in
            Task {
                if let songId = await self.player.currentItem?.songId {
                    let song = await self.songRepo.getSong(by: songId)
                    await self.setCurrentlyPlaying(newSong: song)
                } else {
                    await self.setCurrentlyPlaying(newSong: nil)
                }
            }
        }
    }

    // MARK: - Playback controls

    func play(song: Song? = nil) async {
        if let song {
            clearQueue(stopPlayback: true)
            await enqueue(song: song, position: .last)
            setCurrentlyPlaying(newSong: song)
        }

        player.play()
        setIsPlaying(isPlaying: true)
    }

    func pause() {
        player.pause()
        setIsPlaying(isPlaying: false)
    }

    func resume() {
        player.play()
        setIsPlaying(isPlaying: true)
    }

    func stop() {
        clearQueue()
        setIsPlaying(isPlaying: false)
        setCurrentlyPlaying(newSong: nil)
    }

    func skipForward() {
        player.advanceToNextItem()
    }

    func skipBackward() {
        // TODO: implement
    }

    // MARK: - Queuing controls

    func enqueue(song: Song, position: EnqueuePosition) async {
        enqueueToPlayer(song, position: position)
        Logger.player.debug("Song added to queue: \(song.uuid)")
    }

    func enqueue(songs: [Song], position: EnqueuePosition) async {
        enqueueToPlayer(songs, position: position)
        Logger.player.debug("Songs added to queue: \(songs.debugDescription)")
    }

    /// Clear playback queue. Optionally stop playback of current song.
    private func clearQueue(stopPlayback: Bool = false) {
        if stopPlayback {
            player.removeAllItems()
        } else {
            player.clearNextItems()
        }
    }

    /// Enqueue a song to internal player. The song is placed at the end of its queue.
    private func enqueueToPlayer(_ song: Song, position: EnqueuePosition) {
        // TODO: local file check
        guard let url = api.services.mediaService.getStreamUrl(item: song.uuid, bitrate: nil) else {
            Logger.player.debug("Could not retrieve an URL for song \(song.uuid), skipping")
            return
        }

        let item = AVPlayerItem(url: url)
        switch position {
        case .last:
            player.append(item: item)
        case .next:
            player.prepend(item: item)
        }
    }

    private func enqueueToPlayer(_ songs: [Song], position: EnqueuePosition) {
        // TODO: implement
    }

    private func setCurrentlyPlaying(newSong: Song?) {
        currentSong = newSong
        Logger.player.debug("Song set as currently playing: \(newSong?.uuid ?? "nil")")
    }

    private func setIsPlaying(isPlaying: Bool) {
        self.isPlaying = isPlaying
        Logger.player.debug("Player is playing: \(isPlaying)")
    }

    private func setCurrentTime(_ curTime: TimeInterval) {
        currentTime = curTime.rounded(.toNearestOrAwayFromZero)
        Logger.player.debug("Current time: \(self.currentTime) (\(curTime))")
    }
}
