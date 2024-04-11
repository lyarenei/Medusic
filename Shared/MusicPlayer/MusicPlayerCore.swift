import AVFoundation
import Foundation
import OSLog
import SwiftUI

final class MusicPlayerCore: ObservableObject {
    static let shared = MusicPlayerCore()
    static let seekDelay = 0.75

    internal let session = AVAudioSession.sharedInstance()
    internal var isSessionConfigured = false
    internal var isSessionActive = false

    internal let player = AVQueuePlayer()
    internal var apiClient: ApiClient = .shared
    internal var fileRepo: FileRepository = .shared

    private var playbackRateObserver: NSKeyValueObservation?
    private var currentItemObserver: NSKeyValueObservation?
    internal var cancellables: Cancellables = []

    @Published
    @MainActor
    private(set) var isPlaying = false

    @Published
    @MainActor
    private(set) var currentSong: Song?

    @Published
    @MainActor
    private(set) var upNext: [Song] = []

    @Published
    @MainActor
    private(set) var history: [Song] = []

    init(
        preview: Bool = false,
        apiClient: ApiClient = .shared,
        fileRepo: FileRepository = .shared
    ) {
        self.apiClient = apiClient
        self.fileRepo = fileRepo

        guard !preview else { return }

        try? configureSession()

        // swiftformat:disable:next redundantSelf
        playbackRateObserver = player.observe(\.rate, options: [.new]) { [weak self] _, change in
            guard let self else { return }
            if case .some(let playbackRate) = change.newValue {
                Task { await self.updatePlaybackState(playbackRate) }
            }
        }

//        player.actionAtItemEnd
//        player.error
//        player.reasonForWaitingToPlay
//        player.status
//        player.timeControlStatus

        // swiftformat:disable:next redundantSelf
        self.currentItemObserver = player.observe(\.currentItem, options: [.old, .new]) { [weak self] _, change in
            guard let self else { return }
            if case .some(let previousItem)? = change.oldValue,
               let previousJellyItem = previousItem as? AVJellyPlayerItem,
               let previousSong = previousJellyItem.song {
                Task {
                    await self.sendPlaybackStopped(for: previousSong, at: previousItem.currentTime().seconds)
                    await self.sendPlaybackFinished(for: previousSong)
                }

                Task { await self.appendToHistory(previousSong) }
                Logger.player.debug("Added song to history: \(previousSong.id)")
            }

            guard case .some(let nextItem)? = change.newValue,
                  let nextJellyItem = nextItem as? AVJellyPlayerItem,
                  let nextSong = nextJellyItem.song
            else {
                Task { await self.setCurrentlyPlaying(newSong: nil) }
                try? deactivateSession()
                return
            }

            Task {
                await self.sendPlaybackStarted(for: nextSong)
                await self.setCurrentlyPlaying(newSong: nextSong)
            }

            self.setNowPlayingMetadata(song: nextSong)
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
        Logger.player.debug("Song set as currently playing: \(newSong?.id ?? "none")")
    }

    @MainActor
    internal func appendToHistory(_ song: Song) {
        history.append(song)
        Logger.player.debug("Song added to playback history: \(song.id)")
    }

    internal func configureSession() throws {
        guard isSessionConfigured == false else { return }
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
        guard !isSessionActive else { return }
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
        guard isSessionActive else { return }
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
            debugPrint()
//            Task { await pause() }
        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
//                Task { await resume() }
            }
        default:
            break
        }
    }
}
