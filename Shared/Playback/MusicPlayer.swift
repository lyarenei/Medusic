import AVFoundation
import Combine
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
    var playbackQueue: [Song] = []

    @Published
    var playbackHistory: [Song] = []

    @Published
    var isPlaying = false

    @Published
    var currentTime: TimeInterval = 0

    private var cancellables: Cancellables = []
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

        self.currentItemObserver = player.observe(\.currentItem, options: [.new, .old]) { _, item in
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

    func getNextSong() -> Song? {
        playbackQueue.first
    }

    private func setCurrentlyPlaying(newSong: Song?) {
        currentSong = newSong
        Logger.player.debug("Song set as currently playing: \(newSong?.uuid ?? "nil")")
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
        advanceInQueue()
    }

    func skipBackward() async throws {
        guard playbackHistory.isNotEmpty else { return }
        let nextSong = playbackHistory.removeFirst()
        await enqueue(song: nextSong, position: .next)
        skipForward()
    }

    // MARK: - Queuing controls

    func enqueue(song: Song, position: EnqueuePosition) async {
        Logger.player.debug("Song added to queue: \(song.uuid)")
        await MainActor.run {
            switch position {
            case .last:
                self.playbackQueue.append(song)
            case .next:
                self.playbackQueue.insert(song, at: 0)
            }

            self.enqueueToPlayer(song, position: position)
        }
    }

    func enqueue(songs: [Song], position: EnqueuePosition) async {
        Logger.player.debug("Songs added to queue: \(songs.debugDescription)")
        await MainActor.run {
            switch position {
            case .last:
                self.playbackQueue.append(contentsOf: songs)
            case .next:
                self.playbackQueue.insert(contentsOf: songs, at: 0)
            }

            self.enqueueToPlayer(songs, position: position)
        }
    }

    // TODO: Remove when possible
    func enqueue(itemId: String, position: EnqueuePosition) async {
        guard let song = await SongRepository.shared.getSong(by: itemId) else {
            Logger.player.debug("Could not find song for ID: \(itemId)")
            return
        }

        await enqueue(song: song, position: position)
    }

    @discardableResult
    private func advanceInQueue() -> Song? {
        if let currentSong {
            Logger.player.debug("Added song to playback history: \(currentSong.uuid)")
            playbackHistory.insert(currentSong, at: 0)
        }

        guard playbackQueue.isNotEmpty else {
            stop()
            return nil
        }

        let newCurrentSong = playbackQueue.removeFirst()
        setCurrentlyPlaying(newSong: newCurrentSong)
        player.advanceToNextItem()
        return newCurrentSong
    }

    /// Clear playback queue. Optionally stop playback of current song.
    private func clearQueue(stopPlayback: Bool = false) {
        playbackQueue.removeAll()
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

    private func setIsPlaying(isPlaying: Bool) {
        Task { await MainActor.run { self.isPlaying = isPlaying } }
    }

    private func setCurrentTime(_ curTime: TimeInterval) {
        guard let currentSong else { return }
        let roundedCurTime = curTime.rounded(.toNearestOrAwayFromZero)
        if roundedCurTime > currentSong.runtime && getNextSong() == nil {
            Logger.player.debug("No next song, stopping player")
            advanceInQueue()
            return
        }

        if roundedCurTime > currentSong.runtime {
            Logger.player.debug("Advancing in queue")
            advanceInQueue()
            return
        }

        currentTime = roundedCurTime
    }
}
