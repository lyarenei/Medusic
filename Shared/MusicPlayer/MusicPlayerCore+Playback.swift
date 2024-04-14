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

        // swiftformat:disable:next redundantSelf
        let isPlaying = await self.isPlaying
        if await currentSong != nil && isPlaying {
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

    // Remeber that internal player queue has currently playing item at [0],
    // so everything in there is off by one comapred to what's shown in the UI.
    func skip(to index: Int) async {
        player.clearNextItems(upTo: index)
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
        guard let previousSong = internalPlaybackHistory.popLast() else {
            Logger.player.debug("History queue is empty, cannot skip backwards")
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

        if let currentSong {
            enqueue(song: currentSong, position: .next)
        }

        return true
    }
}