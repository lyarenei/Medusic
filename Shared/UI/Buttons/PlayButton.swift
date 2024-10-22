import ButtonKit
import OSLog
import SFSafeSymbols
import SwiftUI

struct PlayButton: View {
    @EnvironmentObject
    private var player: MusicPlayer

    @EnvironmentObject
    private var repo: LibraryRepository

    private let text: String?
    private let item: any JellyfinItem

    init(_ text: String? = nil, item: any JellyfinItem) {
        self.text = text
        self.item = item
    }

    var body: some View {
        AsyncButton {
            await action()
        } label: {
            HStack {
                Image(systemSymbol: .playFill)
                    .scaledToFit()

                if let text {
                    Text(text)
                }
            }
        }
        .disabledWhenLoading()
    }

    func action() async {
        do {
            switch item {
            case let album as AlbumDto:
                try await playAlbum(album)
            case let song as SongDto:
                try await player.play(song: song)
            default:
                let type = type(of: item)
                Logger.library.debug("Playback of item type: \(type) is not implemented")
                Alerts.error("Playback of \(type) is not available")
            }
        } catch {
            Logger.library.warning("Failed to start playback: \(error.localizedDescription)")
            Alerts.error("Failed to start playback")
        }
    }

    func playAlbum(_ album: AlbumDto) async throws {
        let songs = await repo.getSongs(for: album)
        try await player.play(songs: songs.sorted(by: .album))
    }
}

struct PlayPauseButton: View {
    @EnvironmentObject
    private var player: MusicPlayer

    @State
    private var effectTrigger = false

    private let text: String?

    init(_ text: String? = nil) {
        self.text = text
    }

    var body: some View {
        AsyncButton {
            await action()
        } label: {
            HStack {
                Image(systemSymbol: player.isPlaying ? .pauseFill : .playFill)
                    .contentTransition(.symbolEffect(.replace))

                if let text {
                    Text(text)
                }
            }
        }
        .disabledWhenLoading()
    }

    func action() async {
        if player.isPlaying {
            await player.pause()
        } else {
            await player.resume()
        }

        withAnimation { effectTrigger.toggle() }
    }
}

#if DEBUG
// swiftlint:disable all

#Preview("Play button") {
    PlayButton(item: PreviewData.songs.first!)
        .environmentObject(PreviewUtils.player)
        .environmentObject(PreviewUtils.libraryRepo)
}

#Preview("Play/Pause button") {
    PlayPauseButton()
        .environmentObject(PreviewUtils.player)
        .environmentObject(PreviewUtils.libraryRepo)
}

// swiftlint:enable all
#endif
