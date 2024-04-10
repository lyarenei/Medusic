import OSLog
import SFSafeSymbols
import SwiftUI

struct PlayButton: View {
    @ObservedObject
    private var player: MusicPlayer

    @EnvironmentObject
    private var repo: LibraryRepository

    private let text: String?
    private let item: any JellyfinItem

    init(_ text: String? = nil, item: any JellyfinItem, player: MusicPlayer = .shared) {
        self.text = text
        self.item = item
        self._player = ObservedObject(wrappedValue: player)
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
                let type = type(of: item)
                Logger.library.debug("Playback of item type: \(type) is not implemented")
                Alerts.error("Playback of \(type) is not available")
            }
        }
    }

    func playAlbum(_ album: Album) async {
        let songs = repo.getSongs(for: album)
        await player.play(songs: songs.sorted(by: .album))
    }
}

struct PlayPauseButton: View {
    @ObservedObject
    private var player: MusicPlayer

    private let text: String?

    init(_ text: String? = nil, player: MusicPlayer = .shared) {
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

#Preview {
    PlayButton(item: PreviewData.songs.first!, player: .init(preview: true))
        .environmentObject(PreviewUtils.libraryRepo)
}

#Preview("Play/Pause button") {
    PlayPauseButton(player: .init(preview: true))
}

// swiftlint:enable all
#endif
