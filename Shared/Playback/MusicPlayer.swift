import AVFoundation
import Combine
import Foundation
import OSLog
import SwiftUI

class MusicPlayer: ObservableObject {
    public static let shared = MusicPlayer()

    @ObservedObject
    private var songRepo: SongRepository = .shared

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

    private var cancellables: Cancellables = []

    init(preview: Bool = false) {
        guard !preview else { return }
        subscribeToPlayerState()
        subscribeToCurrentItem()
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

    func stop() {
        audioPlayer.stop()
        playbackQueue.removeAll()
    }

    func playNow(itemId: String) async throws {
        stop()
        try await enqueue(itemId: itemId)
        try await play()
    }

    func skipForward() async throws {
        try await audioPlayer.skipToNext()
    }

    // MARK: - Queuing controls

    func enqueue(itemId: String, at: Int? = nil) async throws {
        guard let song = await songRepo.getSong(by: itemId) else {
            Logger.player.debug("Could not find song for ID: \(itemId)")
            return
        }

        DispatchQueue.main.async {
            if let at = at {
                self.audioPlayer.insertItem(itemId, at: at)
                self.playbackQueue.insert(song, at: at)
            }

            self.audioPlayer.append(itemId: itemId)
            self.playbackQueue.append(song)
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
        audioPlayer.$playerState.sink { [weak self] curState in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch curState {
                case .playing:
                    self.isPlaying = true
                default:
                    self.isPlaying = false
                }
            }
        }
        .store(in: &cancellables)
    }
}
