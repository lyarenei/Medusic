import AVFoundation
import Combine
import Foundation
import SwiftUI

private struct MediaPlayerEnvironmentKey: EnvironmentKey {
    static let defaultValue: MusicPlayer = .init()
}

extension EnvironmentValues {
    var musicPlayer: MusicPlayer {
        get { self[MediaPlayerEnvironmentKey.self] }
        set { self[MediaPlayerEnvironmentKey.self] = newValue }
    }
}

class MusicPlayer: NSObject, AVAudioPlayerDelegate, ObservableObject {
    static let shared = MusicPlayer()

    @Environment(\.albumRepo)
    private var albumRepo: AlbumRepository

    @Environment(\.songRepo)
    private var songRepo: SongRepository

    @Environment(\.mediaRepo)
    private var mediaRepo: MediaRepository

    @Published
//    var currentSong: Song? = nil
    var currentSong: Song? = Song(uuid: "1", index: 1, name: "Random song name", parentId: "1")
    private var currentlyPlayingFile: AVAudioFile?
    private var currentIndex = 0

    @Published
    var currentPlaybackPosition: TimeInterval = 0

    @Published
    var currentTrackDuration: TimeInterval = 0

    @Published
    var isPlaying: Bool = false

    @Published
    var audioQueue: [String] = []

    @Published
    var playbackHistory: [String] = []


    private var audioEngine = AVAudioEngine()
    private var audioPlayerNode = AVAudioPlayerNode()

    override init() {
        super.init()
        audioEngineSetup()
        interruptionHandlingSetup()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: nil)
    }

    private func audioEngineSetup() {
        audioEngine.attach(audioPlayerNode)
        audioEngine.connect(audioPlayerNode, to: audioEngine.mainMixerNode, format: nil)
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
            try audioEngine.start()
        } catch {
            print("Error: \(error)")
        }
    }

    // MARK: - Playback controls

    func enqueue(trackID: String) async {
        audioQueue.append(trackID)
        if audioQueue.count == 1 {
            await loadAndPlayNextTrack()
        }
    }

    func dequeue() -> String? {
        return audioQueue.isEmpty ? nil : audioQueue.removeFirst()
    }

    func play() {
        audioPlayerNode.play()
        self.isPlaying = true
    }

    func pause() {
        audioPlayerNode.pause()
        self.isPlaying = false
    }

    func stop() {
        audioPlayerNode.stop()
        audioQueue.removeAll()
        currentIndex = 0
        stopUpdatingPlaybackPosition()
        Task { await onStopPlayback?() }
    }

    func skipForward() async {
        if currentIndex + 1 < audioQueue.count {
            currentIndex += 1
            await loadAndPlayNextTrack()
        }
    }

    func skipBackward() async {
        if currentIndex > 0 {
            currentIndex -= 1
            await loadAndPlayNextTrack()
        }
    }

    func reorderQueue(fromIndex: Int, toIndex: Int) {
        guard fromIndex >= 0 && toIndex >= 0 && fromIndex < audioQueue.count && toIndex < audioQueue.count else {
            return
        }
        let trackID = audioQueue.remove(at: fromIndex)
        audioQueue.insert(trackID, at: toIndex)
    }

    func playTrackFromHistory(index: Int) async {
        guard index >= 0 && index < playbackHistory.count else { return }
        let trackID = playbackHistory[index]
        await loadAndPlay(trackID: trackID)
    }

    private func loadAndPlayNextTrack() async {
        if let trackID = dequeue() {
            if let song = await songRepo.getSong(by: trackID) {
                currentSong = song
                await loadAndPlay(trackID: trackID)
            }
        }
    }

    // MARK: - Internals

    private func loadAndPlay(trackID: String) async {
        await onTrackStart?()

        if let audioData = await self.mediaRepo.getItem(by: trackID) {
            do {
                let temporaryURL = try writeToTemporaryFile(data: audioData.data)
                let audioFile = try AVAudioFile(forReading: temporaryURL)
                try FileManager.default.removeItem(at: temporaryURL)

                // Xcode complains about alternative function - this is iOS 15 stuff, so ignore
                audioPlayerNode.scheduleFile(audioFile, at: nil) { Task {
                        self.playbackHistory.append(audioFile.url.absoluteString)
                        await self.loadAndPlayNextTrack()
                }}

                await onBeforeNextTrack?()

                let sampleRate = audioFile.processingFormat.sampleRate
                DispatchQueue.main.async {
                    self.currentTrackDuration = Double(audioFile.length) / sampleRate
                }

                currentlyPlayingFile = audioFile
                startUpdatingPlaybackPosition()
            } catch {
                print("Failed create temporary file for playback: \(error)")
            }
        } else {
            print("Failed to load track data")
        }
    }

    private func writeToTemporaryFile(data: Data) throws -> URL {
        let temporaryURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try data.write(to: temporaryURL, options: .atomic)
        return temporaryURL
    }

    // MARK: - Hooks for additional integration

    private var onTrackStart: (() async -> Void)?
    func setOnTrackStart(_ closure: (() async -> Void)?) {
        onTrackStart = closure
    }

    private var onBeforeNextTrack: (() async -> Void)?
    func setOnBeforeNextTrack(_ closure: (() async -> Void)?) {
        onBeforeNextTrack = closure
    }

    private var onStopPlayback: (() async -> Void)?
    func setOnStopPlayback(_ closure: (() async -> Void)?) {
        onStopPlayback = closure
    }

    // MARK: - Seeking support

    private var playbackPositionUpdateTimer: AnyCancellable?

    private func startUpdatingPlaybackPosition() {
        playbackPositionUpdateTimer = Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.updatePlaybackPosition()
            }
    }

    private func stopUpdatingPlaybackPosition() {
        playbackPositionUpdateTimer?.cancel()
        playbackPositionUpdateTimer = nil
    }

    private func updatePlaybackPosition() {
        guard let audioFile = currentlyPlayingFile else { return }
        let sampleRate = audioFile.processingFormat.sampleRate
        let sampleTime = audioPlayerNode.lastRenderTime?.sampleTime ?? 0
        let nodeTime = audioPlayerNode.playerTime(forNodeTime: audioPlayerNode.lastRenderTime!) ?? AVAudioTime(sampleTime: 0, atRate: sampleRate)

        let currentTime = Double(nodeTime.sampleTime) / sampleRate
        currentPlaybackPosition = currentTime
    }

    func seek(to position: TimeInterval) {
        guard let audioFile = self.currentlyPlayingFile else { return }
        let sampleRate = audioFile.processingFormat.sampleRate
        let sampleTime = AVAudioFramePosition(position * sampleRate)
        let time = AVAudioTime(sampleTime: sampleTime, atRate: sampleRate)

        audioPlayerNode.stop()
        audioPlayerNode.scheduleFile(audioFile, at: time) {
            Task {
                self.playbackHistory.append(audioFile.url.absoluteString)
                await self.loadAndPlayNextTrack()
            }
        }
        audioPlayerNode.play()

        currentPlaybackPosition = position
    }

    // MARK: - Handle session interrupts such as incoming call or Siri

    private func interruptionHandlingSetup() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleAudioSessionInterruption), name: AVAudioSession.interruptionNotification, object: nil)
    }

    @objc private func handleAudioSessionInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        switch type {
        case .began:
            // Interruption began, pause playback
            pause()
        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)

            if options.contains(.shouldResume) {
                // Interruption ended, resume playback
                play()
            }
        default:
            break
        }
    }
}
