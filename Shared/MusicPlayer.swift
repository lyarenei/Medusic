import AVFoundation
import Foundation
import OSLog
import SwiftUI

final class MusicPlayer: ObservableObject {
    public static let shared = MusicPlayer()

    var player: AVQueuePlayer = .init()
    let apiClient: ApiClient
    var songRepo: SongRepository
    var fileRepo: FileRepository

    @Published
    var currentSong: Song?

    @Published
    var isPlaying = false

    private var currentItemObserver: NSKeyValueObservation?

    init(
        preview: Bool = false,
        songRepo: SongRepository = .shared,
        fileRepo: FileRepository = .shared,
        apiClient: ApiClient = .shared
    ) {
        self.songRepo = songRepo
        self.fileRepo = fileRepo
        self.apiClient = apiClient
        guard !preview else { return }

        self.currentItemObserver = player.observe(\.currentItem, options: [.new, .old]) { [weak self] _, _ in
            guard let self else { return }
            Task {
                if let currentSong = self.currentSong {
                    await self.sendPlaybackStopped(for: currentSong)
                    await self.sendPlaybackFinished(for: currentSong)
                }

                if let songId = self.player.currentItem?.songId {
                    let song = await self.songRepo.getSong(by: songId)
                    await self.setCurrentlyPlaying(newSong: song)
                    await self.sendPlaybackStarted(for: song)
                } else {
                    await self.setCurrentlyPlaying(newSong: nil)
                }
            }
        }

        audioSessionSetup()
    }

    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance()
        )
    }

    private func audioSessionSetup() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )
            try session.setActive(true)
            UIApplication.shared.beginReceivingRemoteControlEvents()
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleInterruption),
                name: AVAudioSession.interruptionNotification,
                object: AVAudioSession.sharedInstance()
            )
            Logger.player.debug("Audio session has been initialized")
        } catch {
            Logger.player.debug("Failed to set up audio session: \(error.localizedDescription)")
        }
    }

    // MARK: - Playback controls

    func play(song: Song? = nil) async {
        if let song {
            clearQueue(stopPlayback: true)
            await enqueue(song: song, position: .last)
        }

        await player.play()
        await setIsPlaying(isPlaying: true)
    }

    func play(songs: [Song]) async {
        clearQueue(stopPlayback: true)
        await enqueue(songs: songs, position: .last)
        await player.play()
        await setIsPlaying(isPlaying: true)
    }

    func pause() async {
        await player.pause()
        await setIsPlaying(isPlaying: false)
        await sendPlaybackProgress(for: currentSong, isPaused: true)
    }

    func resume() async {
        await player.play()
        await setIsPlaying(isPlaying: true)
        await sendPlaybackProgress(for: currentSong, isPaused: false)
    }

    func stop() async {
        clearQueue()
        await setIsPlaying(isPlaying: false)
        await setCurrentlyPlaying(newSong: nil)
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
        // swiftformat:disable:next preferKeyPath
        Logger.player.debug("Songs added to queue: \(songs.map { $0.uuid })")
    }

    /// Clear playback queue. Optionally stop playback of current song.
    private func clearQueue(stopPlayback: Bool = false) {
        if stopPlayback {
            player.removeAllItems()
        } else {
            player.clearNextItems()
        }
    }

    /// Enqueue a song to internal player. The song is placed at specified position.
    private func enqueueToPlayer(_ song: Song, position: EnqueuePosition) {
        let fileUrl = fileRepo.fileURL(for: song.uuid)
        let remoteUrl = apiClient.services.mediaService.getStreamUrl(item: song.uuid, bitrate: nil)

        guard let remoteUrl else {
            Logger.player.debug("Could not retrieve an URL for song \(song.uuid), skipping")
            return
        }

        let item = AVPlayerItem(url: fileUrl ?? remoteUrl)
        switch position {
        case .last:
            player.append(item: item)
        case .next:
            player.prepend(item: item)
        }
    }

    private func enqueueToPlayer(_ songs: [Song], position: EnqueuePosition) {
        switch position {
        case .last:
            for song in songs {
                enqueueToPlayer(song, position: .last)
            }
        case .next:
            for song in songs.reversed() {
                enqueueToPlayer(song, position: .next)
            }
        }
    }

    @MainActor
    private func setCurrentlyPlaying(newSong: Song?) async {
        currentSong = newSong
        Logger.player.debug("Song set as currently playing: \(newSong?.uuid ?? "nil")")
    }

    @MainActor
    private func setIsPlaying(isPlaying: Bool) {
        self.isPlaying = isPlaying
        Logger.player.debug("Player is playing: \(isPlaying)")
    }

    private func sendPlaybackStarted(for song: Song?) async {
        guard let song else { return }
        try? await apiClient.services.mediaService.playbackStarted(
            itemId: song.uuid,
            at: player.currentTime().seconds,
            isPaused: false,
            playbackQueue: [],
            volume: getVolume(),
            isStreaming: true
        )
    }

    private func sendPlaybackProgress(for song: Song?, isPaused: Bool) async {
        guard let song else { return }
        try? await apiClient.services.mediaService.playbackProgress(
            itemId: song.uuid,
            at: player.currentTime().seconds,
            isPaused: isPaused,
            playbackQueue: [],
            volume: getVolume(),
            isStreaming: true
        )
    }

    private func sendPlaybackStopped(for song: Song?) async {
        guard let song else { return }
        try? await apiClient.services.mediaService.playbackStopped(
            itemId: song.uuid,
            at: player.currentTime().seconds,
            playbackQueue: []
        )
    }

    private func sendPlaybackFinished(for song: Song?) async {
        guard let song else { return }
        try? await apiClient.services.mediaService.playbackFinished(itemId: song.uuid)
    }

    @objc
    private func handleInterruption(notification: Notification) {
        // swiftformat:disable elseOnSameLine
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }
        // swiftformat:enable elseOnSameLine

        switch type {
        case .began:
            Task { await pause() }
        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                Task { await resume() }
            }
        default:
            break
        }
    }

    private func getVolume() -> Int32 {
        let volume = AVAudioSession.sharedInstance().outputVolume * 100
        return Int32(volume.rounded(.toNearestOrAwayFromZero))
    }
}
