import AVFoundation
import Foundation
import Kingfisher
import MediaPlayer
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
                    self.setNowPlayingMetadata()
                } else {
                    await self.setCurrentlyPlaying(newSong: nil)
                }
            }
        }

        audioSessionSetup()
        setupRemoteCommandCenter()
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
                options: []
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
        setNowPlayingPlaybackMetadata(isPlaying: false)
    }

    func resume() async {
        await player.play()
        await setIsPlaying(isPlaying: true)
        await sendPlaybackProgress(for: currentSong, isPaused: false)
        setNowPlayingPlaybackMetadata(isPlaying: true)
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
        guard let fileUrl = fileRepo.getLocalOrRemoteUrl(for: song) else {
            Logger.player.debug("Could not retrieve an URL for song \(song.uuid), skipping")
            return
        }

        let headers = ["Authorization": apiClient.services.systemService.authorizationHeader]
        let asset = AVURLAsset(url: fileUrl, options: ["AVURLAssetHTTPHeaderFieldsKey": headers])
        let item = AVPlayerItem(asset: asset)
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

    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget { [weak self] _ in
            guard let self else { return .commandFailed }
            self.setNowPlayingPlaybackMetadata(isPlaying: true)
            Task { await self.play() }
            return .success
        }

        commandCenter.pauseCommand.addTarget { [weak self] _ in
            guard let self else { return .commandFailed }
            self.setNowPlayingPlaybackMetadata(isPlaying: false)
            Task { await self.pause() }
            return .success
        }

        commandCenter.stopCommand.addTarget { [weak self] _ in
            guard let self else { return .commandFailed }
            Task { await self.stop() }
            return .success
        }

        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            guard let self else { return .commandFailed }
            self.setNowPlayingPlaybackMetadata(isPlaying: self.isPlaying)
            Task {
                if self.isPlaying {
                    await self.pause()
                } else {
                    await self.resume()
                }
            }

            return .success
        }

        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            guard let self else { return .commandFailed }
            self.skipForward()
            return .success
        }
    }

    private func setNowPlayingMetadata() {
        guard let currentSong else { return }
        let nowPlayingCenter = MPNowPlayingInfoCenter.default()
        var nowPlaying = nowPlayingCenter.nowPlayingInfo ?? [String: Any]()

        nowPlaying[MPMediaItemPropertyTitle] = currentSong.name
        nowPlaying[MPMediaItemPropertyArtist] = "song.artistName"
        nowPlaying[MPMediaItemPropertyAlbumArtist] = "album.artistName"
        nowPlaying[MPMediaItemPropertyAlbumTitle] = "album.Name"
        nowPlaying[MPMediaItemPropertyPlaybackDuration] = currentSong.runtime

        nowPlayingCenter.nowPlayingInfo = nowPlaying

        setNowPlayingPlaybackMetadata(isPlaying: true)
        setNowPlayingArtwork(song: currentSong)
    }

    private func setNowPlayingPlaybackMetadata(isPlaying: Bool) {
        let nowPlayingCenter = MPNowPlayingInfoCenter.default()
        var nowPlaying = nowPlayingCenter.nowPlayingInfo ?? [String: Any]()

        nowPlaying[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTimeRounded
        nowPlaying[MPNowPlayingInfoPropertyPlaybackRate] = NSNumber(value: isPlaying ? 1 : 0)
        nowPlaying[MPNowPlayingInfoPropertyMediaType] = NSNumber(value: MPNowPlayingInfoMediaType.audio.rawValue)

        nowPlayingCenter.nowPlayingInfo = nowPlaying
    }

    private func setNowPlayingArtwork(song: Song) {
        let provider = apiClient.getImageDataProvider(itemId: song.parentId)
        let nowPlayingCenter = MPNowPlayingInfoCenter.default()
        var nowPlaying = nowPlayingCenter.nowPlayingInfo ?? [String: Any]()

        KingfisherManager.shared.retrieveImage(with: .provider(provider)) { result in
            do {
                let imageResult = try result.get()
                let artwork = MPMediaItemArtwork(boundsSize: imageResult.image.size) { _ in
                    imageResult.image
                }

                nowPlaying[MPMediaItemPropertyArtwork] = artwork
                nowPlayingCenter.nowPlayingInfo = nowPlaying
            } catch {
                Logger.artwork.debug("Failed to retrieve artwork for now playing info: \(error.localizedDescription)")
            }
        }
    }
}
