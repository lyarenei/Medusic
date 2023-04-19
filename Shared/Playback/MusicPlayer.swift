import AVFoundation
import Combine
import Foundation
import OSLog
import SwiftUI

protocol MusicPlayerDelegate: AnyObject {
    func getNextSong() async -> Song?
}

@MainActor
final class MusicPlayer: ObservableObject, MusicPlayerDelegate {
    public static let shared = MusicPlayer()

    var player: AVQueuePlayer = .init()
    var api: ApiClient = .init()

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

    init(preview: Bool = false) {
        guard !preview else { return }
//        subscribeToPlayerState()
//        subscribeToCurrentTime()
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
    }

    func pause() {
        player.pause()
    }

    func resume() {
        player.play()
    }

    func stop() {
        clearQueue()
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

        guard playbackQueue.isNotEmpty else { return nil }
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

    // MARK: - Subscribers
/*
    private func subscribeToPlayerState() {
        audioPlayer.$playerState.sink { [weak self] curState in
            guard let self = self else { return }
            Task(priority: .background) {
                await MainActor.run {
                    switch curState {
                    case .playing:
                        self.isPlaying = true
                    default:
                        self.isPlaying = false
                    }
                }
            }
        }
        .store(in: &cancellables)
    }

    private func subscribeToCurrentTime() {
        audioPlayer.$currentTime.sink { [weak self] curTime in
            guard let self = self else { return }
            guard let currentSong = self.currentSong else { return }
            let roundedCurTime = curTime.rounded(.toNearestOrAwayFromZero)
            if roundedCurTime > currentSong.runtime && self.getNextSong() == nil {
                Logger.player.debug("No next song, stopping player")
                self.stop()
                self.advanceInQueue()
                return
            }

            if roundedCurTime > currentSong.runtime {
                Logger.player.debug("Advancing in queue")
                self.advanceInQueue()
                self.audioPlayer.resetTimeForNextSong()
                return
            }

            Task(priority: .background) {
                await MainActor.run { self.currentTime = roundedCurTime }
            }
        }
        .store(in: &cancellables)
    }
 */
}
