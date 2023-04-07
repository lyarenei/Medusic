import AVFoundation
import Combine
import Foundation
import OSLog
import SwiftUI

protocol MusicPlayerDelegate {
    func getNextSong() async -> Song?
}

@MainActor
final class MusicPlayer: ObservableObject, MusicPlayerDelegate {
    public static let shared = MusicPlayer()

    @ObservedObject
    private var audioPlayer: AudioPlayer = .init()

    @Published
    var currentSong: Song? = nil

    @Published
    var playbackQueue: [Song] = []

    @Published
    var playbackHistory: [Song] = []

    @Published
    var isPlaying: Bool = false

    @Published
    var currentTime: TimeInterval = 0

    private var cancellables: Cancellables = []

    init(preview: Bool = false) {
        guard !preview else { return }
        audioPlayer.delegate = self
        subscribeToPlayerState()
        subscribeToCurrentTime()
    }

    func getNextSong() -> Song? {
        return playbackQueue.first
    }

    // MARK: - Playback controls

    func play(song: Song? = nil) async throws {
        if let song = song {
            if isPlaying { stop() }
            await enqueue(song: song, position: .next)
        }

        try await skipForward()
    }

    func pause() {
        audioPlayer.pause()
    }

    func resume() {
        switch audioPlayer.playerState {
        case .inactive:
            guard let currentSong = currentSong else { return }
            Task(priority: .userInitiated) {
                try await audioPlayer.play(song: currentSong)
            }
        case .paused:
            audioPlayer.resume()
        case .playing:
            return
        }
    }

    func stop() {
        audioPlayer.stop()
        playbackQueue.removeAll()
    }

    func skipForward() async throws {
        if let nextSong = advanceInQueue() {
            try await audioPlayer.skipToNext(song: nextSong)
        }
    }

    func skipBackward() async throws {
        guard playbackHistory.isNotEmpty else { return }
        let nextSong = playbackHistory.removeFirst()
        await enqueue(song: nextSong, position: .next)
        try await skipForward()
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

    func enqueue(itemId: String, position: EnqueuePosition) async {
        guard let song = await SongRepository.shared.getSong(by: itemId) else {
            Logger.player.debug("Could not find song for ID: \(itemId)")
            return
        }

        await enqueue(song: song, position: position)
    }

    @discardableResult
    private func advanceInQueue() -> Song? {
        if let currentSong = currentSong {
            Logger.player.debug("Added song to playback history: \(currentSong.uuid)")
            playbackHistory.insert(currentSong, at: 0)
        }

        guard playbackQueue.isNotEmpty else { return nil }
        currentSong = playbackQueue.removeFirst()
        Logger.player.debug("Song set as currently playing: \(self.currentSong?.uuid ?? "no_song")")
        return currentSong
    }

    // MARK: - Subscribers

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
            let roundedCurTime = curTime.rounded(.toNearestOrAwayFromZero)
            if let currentSong = self.currentSong {
                if roundedCurTime > currentSong.runtime {
                    self.stop()
                    self.advanceInQueue()
                    return
                }

                if roundedCurTime == currentSong.runtime {
                    self.advanceInQueue()
                }
            }

            Task(priority: .background) {
                await MainActor.run { self.currentTime = roundedCurTime }
            }
        }
        .store(in: &cancellables)
    }
}
