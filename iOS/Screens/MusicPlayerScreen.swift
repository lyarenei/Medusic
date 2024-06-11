import OSLog
import SFSafeSymbols
import SwiftUI

struct MusicPlayerScreen: View {
    @EnvironmentObject
    private var player: MusicPlayer

    @EnvironmentObject
    private var repo: LibraryRepository

    @State
    private var isSongListPresented = false

    @State
    private var artworkScale = 1.0

    var body: some View {
        if let curSong = player.currentSong {
            content(for: curSong)
                .sheet(isPresented: $isSongListPresented) { songListSheet }
        }
    }

    @ViewBuilder
    private func content(for song: SongDto) -> some View {
        GeometryReader { proxy in
            let overallHeight = proxy.size.height + proxy.safeAreaInsets.bottom
            VStack(alignment: .center, spacing: 0) {
                artwork(for: song, areaWidth: proxy.size.width)
                    .frame(height: overallHeight / 2)

                VStack(alignment: .center) {
                    songDetails(for: song)
                        .frame(height: overallHeight / 10, alignment: .bottom)

                    PlaybackProgressComponent()
                        .frame(height: overallHeight / 12)

                    PlaybackControl()
                        .buttonStyle(.plain)
                        .frame(
                            width: proxy.size.width - 170,
                            height: overallHeight / 10,
                            alignment: .center
                        )

                    VolumeSliderComponent()
                        .frame(height: overallHeight / 12)

                    FooterActions(song: song) {
                        isSongListPresented = true
                    }
                    .font(.title3)
                    .frame(
                        width: proxy.size.width - 170,
                        height: proxy.size.height / 12,
                        alignment: .bottom
                    )
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 10)
                .frame(height: overallHeight / 2)
            }
            .padding(.horizontal, 20)
            .frame(width: proxy.size.width, height: overallHeight)
        }
    }

    @ViewBuilder
    private func artwork(for song: SongDto, areaWidth: CGFloat) -> some View {
        ZStack(alignment: .center) {
            ArtworkComponent(for: song.albumId)
                .padding()
                .frame(width: areaWidth, height: areaWidth)
                .scaleEffect(artworkScale, anchor: .center)
        }
        .onChange(of: player.isPlaying) {
            withAnimation(.smooth) {
                artworkScale = player.isPlaying ? 1 : 0.75
            }
        }
    }

    @ViewBuilder
    private func songDetails(for song: SongDto) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(song.name)
                    .bold()
                    .lineLimit(1)
                    .font(.title2)

                Text(song.artistCreditName)
                    .lineLimit(1)
                    .font(.body)
            }

            Spacer()

            FavoriteButton(songId: song.id, isFavorite: song.isFavorite)
                .font(.title2)
                .frame(width: 45, height: 45)
                .labelStyle(.iconOnly)
        }
    }

    @ViewBuilder
    private func footerActions(for song: SongDto) -> some View {
        FooterActions(song: song) {
            isSongListPresented = true
        }
        .padding(.horizontal, 50)
        .font(.title2)
        .dynamicTypeSize(DynamicTypeSize.small...DynamicTypeSize.large)
        .frame(height: 40, alignment: .bottom)
    }

    @ViewBuilder
    private var songListSheet: some View {
        SheetCloseButton(isPresented: $isSongListPresented)
            .padding(.vertical, 7)

        let currentlyPlayingId = "currently_playing"
        ScrollViewReader { proxy in
            List {
                if player.playbackHistory.isNotEmpty {
                    historySection
                }

                if let currentSong = player.currentSong {
                    Section("Currently playing") {
                        SongListRowComponent(song: currentSong)
                            .showArtwork()
                            .showArtistName()
                            .contentShape(Rectangle())
                            .background(.almostClear)
                            .fontWeight(.bold)
                            .id(currentlyPlayingId)
                    }
                }

                if player.nextUpQueue.isNotEmpty {
                    nextUpSection
                }
            }
            .listStyle(.plain)
            .onAppear { animatedScroll(proxy, id: currentlyPlayingId) }
        }
    }

    @ViewBuilder
    private var historySection: some View {
        Section("History") {
            ForEach(player.playbackHistory) { song in
                SongListRowComponent(song: song)
                    .showArtwork()
                    .showArtistName()
                    .contentShape(Rectangle())
                    .background(.almostClear)
                    .onTapGesture {
                        Task {
                            do {
                                try await player.play(song: song, preserveQueue: true)
                            } catch {
                                Logger.player.warning("Could not play a song: \(error.localizedDescription)")
                                Alerts.error("Failed to play song")
                            }
                        }
                    }
            }
        }
    }

    @ViewBuilder
    private var nextUpSection: some View {
        Section("Next up") {
            ForEach(Array(player.nextUpQueue.enumerated()), id: \.offset) { idx, song in
                SongListRowComponent(song: song)
                    .showArtwork()
                    .showArtistName()
                    .contentShape(Rectangle())
                    .background(.almostClear)
                    .onTapGesture {
                        Task { await player.skip(to: idx) }
                    }
            }
        }
    }

    private func animatedScroll(_ proxy: ScrollViewProxy, id: String) {
        withAnimation(.easeInOut) {
            proxy.scrollTo(id, anchor: .top)
        }
    }
}

#if DEBUG

#Preview {
    struct Preview: View {
        @State
        var isPresented = true

        @State
        var player = PreviewUtils.player

        var body: some View {
            Color.white
                .popup(isBarPresented: $isPresented, isPopupOpen: .constant(true)) {
                    MusicPlayerScreen()
                        .padding(.top, 30)
                }
                .task { player.setCurrentlyPlaying(newSong: PreviewData.songs.first) }
                .environmentObject(PreviewUtils.libraryRepo)
                .environmentObject(player)
                .environmentObject(ApiClient(previewEnabled: true))
                .environmentObject(PreviewUtils.fileRepo)
        }
    }

    return Preview()
}

#endif

// MARK: - Playback control

private struct PlaybackControl: View {
    @EnvironmentObject
    private var player: MusicPlayer

    var body: some View {
        GeometryReader { proxy in
            HStack(alignment: .center) {
                PlayPreviousButton()
                    .font(.system(size: 24))
                    .contentShape(Rectangle())

                Spacer()

                PlayPauseButton()
                    .font(.system(size: 42))
                    .contentShape(Rectangle())

                Spacer()

                PlayNextButton()
                    .font(.system(size: 24))
                    .contentShape(Rectangle())
                    .disabled(player.nextUpQueue.isEmpty)
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
        }
    }
}

private struct FooterActions: View {
    private let song: SongDto
    private let listTapHandler: () -> Void

    init(song: SongDto, listTapHandler: @escaping () -> Void) {
        self.song = song
        self.listTapHandler = listTapHandler
    }

    var body: some View {
        HStack {
            DownloadButton(songId: song.id, isDownloaded: song.isDownloaded)
                .labelStyle(.iconOnly)
                .padding(.all, 7)

            Spacer()

            AirPlayComponent()
                .padding(.all, 7)

            Spacer()

            queueButton
                .padding(.all, 7)
        }
    }

    @ViewBuilder
    private var queueButton: some View {
        Button {
            listTapHandler()
        } label: {
            Image(systemSymbol: .listBullet)
        }
    }
}
