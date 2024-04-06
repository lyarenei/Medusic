import Foundation

extension MusicPlayerCore {
    func play(song: Song? = nil) async throws {
        if let song {
            clearQueue(stopPlayback: true)
            enqueue(song: song, position: .last)
        }

        try configureSession()
        try activateSession()
        player.play()
    }

    func play(songs: [Song]) async throws {
        if songs.isNotEmpty {
            clearQueue(stopPlayback: true)
            enqueue(songs: songs, position: .last)
        }

        try configureSession()
        try activateSession()
        player.play()
    }

    func pause() async {
        player.pause()
//        await sendPlaybackProgress(for: currentSong, isPaused: true)
        setNowPlayingPlaybackMetadata(isPlaying: false)
    }

    func resume() async {
        player.play()
//        await sendPlaybackProgress(for: currentSong, isPaused: false)
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
}
