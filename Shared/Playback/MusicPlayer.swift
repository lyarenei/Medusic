import AVFoundation
import Combine
import Foundation
import SwiftUI

class MusicPlayer: ObservableObject {
    public static let shared = MusicPlayer()

    @ObservedObject
    private var albumRepo: AlbumRepository = .shared

    @ObservedObject
    private var songRepo: SongRepository = .shared

    @ObservedObject
    private var mediaRepo: MediaRepository = .shared

    @ObservedObject
    private var audioPlayer: AudioPlayer = .init()

    @Published
    var currentSong: Song? = nil

    @Published
    var playbackQueue: [String] = []

    @Published
    var playbackHistory: [String] = []

    @Published
    var isPlaying: Bool = false

    private var cancellables: Cancellables = []

    init() {
        cancellables = [
            audioPlayer.$currentItemId.sink { [weak self] curItemId in
                if let itemId = curItemId {
                    DispatchQueue.main.async { Task(priority: .background) {
                        self?.currentSong = await self?.songRepo.getSong(by: itemId)
                    }}
                } else {
                    DispatchQueue.main.async { Task(priority: .background) {
                        self?.currentSong = nil
                    }}
                }
            },
            audioPlayer.$playerState.sink { [weak self] curState in
                switch curState {
                case .playing:
                    DispatchQueue.main.async { Task(priority: .background) {
                        self?.isPlaying = true
                    }}
                default:
                    DispatchQueue.main.async { Task(priority: .background) {
                        self?.isPlaying = false
                    }}
                }
            },
        ]
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
    }

    func playNow(itemId: String) async throws {
        self.stop()
        audioPlayer.insertItem(itemId, at: 0)
        try await self.play()
    }

    func skipForward() async throws {
        try await audioPlayer.skipToNext()
    }

    // MARK: - Queuing controls

    func enqueue(itemId: String, at: Int? = nil) {
        if let idx = at {
            return audioPlayer.insertItem(itemId, at: idx)
        }

        audioPlayer.append(itemId: itemId)
    }

    func enqueue(itemIds: [String], at: Int? = nil) {
        if let idx = at {
            return audioPlayer.insertItems(itemIds, at: idx)
        }

        audioPlayer.append(itemIds: itemIds)
    }
}
