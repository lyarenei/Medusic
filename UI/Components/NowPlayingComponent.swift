import SFSafeSymbols
import SwiftUI
import SwiftUIX

/// Now playing component, somewhat similar what can be seen in Apple Music app.
///
/// Base implementation taken from: https://itnext.io/add-a-now-playing-bar-with-swiftui-to-your-app-d515b03f05e3
struct NowPlayingComponent<Content: View>: View {
    @EnvironmentObject
    private var player: MusicPlayer

    @Binding
    var isPresented: Bool

    var content: Content

    init(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) {
        self._isPresented = isPresented
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            content

            if isPresented {
                NowPlayingBar()
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom),
                        removal: .identity
                    ))
            }
        }
    }
}

#if DEBUG

#Preview {
    struct Preview: View {
        @State
        var player = PreviewUtils.player

        var body: some View {
            NowPlayingComponent(isPresented: .constant(true)) {
                LibraryScreen()
            }
            .task { player.setCurrentlyPlaying(newSong: PreviewData.songs.first) }
            .environmentObject(ApiClient(previewEnabled: true))
            .environmentObject(PreviewUtils.libraryRepo)
            .environmentObject(player)
        }
    }

    return Preview()
}

#endif

private struct NowPlayingBar: View {
    @EnvironmentObject
    private var player: MusicPlayer

    @State
    private var isOpen = false

    var body: some View {
        HStack(spacing: 0) {
            Button {
                isOpen = true
            } label: {
                songInfo(for: player.currentSong)
                    .frame(height: 60)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

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
        .frame(width: Screen.size.width, height: 65)
        .background(Blur())
        .sheet(isPresented: $isOpen) {
            SheetCloseButton(isPresented: $isOpen)
            MusicPlayerScreen()
        }
    }

    @ViewBuilder
    private func songInfo(for song: Song?) -> some View {
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

/// Blur effect.
///
/// From: https://itnext.io/add-a-now-playing-bar-with-swiftui-to-your-app-d515b03f05e3
struct Blur: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemChromeMaterial

    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
