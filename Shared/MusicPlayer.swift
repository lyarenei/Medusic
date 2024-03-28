import AVFoundation
import Combine
import Defaults
import Foundation
import Kingfisher
import MediaPlayer
import OSLog
import SwiftUI

final class AVJellyPlayerItem: AVPlayerItem {
    var song: Song?
}

final class MusicPlayer: ObservableObject {
    public static let shared = MusicPlayer()

    static let seekDelay = 0.75

    var player = AVQueuePlayer()
    let apiClient: ApiClient
    var songRepo: SongRepository
    var fileRepo: FileRepository
    var persistRepo: PersistenceRepository

    @MainActor
    @Published
    private(set) var history: [Song] = []

    /// A flag for when history shouldn't be modified by standard current song change.
    private var isHistoryRewritten = false

    var upNext: [Song] {
        player.items()
            .filter { $0 != player.currentItem }
            .compactMap { ($0 as? AVJellyPlayerItem)?.song }
    }

    @Published
    var currentSong: Song?

    @Published
    private(set) var isPlaying = false

    private var seekCancellable: Cancellable?
    private var currentItemObserver: NSKeyValueObservation?
    private var cancellables: Cancellables

    init(
        preview: Bool = false,
        songRepo: SongRepository = .shared,
        fileRepo: FileRepository = .shared,
        persistRepo: PersistenceRepository = .shared,
        apiClient: ApiClient = .shared
    ) {
        self.songRepo = songRepo
        self.fileRepo = fileRepo
        self.persistRepo = persistRepo
        self.apiClient = apiClient
        self.cancellables = []

        guard !preview else { return }

        // swiftformat:disable:next redundantSelf
        currentItemObserver = player.observe(\.currentItem, options: [.old, .new]) { [weak self] _, change in
            guard let self else { return }
            guard case .some(let currentItem)? = change.newValue,
                  let currentJellyItem = currentItem as? AVJellyPlayerItem,
                  let currentSong = currentJellyItem.song
            else {
                Task {
                    await self.setCurrentlyPlaying(newSong: nil)
                    Logger.player.info("Current song is not set, stopping")
                }
                return
            }

            Task { @MainActor in
                if case .some(let previousItem)? = change.oldValue,
                   let previousJellyItem = previousItem as? AVJellyPlayerItem,
                   let previousSong = previousJellyItem.song,
                   previousItem != currentItem {

                    if !self.isHistoryRewritten {
                        self.history.append(previousSong)
                        Logger.player.debug("Added song to history: \(currentSong.id)")
                    } else {
                        // The next song change should be reported as usual.
                        self.isHistoryRewritten = false
                    }

                    await self.sendPlaybackStopped(for: previousSong, at: previousItem.currentTime().seconds)
                    await self.sendPlaybackFinished(for: previousSong)
                }

                await self.setCurrentlyPlaying(newSong: currentSong)
                await self.sendPlaybackStarted(for: currentSong)
                self.setNowPlayingMetadata(song: currentSong)
                self.persistPlaybackQueue()
            }
        }

        audioSessionSetup()
        setupRemoteCommandCenter()

        Task { await self.restorePlaybackQueue() }
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

    private func restorePlaybackQueue() async {
        guard Defaults[.restorePlaybackQueue] else { return }
        if !apiClient.isAuthorized {
            try? await apiClient.performAuth()
        }

        let sortedQueueItems = await persistRepo.playbackQueue.sorted { $0.orderIndex < $1.orderIndex }
        for item in sortedQueueItems {
            if let song = await songRepo.getSong(by: item.songId) {
                enqueueToPlayer(song, position: .last)
            }
        }

        guard let firstQueueItem = sortedQueueItems.first else { return }
        let firstSong = await songRepo.getSong(by: firstQueueItem.songId)
        await setCurrentlyPlaying(newSong: firstSong)
    }

    // MARK: - Playback controls

    func play(song: Song? = nil) async {
        if let song {
            clearQueue(stopPlayback: true)
            enqueue(song: song, position: .last)
        }

        await player.play()
        await setIsPlaying(isPlaying: true)
    }

    func play(songs: [Song]) async {
        if songs.isNotEmpty {
            clearQueue(stopPlayback: true)
            enqueue(songs: songs, position: .last)
        }

        await player.play()
        await setIsPlaying(isPlaying: true)
    }

    @MainActor
    func playHistory(song: Song) {
        guard let historySongIndex = history.firstIndex(of: song) else {
            Logger.player.warning("Failed to find history index for song: \(song.id)")
            return
        }

        let previousSongs = Array(history.suffix(from: historySongIndex))
        guard let newCurrentSong = previousSongs.first else { return }
        let currentSong = (player.currentItem as? AVJellyPlayerItem)?.song
        history = Array(history.prefix(historySongIndex))
        isHistoryRewritten = true

        do {
            let newCurrentItem = try avItemFactory(song: newCurrentSong)
            player.replaceCurrentItem(with: newCurrentItem)
        } catch {
            Logger.player.error("Failed to create AV item for song: \(newCurrentSong.id)")
            return
        }

        enqueue(songs: previousSongs.dropFirst() + [currentSong].compactMap { $0 }, position: .next)
    }

    @MainActor
    func playUpNext(song: Song) {
        let currentJellyItems = player.items().compactMap { $0 as? AVJellyPlayerItem }
        let currentSongs = currentJellyItems.compactMap(\.song)
        guard let upNextSongIndex = currentSongs.firstIndex(of: song) else {
            Logger.player.warning("Failed to find up next index for song: \(song.id)")
            return
        }

        history += Array(currentSongs.prefix(upTo: upNextSongIndex))
        isHistoryRewritten = true

        do {
            let newCurrentSong = currentSongs[upNextSongIndex]
            let newCurrentItem = try avItemFactory(song: newCurrentSong)

            player.clearNextItems()
            player.replaceCurrentItem(with: newCurrentItem)
            try player.prepend(items: currentSongs.suffix(from: upNextSongIndex + 1).map { try avItemFactory(song: $0) })
        } catch {
            Logger.player.error("Failed to create AV item for song: \(currentSongs[upNextSongIndex].id)")
            return
        }
    }

    func seek(percent: Double) {
        guard let currentItem = player.currentItem,
              let currentJellyItem = currentItem as? AVJellyPlayerItem,
              let currentSong = currentJellyItem.song
        else { return }

        let newTime = currentSong.runtime * percent
        Logger.player.info("Seeking to \(percent)%, time \(newTime.timeString)")
        player.seek(
            to: CMTime(
                seconds: newTime,
                preferredTimescale: currentItem.currentTime().timescale
            ),
            toleranceBefore: .zero,
            toleranceAfter: .zero
        )
    }

    func seekBackward(isActive: Bool) {
        seek(forward: false, isActive: isActive)
    }

    func seekForward(isActive: Bool) {
        seek(forward: true, isActive: isActive)
    }

    private func seek(forward: Bool, isActive: Bool) {
        if isActive {
            let skipSequence = [5, 10, 20, 30, 60].flatMap { Array(repeating: $0, count: 6) }
            seekCancellable = Timer.publish(every: Self.seekDelay, on: .main, in: .default)
                .autoconnect()
                .zip(skipSequence.publisher) { $1 }
                .sink { [weak self] skipAhead in
                    guard let self else { return }
                    let currentTime = self.player.currentTime()
                    let adjustedSkipAhead = forward ? skipAhead : -skipAhead
                    self.player.seek(
                        to: CMTime(seconds: currentTime.seconds + Double(adjustedSkipAhead), preferredTimescale: currentTime.timescale),
                        toleranceBefore: .zero,
                        toleranceAfter: .zero
                    )
                }
        } else {
            seekCancellable?.cancel()
            seekCancellable = nil
        }
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

    @MainActor
    func skipBackward() {
        if history.isNotEmpty && player.currentTimeRounded < 5 {
            skipToPreviousSong()
        } else {
            Task { @MainActor in
                await player.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
            }
        }
    }

    @MainActor
    private func skipToPreviousSong() {
        guard let previousSong = history.last, let currentSong else {
            Logger.player.info("No song in history to skip backwards to.")
            return
        }
        let previousItem: AVPlayerItem
        do {
            previousItem = try avItemFactory(song: previousSong)
        } catch {
            Logger.player.error("Failed to create AVPlayerItem for song: \(previousSong.id)")
            return
        }
        player.replaceCurrentItem(with: previousItem)
        enqueue(song: currentSong, position: .next)
        history = history.dropLast(2)
    }

    // MARK: - Queuing controls

    func enqueue(song: Song, position: EnqueuePosition) {
        enqueueToPlayer(song, position: position)
        persistPlaybackQueue()
    }

    func enqueue(songs: [Song], position: EnqueuePosition) {
        enqueueToPlayer(songs, position: position)
        persistPlaybackQueue()
    }

    /// Clear playback queue. Optionally stop playback of current song.
    private func clearQueue(stopPlayback: Bool = false) {
        if stopPlayback {
            player.removeAllItems()
        } else {
            player.clearNextItems()
        }
    }

    private func enqueueToPlayer(_ songs: [Song], position: EnqueuePosition) {
        do {
            let items = try songs.map(avItemFactory(song:))
            switch position {
            case .last:
                player.append(items: items)
            case .next:
                player.prepend(items: items)
            }

            Logger.player.debug("Songs added to queue: \(songs.map(\.id))")
        } catch {
            Logger.player.error("Failed to add songs to queue: \(songs.map(\.id))")
        }
    }

    /// Enqueue a song to internal player. The song is placed at specified position.
    private func enqueueToPlayer(_ song: Song, position: EnqueuePosition) {
        do {
            let item = try avItemFactory(song: song)
            switch position {
            case .last:
                player.append(item: item)
            case .next:
                player.prepend(item: item)
            }

            Logger.player.debug("Song added to queue: \(song.id)")
        } catch {
            Logger.player.debug("Failed to add song to queue: \(song.id)")
        }
    }

    private func avItemFactory(song: Song) throws -> AVPlayerItem {
        guard let fileUrl = fileRepo.getLocalOrRemoteUrl(for: song) else {
            Logger.player.debug("Could not retrieve an URL for song \(song.id), skipping")
            throw PlayerError.songUrlNotFound
        }

        if !apiClient.isAuthorized {
            Logger.player.warning("Client is not authenticated against server, remote playback may fail!")
        }

        let headers = ["Authorization": apiClient.authHeader]
        let asset = AVURLAsset(url: fileUrl, options: ["AVURLAssetHTTPHeaderFieldsKey": headers])
        let item = AVJellyPlayerItem(asset: asset)
        item.song = song
        subscribeToError(of: item)

        return item
    }

    @MainActor
    private func setCurrentlyPlaying(newSong: Song?) async {
        currentSong = newSong
        Logger.player.debug("Song set as currently playing: \(newSong?.id ?? "nil")")
    }

    @MainActor
    private func setIsPlaying(isPlaying: Bool) {
        self.isPlaying = isPlaying
        Logger.player.debug("Player is playing: \(isPlaying)")
    }

    private func sendPlaybackStarted(for song: Song?) async {
        guard let song else { return }
        try? await apiClient.services.mediaService.playbackStarted(
            itemId: song.id,
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
            itemId: song.id,
            at: player.currentTime().seconds,
            isPaused: isPaused,
            playbackQueue: [],
            volume: getVolume(),
            isStreaming: true
        )
    }

    private func sendPlaybackStopped(for song: Song?, at time: TimeInterval) async {
        guard let song else { return }
        try? await apiClient.services.mediaService.playbackStopped(
            itemId: song.id,
            at: time,
            playbackQueue: []
        )
    }

    private func sendPlaybackFinished(for song: Song?) async {
        guard let song else { return }
        try? await apiClient.services.mediaService.markAsPlayed(itemId: song.id)
    }

    @objc
    private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue)
        else { return }

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

    private func getVolume() -> Int {
        let volume = AVAudioSession.sharedInstance().outputVolume * 100
        return Int(volume.rounded(.toNearestOrAwayFromZero))
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

        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            guard let self else { return .commandFailed }
            Task { await self.skipBackward() }
            return .success
        }

        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            guard let self else { return .commandFailed }
            self.skipForward()
            return .success
        }
    }

    private func setNowPlayingMetadata(song: Song) {
        let nowPlayingCenter = MPNowPlayingInfoCenter.default()
        var nowPlaying = nowPlayingCenter.nowPlayingInfo ?? [String: Any]()

        nowPlaying[MPMediaItemPropertyTitle] = song.name
        nowPlaying[MPMediaItemPropertyArtist] = song.artistCreditName
        nowPlaying[MPMediaItemPropertyAlbumArtist] = "album.artistName"
        nowPlaying[MPMediaItemPropertyAlbumTitle] = "album.Name"
        nowPlaying[MPMediaItemPropertyPlaybackDuration] = song.runtime

        nowPlayingCenter.nowPlayingInfo = nowPlaying

        setNowPlayingPlaybackMetadata(isPlaying: true)
        setNowPlayingArtwork(song: song)
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
        let provider = apiClient.getImageDataProvider(itemId: song.albumId)
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

    private func persistPlaybackQueue() {
        guard Defaults[.restorePlaybackQueue] else { return }
        let currentQueue = player.items().compactMap { $0 as? AVJellyPlayerItem }
        Task { await persistRepo.save(currentQueue) }
    }

    private func subscribeToError(of item: AVJellyPlayerItem) {
        item.publisher(for: \.error)
            .receive(on: DispatchQueue.global(qos: .background))
            .sink { error in
                guard let error else { return }
                Logger.player.error("Failed to play song: \(error.localizedDescription)")
                Alerts.error("Failed to play song.")
            }
            .store(in: &cancellables)
    }

    enum PlayerError: Error {
        case songUrlNotFound
    }
}
