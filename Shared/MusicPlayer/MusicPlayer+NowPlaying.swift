import Foundation
import Kingfisher
import MediaPlayer
import OSLog

extension MusicPlayer {
    // TODO: support erasing
    internal func setNowPlayingMetadata(song: Song) {
        let nowPlayingCenter = MPNowPlayingInfoCenter.default()
        var nowPlaying = nowPlayingCenter.nowPlayingInfo ?? [String: Any]()

        nowPlaying[MPMediaItemPropertyTitle] = song.name
        nowPlaying[MPMediaItemPropertyArtist] = song.artistCreditName
        nowPlaying[MPMediaItemPropertyAlbumArtist] = "album.artistName"
        nowPlaying[MPMediaItemPropertyAlbumTitle] = "album.Name"
        nowPlaying[MPMediaItemPropertyPlaybackDuration] = song.runtime

        nowPlayingCenter.nowPlayingInfo = nowPlaying

        setNowPlayingPlaybackMetadata(isPlaying: true)
        setNowPlayingArtwork(song: song)
    }

    internal func setNowPlayingPlaybackMetadata(isPlaying: Bool, elapsedTime: TimeInterval? = nil) {
        let nowPlayingCenter = MPNowPlayingInfoCenter.default()
        var nowPlaying = nowPlayingCenter.nowPlayingInfo ?? [String: Any]()

        nowPlaying[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime ?? player.currentTimeRounded
        nowPlaying[MPNowPlayingInfoPropertyPlaybackRate] = NSNumber(value: isPlaying ? 1 : 0)
        nowPlaying[MPNowPlayingInfoPropertyMediaType] = NSNumber(value: MPNowPlayingInfoMediaType.audio.rawValue)

        nowPlayingCenter.nowPlayingInfo = nowPlaying
    }

    private func setNowPlayingArtwork(song: Song) {
        let provider = apiClient.getImageDataProvider(itemId: song.albumId)
        let nowPlayingCenter = MPNowPlayingInfoCenter.default()
        var nowPlaying = nowPlayingCenter.nowPlayingInfo ?? [String: Any]()

        KingfisherManager.shared.retrieveImage(with: .provider(provider)) { result in
            do {
                let imageResult = try result.get()
                let artwork = MPMediaItemArtwork(boundsSize: imageResult.image.size) { _ in
                    imageResult.image
                }

                nowPlaying[MPMediaItemPropertyArtwork] = artwork
                nowPlayingCenter.nowPlayingInfo = nowPlaying
            } catch {
                Logger.artwork.debug("Failed to retrieve artwork for now playing info: \(error.localizedDescription)")
            }
        }
    }
}
