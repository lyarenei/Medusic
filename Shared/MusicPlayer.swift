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
    var fileRepo: FileRepository

    @Published
    var currentSong: Song?

    @Published
    var isPlaying = false

    @Published
    var currentTime: TimeInterval = 0

    private var currentItemObserver: NSKeyValueObservation?

    init(
        preview: Bool = false,
        songRepo: SongRepository = .shared,
        fileRepo: FileRepository = .shared
    ) {
        self.songRepo = songRepo
        self.fileRepo = fileRepo
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

        audioSessionSetup()
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

        player.play()
        setIsPlaying(isPlaying: true)
    }

    func play(songs: [Song]) async {
        clearQueue(stopPlayback: true)
        await enqueue(songs: songs, position: .last)
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
        let remoteUrl = api.services.mediaService.getStreamUrl(item: song.uuid, bitrate: nil)

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

    private func setCurrentlyPlaying(newSong: Song?) {
        currentSong = newSong
        Logger.player.debug("Song set as currently playing: \(newSong?.uuid ?? "nil")")
    }

    private func setIsPlaying(isPlaying: Bool) {
        self.isPlaying = isPlaying
        Logger.player.debug("Player is playing: \(isPlaying)")
    }

    private func setCurrentTime(_ curTime: TimeInterval) {
        guard let songRuntime = currentSong?.runtime else { return }

        if curTime >= songRuntime {
            currentTime = songRuntime
            return
        }

        currentTime = curTime.rounded(.toNearestOrAwayFromZero)
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
            pause()
        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) { resume() }
        default:
            break
        }
    }
}
