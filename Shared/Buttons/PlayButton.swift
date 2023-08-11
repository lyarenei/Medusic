import SFSafeSymbols
import SwiftUI

struct PlayButton: View {
    @ObservedObject
    var player: MusicPlayer

    let text: String?
    let item: any JellyfinItem
    let songRepo: SongRepository

    init(
        text: String? = nil,
        item: any JellyfinItem,
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
            if let text {
                Text(text)
            }
        }
    }

    func action() {
        Task {
            switch item {
            case let album as Album:
                await playAlbum(album)
            case let song as Song:
                await player.play(song: song)
            default:
                print("Unhandled item type: \(item)")
            }
        }
    }

    func playAlbum(_ album: Album) async {
        let songs = await songRepo.getSongs(ofAlbum: album.id)
        await player.play(songs: songs.sortByAlbum())
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
            action()
        } label: {
            Image(systemSymbol: player.isPlaying ? .pauseFill : .playFill)
            if let text {
                Text(text)
            }
        }
    }

    func action() {
        Task {
            if player.isPlaying {
                await player.pause()
            } else {
                await player.resume()
            }
        }
    }
}

#if DEBUG
// swiftlint:disable all
struct PlayButton_Previews: PreviewProvider {
    static var previews: some View {
        PlayButton(
            item: PreviewData.songs.first!,
            player: .init(preview: true),
            songRepo: .init(store: .previewStore(items: PreviewData.songs, cacheIdentifier: \.id))
        )
        PlayPauseButton(player: .init(preview: true))
            .previewDisplayName("Play/Pause button")
    }
}
// swiftlint:enable all
#endif
