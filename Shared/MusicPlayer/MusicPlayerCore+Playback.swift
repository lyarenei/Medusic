import AVFoundation
import Foundation
import OSLog

extension MusicPlayerCore {
    func play(song: Song? = nil) async throws {
        if let song {
            try await play(songs: [song])
            return
        }

        try configureSession()
        try activateSession()

        player.play()
    }

    func play(songs: [Song]) async throws {
        try configureSession()
        try activateSession()

        if songs.isNotEmpty {
            clearQueue(stopPlayback: false)
            enqueue(songs: songs, position: .last)
        }

        if await currentSong != nil {
            player.advanceToNextItem()
        }

        player.play()
    }

    func pause() async {
        player.pause()
    }

    func resume() async {
        player.play()
    }

    func stop() async {
        clearQueue(stopPlayback: true)
        try? deactivateSession()
    }

    func skip(to index: Int) async {
        // Advance will take care of the - 1
        player.clearNextItems(upTo: index - 1)
        player.advanceToNextItem()
    }

    func skipForward() {
        player.advanceToNextItem()
    }

    func skipBackward() {
        if player.currentTimeRounded < MusicPlayerCore.minPlaybackTime {
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
//        TODO: reimplement
//        guard queueIndex > 0 else {
//            Logger.player.info("No song in history to skip backwards to.")
//            return false
//        }
//
//        let previousSong = playbackQueue[queueIndex - 1]
//        let currentSong = playbackQueue[queueIndex]
//        let previousItem: AVPlayerItem
//
//        do {
//            previousItem = try avItemFactory(song: previousSong)
//        } catch {
//            Logger.player.error("Failed to create AVPlayerItem for song: \(previousSong.id): \(error.localizedDescription)")
//            return false
//        }
//
//        player.replaceCurrentItem(with: previousItem)
//        enqueue(song: currentSong, position: .next)
        return true
    }
}
