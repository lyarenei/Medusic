import AVFoundation
import Combine
import Foundation

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
    private let mediaRepo: MediaRepository

    init(mediaRepo: MediaRepository = .shared) {
        self.mediaRepo = mediaRepo
        audioEngineSetup()

        // Set interruption handler
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification, object: nil
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
                options: [
                    .allowAirPlay,
                    .allowBluetooth,
                    .allowBluetoothA2DP,
                    .mixWithOthers,
                ]
            )
            try session.setActive(true)
        } catch {
            print("Failed to initialize audio engine: \(error)")
        }
    }

    func play() async throws {
        switch playerState {
        case .inactive, .paused:
            print("player is inactive or paused")
            if queue.isEmpty { throw PlayerError.emptyQueue }
            if playerState == .inactive {
                print("player is inactive")
                currentItemId = queue.removeFirst()
                audioFile = try await getItemAudioFile(by: currentItemId!)
                print("fetched audio data for playback for next item in queue \(currentItemId!)")
            }

            scheduleAudio()

            try? audioEngine.start()
            playerNode.play()
            playerState = .playing
            print("player is playing")
        default:
            scheduleAudio()
        }
    }

    func pause() {
        if playerState == .playing {
            print("player is playing")
            playerNode.pause()
            playerState = .paused
        }
        print("player is paused")
    }

    func resume() {
        if playerState == .paused {
            print("player is paused")
            playerNode.play()
            playerState = .playing
        }
        print("player is playing")
    }

    func stop() {
        if playerState != .inactive {
            print("player is playing or paused")
            playerNode.stop()
            playerNode.reset()
            playerState = .inactive
        }
        print("player is inactive")
    }

    func skipToNext() async throws {
        if queue.isEmpty { throw PlayerError.emptyQueue }
        playerNode.stop()
        try await playNextItem()
    }

    func insertItem(_ itemID: String, at index: Int) {
        print("current queue: \(queue)")
        print("appending item: \(itemID)")
        queue.insert(itemID, at: index)
        print("current queue now: \(queue)")
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
        print("current queue: \(queue)")
        print("appending item: \(itemId)")
        queue.append(itemId)
        print("current queue now: \(queue)")
    }

    func append(itemIds: [String]) {
        queue.append(contentsOf: itemIds)
    }

    private func playNextItem() async throws {
        print("current queue: \(queue)")
        if queue.isEmpty {
            throw PlayerError.emptyQueue
        } else {
            currentItemId = queue.removeFirst()
            print("current queue after removed: \(queue)")
            audioFile = try await getItemAudioFile(by: currentItemId!)
            print("got data for item: \(currentItemId)")
            Task(priority: .userInitiated) { try await self.play() }
        }
    }

    private func scheduleAudio() {
        print("scheduling audio file to play")
        // Xcode suggestion is for iOS 15
        playerNode.scheduleFile(audioFile!, at: nil) {
            Task(priority: .background) { try await self.playNextItem() }
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
            if options.contains(.shouldResume) {
                resume()
            }
        default:
            break
        }
    }

    private func getItemAudioFile(by itemID: String) async throws -> AVAudioFile? {
        guard let audioData = await self.mediaRepo.getItem(by: itemID) else {
            throw PlayerError.noData(itemId: itemID)
        }

        do {
            let temporaryURL = try writeToTemporaryFile(data: audioData.data)
            let audioFile = try AVAudioFile(forReading: temporaryURL)
            try FileManager.default.removeItem(at: temporaryURL)
            return audioFile
        } catch {
            print("Failed create temporary file for playback: \(error)")
            throw PlayerError.tempFileError
        }
    }

    private func writeToTemporaryFile(data: Data) throws -> URL {
        let temporaryURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try data.write(to: temporaryURL, options: .atomic)
        return temporaryURL
    }
}
