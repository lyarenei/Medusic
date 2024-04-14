import AVFoundation
import Foundation
import OSLog

extension MusicPlayer {
    /// Seek in a current track to specified percent.
    func seek(to percent: Double) {
        guard let currentItem = player.currentItem,
              let currentJellyItem = currentItem as? AVJellyPlayerItem,
              let currentSong = currentJellyItem.song
        else { return }

        let newTime = currentSong.runtime * percent
        Logger.player.info("Seeking to \(newTime.timeString) (\(percent * 100)%)")
        player.seek(
            to: CMTime(seconds: newTime, preferredTimescale: currentItem.currentTime().timescale),
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
        guard isActive else {
            seekCancellable?.cancel()
            seekCancellable = nil
            return
        }

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
                    toleranceBefore: .init(seconds: 0.3, preferredTimescale: currentTime.timescale),
                    toleranceAfter: .init(seconds: 0.3, preferredTimescale: currentTime.timescale)
                )
            }
    }
}
