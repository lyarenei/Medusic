import AVFoundation
import Combine
import Foundation
import OSLog
import SwiftUI

final class MusicPlayerCore: ObservableObject {
    static let shared = MusicPlayerCore()
    static let seekDelay = 0.75
    static let minPlaybackTime = 3.0

    internal let session = AVAudioSession.sharedInstance()
    internal var isSessionConfigured = false
    internal var isSessionActive = false

    internal let player = AVQueuePlayer()
    internal var apiClient: ApiClient = .shared
    internal var fileRepo: FileRepository = .shared
    internal var library: LibraryRepository = .shared

    private var playbackRateObserver: NSKeyValueObservation?
    private var currentItemObserver: NSKeyValueObservation?
    private var statusObserver: NSKeyValueObservation?
    private var waitingToPlayObserver: NSKeyValueObservation?
    internal var cancellables: Cancellables = []
    internal var seekCancellable: Cancellable?

    @Published
    @MainActor
    private(set) var isPlaying = false

    @Published
    @MainActor
    private(set) var currentSong: Song?

    // Only for user visibility, it is not used for player functionality.
    // See playback history behavior in the (Apple) Music app.
    @Published
    @MainActor
    private(set) var playbackHistory: [Song] = []

    // Used for player functionality when skipping backwards with skip button.
    var internalPlaybackHistory: [Song] = []

    @Published
    @MainActor
    private(set) var nextUpQueue: [Song] = []

    init(
        preview: Bool = false,
        apiClient: ApiClient = .shared,
        fileRepo: FileRepository = .shared,
        library: LibraryRepository = .shared
    ) {
        self.apiClient = apiClient
        self.fileRepo = fileRepo
        self.library = library

        guard !preview else { return }

        try? configureSession()

        self.playbackRateObserver = player.observe(\.rate, options: [.new]) { [weak self] _, change in
            guard let self else { return }
            if case .some(let playbackRate) = change.newValue {
                self.setNowPlayingPlaybackMetadata(isPlaying: playbackRate > 0)
                Task {
                    await self.updatePlaybackState(playbackRate)
                    await self.sendPlaybackProgress(for: self.currentSong, isPaused: playbackRate > 0)
                }
            }
        }

        self.statusObserver = player.observe(\.status, options: [.new]) { _, change in
            switch change.newValue {
            case .failed:
                Logger.player.error("Internal player reported failed state, player needs to be reset")
            case .readyToPlay:
                Logger.player.debug("Internal player is ready to play")
            case .unknown:
                Logger.player.debug("Internal player is is not actively processing audio")
            default:
                Logger.player.debug("Internal player reports unhandled status")
            }
        }

        self.waitingToPlayObserver = player.observe(\.reasonForWaitingToPlay, options: [.new]) { _, change in
            switch change.newValue {
            case .evaluatingBufferingRate:
                Logger.player.debug("Internal player is waiting for playback: evaluating buffering rate")
            case .interstitialEvent:
                Logger.player.debug("Internal player is waiting for playback: interstitial event occurred")
            case .noItemToPlay:
                Logger.player.debug("Internal player is waiting for playback: there is nothing to play")
            case .toMinimizeStalls:
                Logger.player.debug("Internal player is waiting for playback: delay to minimize stalling")
            case .waitingForCoordinatedPlayback:
                Logger.player.debug("Internal player is waiting for playback: waiting for coordinated playback")
            default:
                Logger.player.debug("Internal player is no longer waiting for playback")
            }
        }

//        player.actionAtItemEnd
//        player.error
//        player.timeControlStatus

        self.currentItemObserver = player.observe(\.currentItem, options: [.old, .new]) { [weak self] _, change in
            guard let self else { return }

            let previousJellyItem = change.oldValue as? AVJellyPlayerItem
            let previousSong = previousJellyItem?.song

            let nextJellyItem = change.newValue as? AVJellyPlayerItem
            let nextSong = nextJellyItem?.song

            Task {
                await self.handleSongChange(
                    previous: previousSong,
                    atTime: previousJellyItem?.currentTime().seconds ?? 0,
                    next: nextSong
                )
            }
        }
    }

    deinit {
        try? deactivateSession()
    }

    @MainActor
    internal func updatePlaybackState(_ playbackRate: Float) {
        isPlaying = playbackRate > 0
        Logger.player.debug("Player is currently playing: \(playbackRate > 0)")
    }

    @MainActor
    internal func setCurrentlyPlaying(newSong: Song?) {
        currentSong = newSong
    }

    @MainActor
    internal func appendToHistory(_ song: Song) {
        playbackHistory.append(song)
        internalPlaybackHistory.append(song)
        Logger.player.debug("Song added to playback history: \(song.id)")
    }

    @MainActor
    internal func updateQueue() {
        Logger.player.debug("Updating player queue...")
        nextUpQueue = player.items().dropFirst().compactMap { avItem in
            if let id = avItem.songId {
                return library.songs.by(id: id)
            }

            return nil
        }
    }

    internal func configureSession() throws {
        guard isSessionConfigured == false else {
            Logger.player.debug("Audio session is already configured, skipping")
            return
        }

        do {
            try session.setCategory(.playback, mode: .default, options: [])
            isSessionConfigured = true
            Logger.player.debug("Audio session has been configured")
        } catch {
            isSessionConfigured = false
            Logger.player.debug("Failed to set up audio session: \(error.localizedDescription)")
            throw error
        }
    }

    internal func activateSession() throws {
        guard !isSessionActive else {
            Logger.player.debug("Audio session is already active, skipping")
            return
        }

        do {
            try session.setActive(true)
            isSessionActive = true

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleInterruption),
                name: AVAudioSession.interruptionNotification,
                object: AVAudioSession.sharedInstance()
            )

            Task { @MainActor in
                UIApplication.shared.beginReceivingRemoteControlEvents()
            }

            Logger.player.debug("Audio session has been activated")
        } catch {
            Logger.player.warning("Audio session was not activated: \(error.localizedDescription)")
            throw error
        }
    }

    internal func deactivateSession() throws {
        guard isSessionActive else {
            Logger.player.debug("Audio session is already deactivated, skipping")
            return
        }

        do {
            try session.setActive(false)
            isSessionActive = false

            NotificationCenter.default.removeObserver(
                self,
                name: AVAudioSession.interruptionNotification,
                object: AVAudioSession.sharedInstance()
            )

            Task { @MainActor in
                UIApplication.shared.endReceivingRemoteControlEvents()
            }

            Logger.player.debug("Audio session has been deactivated")
        } catch {
            Logger.player.warning("Audio session was not deactivated: \(error.localizedDescription)")
        }
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

    @objc
    private nonisolated func handleInterruption(notification: Notification) {
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

    private func handleSongChange(previous: Song?, atTime: TimeInterval, next: Song?) async {
        Logger.player.debug("Currently played AV item has changed, processing change...")
        if let previous {
            await sendPlaybackStopped(for: previous, at: atTime)
            await sendPlaybackFinished(for: previous)

            // It may not probably be worth it to register in history
            if atTime > MusicPlayerCore.minPlaybackTime {
                await appendToHistory(previous)
            }
        }

        await setCurrentlyPlaying(newSong: next)
        await updateQueue()

        if let next {
            // TODO: move above when support for erasing is available
            setNowPlayingMetadata(song: next)
            await sendPlaybackStarted(for: next)
        } else {
            try? deactivateSession()
        }
    }
}
