import SFSafeSymbols
import SwiftUI

struct PlayButton: View {
    @ObservedObject
    var player: MusicPlayer

    let text: String?
    let item: Item
    let songRepo: SongRepository

    init(
        text: String? = nil,
        item: Item,
        player: MusicPlayer = .shared,
        songRepo: SongRepository = .shared
    ) {
        self.text = text
        self.item = item
        _player = ObservedObject(wrappedValue: player)
        self.songRepo = songRepo
    }

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemSymbol: .playFill)
            if let text = text {
                Text(text)
            }
        }
    }

    func action() {
        Task(priority: .userInitiated) {
            do {
                switch item {
                case .album(let album):
                    try await playAlbum(album)
                case .song(let song):
                    try await player.play(song: song)
                }
            } catch {
                print("Failed to start playback")
                player.stop()
            }
        }
    }

    func playAlbum(_ album: Album) async throws {
        let songs = await songRepo.getSongs(ofAlbum: album.uuid)
        await player.enqueue(songs: songs, position: .next)
        try await player.play()
    }
}

struct PlayPauseButton: View {
    @ObservedObject
    var player: MusicPlayer

    let text: String?

    init(
        text: String? = nil,
        player: MusicPlayer = .shared
    ) {
        self.text = text
        _player = ObservedObject(wrappedValue: player)
    }

    var body: some View {
        Button {
            player.isPlaying ? player.pause() : player.resume()
        } label: {
            Image(systemSymbol: player.isPlaying ? .pauseFill : .playFill)
            if let text = text {
                Text(text)
            }
        }
    }
}

#if DEBUG
struct PlayButton_Previews: PreviewProvider {
    static var previews: some View {
        PlayButton(
            item: .song(PreviewData.songs.first!),
            player: .init(preview: true),
            songRepo: .init(store: .previewStore(items: PreviewData.songs, cacheIdentifier: \.uuid))
        )
        PlayPauseButton(player: .init(preview: true))
            .previewDisplayName("Play/Pause button")
    }
}
#endif
