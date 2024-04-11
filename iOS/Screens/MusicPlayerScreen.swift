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

        ScrollViewReader { proxy in
            songList
                .listStyle(.grouped)
                .onAppear { animatedScroll(proxy, song: player.currentSong) }
                .onChange(of: player.currentSong) {
                    animatedScroll(proxy, song: player.currentSong)
                }
        }
    }

    @ViewBuilder
    private var songList: some View {
        List {
            if player.history.isNotEmpty {
                historySection
            }

            if let curSong = player.currentSong {
                currentSection(with: curSong)
            }

            if player.nextUp.isNotEmpty {
                upNextSection
            }
        }
    }

    @ViewBuilder
    private var historySection: some View {
        Section {
            ForEach(player.history, id: \.id) { song in
                SongListRowComponent(song: song)
                    .showArtwork()
                    .showArtistName()
                    .contentShape(Rectangle())
                    .background(.almostClear)
//                TODO: enable
//                    .onTapGesture { player.playHistory(song: song) }
                    .id(song.id)
            }
        } header: {
            Text("History")
        }
    }

    @ViewBuilder
    private func currentSection(with currentSong: Song) -> some View {
        Section {
            SongListRowComponent(song: currentSong)
                .showArtwork()
                .showArtistName()
                .background(.almostClear)
                .id(currentSong.id)
        } header: {
            Text("Currently Playing")
        }
    }

    @ViewBuilder
    private var upNextSection: some View {
        Section {
            ForEach(player.nextUp, id: \.id) { song in
                SongListRowComponent(song: song)
                    .showArtwork()
                    .showArtistName()
                    .contentShape(Rectangle())
                    .background(.almostClear)
//                TODO: enable
//                    .onTapGesture { player.playUpNext(song: song) }
                    .id(song.id)
            }
        } header: {
            Text("Up next")
        }
    }

    private func animatedScroll(_ proxy: ScrollViewProxy, song: Song?) {
        guard let song else { return }
        withAnimation(.easeInOut) {
            proxy.scrollTo(song.id, anchor: .top)
        }
    }
}

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
                .disabled(player.history.isEmpty)

            Spacer()

            PlayPauseButton()
                .frame(width: 50, height: 50)
                .contentShape(Rectangle())

            Spacer()

            PlayNextButton()
                .font(.title2)
                .frame(width: 50, height: 50)
                .contentShape(Rectangle())
                .disabled(player.nextUp.isEmpty)
        }
        .frame(height: 40)
    }
}

private struct FooterActions: View {
    var song: Song
    var listTapHandler: () -> Void

    var body: some View {
        HStack {
            DownloadButton(item: song)
                .padding(.all, 7)

            Spacer()

            AirPlayComponent()
                .padding(.all, 7)

            Spacer()

            queueButton
                .buttonStyle(.plain)
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
