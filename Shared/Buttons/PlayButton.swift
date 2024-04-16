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
                if let text {
                    Text(text)
                }
            }
        }
    }

    func action() async {
        do {
            switch item {
            case let album as Album:
                try await playAlbum(album)
            case let song as Song:
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

    func playAlbum(_ album: Album) async throws {
        let songs = repo.getSongs(for: album)
        try await player.play(songs: songs.sorted(by: .album))
    }
}

struct PlayPauseButton: View {
    @EnvironmentObject
    private var player: MusicPlayer

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
                if let text {
                    Text(text)
                }
            }
        }
    }

    func action() async {
        if player.isPlaying {
            await player.pause()
        } else {
            await player.resume()
        }
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
