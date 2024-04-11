import AVFoundation
import Foundation
import OSLog

extension MusicPlayerCore {
    func play(song: Song? = nil) async throws {
        if let song {
            clearQueue(stopPlayback: true)
            enqueue(song: song, position: .last)
        }

        try configureSession()
        try activateSession()
        player.play()
        await advanceInUpNext()
    }

    func play(songs: [Song]) async throws {
        if songs.isNotEmpty {
            clearQueue(stopPlayback: true)
            enqueue(songs: songs, position: .last)
        }

        try configureSession()
        try activateSession()
        player.play()
        await advanceInUpNext()
    }

    func pause() async {
        player.pause()
        await sendPlaybackProgress(for: currentSong, isPaused: true)
        setNowPlayingPlaybackMetadata(isPlaying: false)
    }

    func resume() async {
        player.play()
        await sendPlaybackProgress(for: currentSong, isPaused: false)
        setNowPlayingPlaybackMetadata(isPlaying: true)
    }

    func stop() async {
        clearQueue()
        try? deactivateSession()
        await setCurrentlyPlaying(newSong: nil)
    }

    func skipForward() {
        player.advanceToNextItem()
    }

    func skipBackward() {
        if player.currentTimeRounded < 5 {
            Task { @MainActor in
                if !skipToPreviousSong() {
                    await player.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
                }
            }
        } else {
            Task { await player.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero) }
        }
    }

    /// Skips to previous song. Returns true if skip succeeded, false otherwise.
    @MainActor
    private func skipToPreviousSong() -> Bool {
        guard let previousSong = history.last,
              let currentSong
        else {
            Logger.player.info("No song in history to skip backwards to.")
            return false
        }

        let previousItem: AVPlayerItem
        do {
            previousItem = try avItemFactory(song: previousSong)
        } catch {
            Logger.player.error("Failed to create AVPlayerItem for song: \(previousSong.id): \(error.localizedDescription)")
            return false
        }

        player.replaceCurrentItem(with: previousItem)
        enqueue(song: currentSong, position: .next)
        return true
    }
}
