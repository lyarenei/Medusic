import Foundation
import Kingfisher
import MediaPlayer
import OSLog

extension MusicPlayer {
    internal func registerCommandHandlers() {
        let center = MPRemoteCommandCenter.shared()
        center.playCommand.addTarget(self, action: #selector(handlePlayCommand))
        center.pauseCommand.addTarget(self, action: #selector(handlePauseCommand))
        center.stopCommand.addTarget(self, action: #selector(handleStopCommand))
        center.togglePlayPauseCommand.addTarget(self, action: #selector(handlePlayPauseCommand))
        center.nextTrackCommand.addTarget(self, action: #selector(handleNextTrackCommand))
        center.previousTrackCommand.addTarget(self, action: #selector(registerPreviousTrackCommand))
    }

    @objc
    private func handlePlayCommand() -> MPRemoteCommandHandlerStatus {
        Logger.player.debug("Called play command")
        Task {
            do {
                try await self.play()
                self.setNowPlayingPlaybackMetadata(isPlaying: true)
                Logger.player.debug("Play command was successfuly executed")
            } catch {
                Logger.player.debug("Play command failed: \(error.localizedDescription)")
            }
        }

        return .success
    }

    @objc
    private func handlePauseCommand() -> MPRemoteCommandHandlerStatus {
        Logger.player.debug("Called pause command")
        Task {
            await self.pause()
            self.setNowPlayingPlaybackMetadata(isPlaying: false)
            Logger.player.debug("Pause command was successfuly executed")
        }

        return .success
    }

    @objc
    private func handleStopCommand() -> MPRemoteCommandHandlerStatus {
        Logger.player.debug("Called stop command")
        Task {
            await self.stop()
            Logger.player.debug("Stop command was successfully executed")
        }

        return .success
    }

    @objc
    private func handlePlayPauseCommand() -> MPRemoteCommandHandlerStatus {
        Logger.player.debug("Called play/pause command")
        Task {
            if self.player.rate > 0 {
                await self.pause()
                Logger.player.debug("Player is playing, pausing")
            } else {
                await self.resume()
                Logger.player.debug("Player is paused, resuming")
            }
        }

        return .success
    }

    @objc
    private func handleNextTrackCommand() -> MPRemoteCommandHandlerStatus {
        Logger.player.debug("Called next track command")
        skipForward()
        return .success
    }

    @objc
    private func registerPreviousTrackCommand() -> MPRemoteCommandHandlerStatus {
        Logger.player.debug("Called previous track command")
        skipBackward()
        return .success
    }
}
