import AVFoundation
import Combine
import Foundation
import OSLog

enum PlayerState: String {
    case inactive, playing, paused
}

enum PlayerError: Error {
    case emptyQueue, tempFileError, noData(itemId: String)
}

class AudioPlayer: ObservableObject {
    @Published
    var playerState: PlayerState = .inactive

    @Published
    var queue: [String] = []

    @Published
    var currentItemId: String?

    private let audioEngine = AVAudioEngine()
    private var playerNode = AVAudioPlayerNode()
    private var audioFile: AVAudioFile?

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

    func play() async throws {
        switch playerState {
        case .inactive, .paused:
            Logger.player.debug("Player is inactive or paused")
            if queue.isEmpty { throw PlayerError.emptyQueue }
            if playerState == .inactive {
                Logger.player.debug("Player is inactive")
                currentItemId = queue.removeFirst()
                Logger.player.debug("Fetching audio data for next item in queue \(self.currentItemId ?? "no-id")")
                audioFile = try await getItemAudioFile(by: currentItemId!)
            }

            scheduleAudio()

            try? audioEngine.start()
            playerNode.play()
            playerState = .playing
            Logger.player.debug("Player is playing")
        default:
            scheduleAudio()
        }
    }

    func pause() {
        playerNode.pause()
        audioEngine.pause()
        playerState = .paused
        Logger.player.debug("Player is paused")
    }

    func resume() {
        try? audioEngine.start()
        playerNode.play()
        playerState = .playing
        Logger.player.debug("Player is playing")
    }

    func stop() {
        playerNode.stop()
        playerNode.reset()
        audioEngine.stop()
        playerState = .inactive
        queue.removeAll()
        Logger.player.debug("Player is inactive")
    }

    func skipToNext() async throws {
        try await playNextItem()
    }

    func insertItem(_ itemID: String, at index: Int) {
        Logger.player.debug("Adding item to queue: \(itemID)")
        queue.insert(itemID, at: index)
        Logger.player.debug("Current queue: \(self.queue)")
    }

    func insertItems(_ itemIds: [String], at index: Int) {
        queue.insert(contentsOf: itemIds, at: index)
    }

    func removeItem(at index: Int) {
        if index >= 0 && index < queue.count {
            queue.remove(at: index)
        }
    }

    func append(itemId: String) {
        Logger.player.debug("Adding item to queue: \(itemId)")
        queue.append(itemId)
        Logger.player.debug("Current queue: \(self.queue)")
    }

    func append(itemIds: [String]) {
        queue.append(contentsOf: itemIds)
    }

    private func playNextItem() async throws {
        if queue.isEmpty {
            stop()
            throw PlayerError.emptyQueue
        } else {
            currentItemId = queue.removeFirst()
            Logger.player.debug("Next item will be played: \(self.currentItemId ?? "no-id")")
            Logger.player.debug("Current queue: \(self.queue)")
            audioFile = try await getItemAudioFile(by: currentItemId!)
            Task(priority: .userInitiated) { try await self.play() }
        }
    }

    private func scheduleAudio() {
        Logger.player.debug("Scheduling audio file to play")
        // Xcode suggestion is for iOS 15
        playerNode.scheduleFile(audioFile!, at: nil) {
            Task(priority: .background) { try await self.playNextItem() }
        }
    }

    /// Handles interruption from a call or Siri
    @objc private func handleInterruption(notification: Notification) {
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

    private func getItemAudioFile(by itemID: String) async throws -> AVAudioFile? {
        guard let url = FileRepository.shared.fileURL(for: itemID) else {
            throw PlayerError.noData(itemId: itemID)
        }

        do {
            return try AVAudioFile(forReading: url)
        } catch {
            Logger.player.debug("Failed to create file for playback: \(error)")
            throw PlayerError.tempFileError
        }
    }
}
