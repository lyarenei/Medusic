import Foundation
import Kingfisher
import MediaPlayer
import OSLog

extension MusicPlayer {
    internal func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        registerPlayCommand(commandCenter)
        registerPauseCommand(commandCenter)
        registerStopCommand(commandCenter)
        registerPlayPauseCommand(commandCenter)
        registerNextTrackCommand(commandCenter)
        registerPreviousTrackCommand(commandCenter)
    }

    private func registerPlayCommand(_ center: MPRemoteCommandCenter) {
        center.playCommand.addTarget { [weak self] _ in
            guard let self else { return .commandFailed }

            Task {
                do {
                    try await self.play()
                    self.setNowPlayingPlaybackMetadata(isPlaying: true)
                    Logger.player.debug("Called play command")
                } catch {
                    Logger.player.debug("Called play command, playback failed: \(error.localizedDescription)")
                }
            }

            return .success
        }
    }

    private func registerPauseCommand(_ center: MPRemoteCommandCenter) {
        center.pauseCommand.addTarget { [weak self] _ in
            guard let self else { return .commandFailed }

            Task {
                await self.pause()
                self.setNowPlayingPlaybackMetadata(isPlaying: false)
                Logger.player.debug("Called pause command")
            }

            return .success
        }
    }

    private func registerStopCommand(_ center: MPRemoteCommandCenter) {
        center.stopCommand.addTarget { [weak self] _ in
            guard let self else { return .commandFailed }

            Task {
                await self.stop()
                Logger.player.debug("Called stop command")
            }

            return .success
        }
    }

    private func registerPlayPauseCommand(_ center: MPRemoteCommandCenter) {
        center.togglePlayPauseCommand.addTarget { [weak self] _ in
            guard let self else { return .commandFailed }

            Task {
                if self.player.rate > 0 {
                    await self.pause()
                    Logger.player.debug("Called play/pause command, player is paused")
                } else {
                    await self.resume()
                    Logger.player.debug("Called play/pause command, player is playing")
                }

                self.setNowPlayingPlaybackMetadata(isPlaying: self.player.rate > 0)
            }

            return .success
        }
    }

    private func registerNextTrackCommand(_ center: MPRemoteCommandCenter) {
        center.nextTrackCommand.addTarget { [weak self] _ in
            guard let self else { return .commandFailed }
            Logger.player.debug("Called next track command")
            self.skipForward()
            return .success
        }
    }

    private func registerPreviousTrackCommand(_ center: MPRemoteCommandCenter) {
        center.previousTrackCommand.addTarget { [weak self] _ in
            guard let self else { return .commandFailed }
            Logger.player.debug("Called previous track command")
            self.skipBackward()
            return .success
        }
    }
}
