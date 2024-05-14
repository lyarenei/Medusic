import SwiftUI

struct NowPlayingBarComponent: View {
    @EnvironmentObject
    private var player: MusicPlayer

    var body: some View {
        HStack(spacing: 0) {
            songInfo(for: player.currentSong)
                .frame(height: 60)
                .contentShape(Rectangle())

            PlayPauseButton()
                .frame(width: 60, height: 60)
                .font(.title2)
                .buttonStyle(.plain)
                // Increase the tap area
                .padding(.leading)
                .contentShape(Rectangle())

            PlayNextButton()
                .font(.title2)
                .frame(width: 60, height: 60)
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                .disabled(player.nextUpQueue.isEmpty)
        }
        .padding(.trailing, 10)
    }

    @ViewBuilder
    private func songInfo(for song: SongDto?) -> some View {
        HStack {
            ArtworkComponent(for: song?.albumId ?? .empty)
                .frame(width: 50, height: 50)
                .shadow(radius: 6, x: 0, y: 3)
                .padding(.leading)

            Text(song?.name ?? .empty)
                .font(.system(size: 16))
                .padding(.leading, 10)
                .lineLimit(1)

            Spacer()
        }
    }
}

#if DEBUG
// swiftlint:disable all

#Preview {
    struct Preview: View {
        @State
        var player = PreviewUtils.player

        var body: some View {
            Color.white
                .task { player.setCurrentlyPlaying(newSong: PreviewData.songs.first) }
                .popup(isBarPresented: .constant(true)) { EmptyView() }
                .popupBarCustomView { NowPlayingBarComponent() }
                .environmentObject(ApiClient(previewEnabled: true))
                .environmentObject(PreviewUtils.player)
        }
    }

    return Preview()
}

// swiftlint:enable all
#endif
