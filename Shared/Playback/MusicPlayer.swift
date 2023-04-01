import AVFoundation
import Combine
import Foundation
import OSLog
import SwiftUI

actor MusicPlayer: ObservableObject {
    public static let shared = MusicPlayer()

//    @ObservedObject
    private var songRepo: SongRepository = .shared

//    @ObservedObject
    private var audioPlayer: AudioPlayer = .init()

    @MainActor
    @Published
    var currentSong: Song? = nil

    @MainActor
    @Published
    var playbackQueue: [Song] = []

    @MainActor
    @Published
    var playbackHistory: [Song] = []

    @MainActor
    @Published
    var isPlaying: Bool = false

    private var cancellables: Cancellables = []

    init(preview: Bool = false) {
        guard !preview else { return }

        Task {
            await subscribeToPlayerState()
            await subscribeToCurrentItem()
        }
    }

    // MARK: - Playback controls

    func play() async throws {
        try await audioPlayer.play()
    }

    func pause() {
        audioPlayer.pause()
    }

    func resume() {
        audioPlayer.resume()
    }

    func stop() async {
        audioPlayer.stop()
        await MainActor.run {
            playbackQueue.removeAll()
        }
    }

    func playNow(itemId: String) async throws {
        await stop()
        try await enqueue(itemId: itemId)
        try await play()
    }

    func skipForward() async throws {
        try await audioPlayer.skipToNext()
    }

    // MARK: - Queuing controls
    // TODO: Add parameter name, what the hell is `at`?
    func enqueue(itemId: String, at: Int? = nil) async throws {
        guard let song = await songRepo.getSong(by: itemId) else {
            Logger.player.debug("Could not find song for ID: \(itemId)")
            return
        }

        if let at {
            audioPlayer.insertItem(itemId, at: at)
            await MainActor.run {
                playbackQueue.insert(song, at: at)
            }
        }

        audioPlayer.append(itemId: itemId)
        await MainActor.run {
            playbackQueue.append(song)
        }
    }

    // MARK: - Subscribers

    private func subscribeToCurrentItem() {
        audioPlayer.$currentItemId.sink { [weak self] nextItemId in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let currentSong = self.currentSong {
                    self.playbackHistory.insert(currentSong, at: 0)
                    self.currentSong = nil
                }

                guard self.playbackQueue.isNotEmpty else {
                    print("Playback queue is empty")
                    return
                }
                self.currentSong = self.playbackQueue.removeFirst()
            }
        }
        .store(in: &cancellables)
    }

    private func subscribeToPlayerState() {
        audioPlayer.$playerState
            .sink { [weak self] state in
                guard let self = self else { return }
                Task {
                    await MainActor.run {
                        switch state {
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
}
