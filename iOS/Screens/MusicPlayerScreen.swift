import SFSafeSymbols
import SwiftUI
import SwiftUIX

struct MusicPlayerScreen: View {
    @EnvironmentObject
    private var player: MusicPlayerCore

    @EnvironmentObject
    private var repo: LibraryRepository

    @State
    private var isSongListPresented = false

    var body: some View {
        if let curSong = player.currentSong {
            content(for: curSong)
                .sheet(isPresented: $isSongListPresented) { songListSheet }
        }
    }

    @ViewBuilder
    private func content(for song: Song) -> some View {
        VStack(alignment: .center, spacing: 15) {
            ArtworkComponent(for: song.albumId)
                .frame(
                    width: Screen.size.width - 40,
                    height: Screen.size.width - 40
                )

            songDetails(for: song)
                .padding(.leading, 28)
                .padding(.trailing, 16)

            Group {
                PlaybackProgressComponent()
                PlaybackControl()
                    .font(.largeTitle)
                    .buttonStyle(.plain)
                    .padding(.horizontal, 40)

                VolumeSliderComponent()
                    .frame(height: 40)
                    .padding(.top, 10)

                footerActions(for: song)
            }
            .padding(.horizontal, 28)
        }
        .padding(.top, 5)
        .padding(.bottom, 15)
    }

    @ViewBuilder
    private func songDetails(for song: Song) -> some View {
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

            FavoriteButton(item: song)
                .font(.title2)
                .frame(width: 45, height: 45)
        }
    }

    @ViewBuilder
    private func footerActions(for song: Song) -> some View {
        FooterActions(song: song) {
            isSongListPresented = true
        }
        .padding(.horizontal, 50)
        .font(.title3)
        .frame(height: 40)
    }

    @ViewBuilder
    private var songListSheet: some View {
        SheetCloseButton(isPresented: $isSongListPresented)
            .padding(.vertical, 7)

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
                }
            }

            if player.nextUpQueue.isNotEmpty {
                nextUpSection
            }
        }

//        ScrollViewReader { proxy in
//            songList
//                .listStyle(.plain)
//            TODO: update when playback history is reimplemented
//                .onAppear { animatedScroll(proxy, songIdx: player.queueIndex) }
//                .onChange(of: player.queueIndex) {
//                    animatedScroll(proxy, songIdx: player.queueIndex)
//                }
//        }
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

    @ViewBuilder
    private var songList: some View {
        List(Array(player.nextUpQueue.enumerated()), id: \.offset) { idx, song in
            SongListRowComponent(song: song)
                .showArtwork()
                .showArtistName()
                .contentShape(Rectangle())
                .background(.almostClear)
                // TODO: replace with playing icon or something after list row is refactored
                .fontWeight(idx == 0 ? .bold : .regular)
                .onTapGesture {
//                    if idx > player.queueIndex {
                        Task { await player.skip(to: idx) }
//                    }
                }
        }
    }

    private func animatedScroll(_ proxy: ScrollViewProxy, songIdx: Int?) {
        guard let songIdx else { return }
        withAnimation(.easeInOut) {
            proxy.scrollTo(songIdx, anchor: .top)
        }
    }
}

#if DEBUG

#Preview {
    struct Preview: View {
        @State
        var isPresented = false

        @State
        var player = PreviewUtils.player

        var body: some View {
            VStack {
                SheetCloseButton(isPresented: $isPresented)
                MusicPlayerScreen()
            }
            .task { player.setCurrentlyPlaying(newSong: PreviewData.songs.first) }
            .environmentObject(PreviewUtils.libraryRepo)
            .environmentObject(player)
            .environmentObject(ApiClient(previewEnabled: true))
        }
    }

    return Preview()
}

#endif

// MARK: - Playback control

private struct PlaybackControl: View {
    @EnvironmentObject
    private var player: MusicPlayerCore

    var body: some View {
        HStack {
            PlayPreviousButton()
                .font(.title2)
                .frame(width: 50, height: 50)
                .contentShape(Rectangle())

            Spacer()

            PlayPauseButton()
                .frame(width: 50, height: 50)
                .contentShape(Rectangle())

            Spacer()

            PlayNextButton()
                .font(.title2)
                .frame(width: 50, height: 50)
                .contentShape(Rectangle())
                .disabled(player.nextUpQueue.isEmpty)
        }
        .frame(height: 40)
    }
}

private struct FooterActions: View {
    private let song: Song
    private let listTapHandler: () -> Void

    init(song: Song, listTapHandler: @escaping () -> Void) {
        self.song = song
        self.listTapHandler = listTapHandler
    }

    var body: some View {
        HStack {
            DownloadButton(item: song)
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
