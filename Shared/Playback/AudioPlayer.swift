import AVFoundation
import Combine
import Foundation
import OSLog

enum PlayerState: String {
    case inactive, playing, paused
}

enum PlayerError: Error {
    case tempFileError, noData(itemId: String)
}

final class AudioPlayer: ObservableObject {
    @Published
    var playerState: PlayerState = .inactive

    @Published
    var currentTime: TimeInterval = 0

    private let audioEngine = AVAudioEngine()
    private var playerNode = AVAudioPlayerNode()
    private var playbackTimer: Timer?
    private var trackStartTime: TimeInterval = 0
    var delegate: MusicPlayerDelegate?

    init() {
        audioEngineSetup()

        // Set interruption handler
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
    }

    private func audioEngineSetup() {
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: nil)
        audioEngine.prepare()
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )
            try session.setActive(true)
            Logger.player.debug("Audio engine has been initialized")
        } catch {
            Logger.player.debug("Failed to initialize audio engine: \(error.localizedDescription)")
        }
    }

    func play(song: Song) async throws {
        try await scheduleNext(song: song)
        resume()
    }

    func pause() {
        playerNode.pause()
        audioEngine.pause()
        playerState = .paused
        stopPlaybackTimer()
        Logger.player.debug("Player is paused")
    }

    func resume() {
        try? audioEngine.start()
        playerNode.play()
        playerState = .playing
        Task { await startPlaybackTimer() }
        Logger.player.debug("Player is playing")
    }

    func stop() {
        playerNode.stop()
        playerNode.reset()
        audioEngine.stop()
        playerState = .inactive
        stopPlaybackTimer()
        resetTime()
        Logger.player.debug("Player is inactive")
    }

    func skipToNext(song: Song) async throws {
        Logger.player.debug("Requested skip to next song: \(song.uuid)")
        playerNode.stop()
        playerNode.reset()
        resetTime()
        try await play(song: song)
    }

    func resetTimeForNextSong() {
        self.trackStartTime = self.currentTime
        self.currentTime = 0
    }

    private func resetTime() {
        currentTime = 0
        trackStartTime = 0
    }

    private func scheduleNext(song: Song) async throws {
        Logger.player.debug("Next song will be played: \(song.uuid)")
        let audioFile = try await getItemAudioFile(by: song.uuid)
        playerNode.scheduleFile(audioFile, at: nil) {
            Task(priority: .background) {
                if let nextSong = await self.delegate?.getNextSong() {
                    try await self.play(song: nextSong)
                }
            }
        }
    }

    /// Handles interruption from a call or Siri
    @objc
    private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }

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

    private func getItemAudioFile(by itemId: String) async throws -> AVAudioFile {
        guard let url = FileRepository.shared.fileURL(for: itemId) else {
            throw PlayerError.noData(itemId: itemId)
        }

        do {
            return try AVAudioFile(forReading: url)
        } catch {
            Logger.player.debug("Failed to create file for playback: \(error)")
            throw PlayerError.tempFileError
        }
    }

    private func startPlaybackTimer() async {
        Logger.player.debug("Starting playback timer")
        await MainActor.run {
            // Note: Not using CADisplayLink becasue:
            // 1) It would result in too smooth updates for the seek bar (every 1s is preferable)
            // 2) Is not available for macOS (there is CVDisplayLink, but the above point still stands)
            playbackTimer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
                guard let self else { return }
                if let lastRenderTime = self.playerNode.lastRenderTime,
                   let playerTime = self.playerNode.playerTime(forNodeTime: lastRenderTime) {
                    let currentTime = Double(playerTime.sampleTime) / playerTime.sampleRate
                    self.currentTime = currentTime - self.trackStartTime
                }
            }

            RunLoop.current.add(playbackTimer!, forMode: .common)
        }
    }

    private func stopPlaybackTimer() {
        Logger.player.debug("Stopping playback timer")
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
}
