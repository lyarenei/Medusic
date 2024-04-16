import Foundation

extension MusicPlayer {
    private var playerVolume: Int {
        let volume = session.outputVolume * 100
        return Int(volume.rounded(.toNearestOrAwayFromZero))
    }

    internal func sendPlaybackStarted(for song: Song?) async {
        guard let song else { return }
        try? await apiClient.services.mediaService.playbackStarted(
            itemId: song.id,
            at: player.currentTimeRounded,
            isPaused: false,
            playbackQueue: [],
            volume: playerVolume,
            isStreaming: true
        )
    }

    internal func sendPlaybackProgress(for song: Song?, isPaused: Bool) async {
        guard let song else { return }
        try? await apiClient.services.mediaService.playbackProgress(
            itemId: song.id,
            at: player.currentTimeRounded,
            isPaused: isPaused,
            playbackQueue: [],
            volume: playerVolume,
            isStreaming: true
        )
    }

    internal func sendPlaybackStopped(for song: Song?, at time: TimeInterval) async {
        guard let song else { return }
        try? await apiClient.services.mediaService.playbackStopped(
            itemId: song.id,
            at: time,
            playbackQueue: []
        )
    }

    internal func sendPlaybackFinished(for song: Song?) async {
        guard let song else { return }
        try? await apiClient.services.mediaService.markAsPlayed(itemId: song.id)
    }
}
