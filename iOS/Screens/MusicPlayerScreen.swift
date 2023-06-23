import SFSafeSymbols
import SwiftUI
import SwiftUIX

struct MusicPlayerScreen: View {
    @ObservedObject
    var player: MusicPlayer

    @State
    private var isSongListPresented = false

    init(player: MusicPlayer = .shared) {
        _player = ObservedObject(wrappedValue: player)
    }

    var body: some View {
        VStack(spacing: 15) {
            ArtworkComponent(itemId: player.currentSong?.parentId ?? "")
            SongWithActions(song: player.currentSong)
            PlaybackProgressComponent(player: player)
                .padding(.top, 15)

            PlaybackControl()
                .font(.largeTitle)
                .buttonStyle(.plain)
                .padding(.horizontal, 50)

            VolumeSliderComponent()
                .frame(height: 40)

            FooterActions {
                isSongListPresented = true
            }
            .padding(.horizontal, 50)
            .padding(.bottom, 30)
            .font(.title3)
            .frame(height: 40)
        }
        .padding([.top, .horizontal], 30)
        .sheet(isPresented: $isSongListPresented) {
            sheetCloseButton
            ScrollViewReader { proxy in
                songList
                    .listStyle(.grouped)
                    .onAppear { animatedScroll(proxy, song: player.currentSong) }
                    .onChange(of: player.currentSong) { newSong in
                        animatedScroll(proxy, song: newSong)
                    }
            }
        }
    }

    @ViewBuilder
    private var sheetCloseButton: some View {
        Button {
            isSongListPresented = false
        } label: {
            Image(systemSymbol: .chevronCompactDown)
                .font(.system(size: 42))
                .foregroundColor(.lightGray)
                .padding(.top, 10)
                .padding(.bottom, 1)
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

            if player.upNext.isNotEmpty {
                upNextSection
            }
        }
    }

    @ViewBuilder
    private var historySection: some View {
        Section {
            ForEach(player.history, id: \.uuid) { song in
                SongListRowComponent(song: song)
                    .showArtwork()
                    .showArtistName()
                    .contentShape(Rectangle())
                    .background(.almostClear)
                    .onTapGesture { player.playHistory(song: song) }
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
            ForEach(player.upNext, id: \.uuid) { song in
                SongListRowComponent(song: song)
                    .showArtwork()
                    .showArtistName()
                    .contentShape(Rectangle())
                    .background(.almostClear)
                    .onTapGesture { player.playUpNext(song: song) }
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

#if DEBUG
// swiftlint:disable all
struct MusicPlayerScreen_Previews: PreviewProvider {
    static var player = {
        var mp = MusicPlayer(preview: true)
        mp.currentSong = PreviewData.songs.first!
        return mp
    }

    static var previews: some View {
        MusicPlayerScreen(player: player())
    }
}
// swiftlint:enable all
#endif

// MARK: - Song with actions

private struct SongWithActions: View {
    var song: Song?

    var body: some View {
        if let song {
            content(for: song)
        }
    }

    @ViewBuilder
    private func content(for song: Song) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(song.name)
                    .bold()
                    .lineLimit(1)
                    .font(.title2)

                Text("song.artistName")
                    .lineLimit(1)
                    .font(.body)
            }

            Spacer()

            Button {
                // Options button
            } label: {
                Image(systemSymbol: .ellipsisCircle)
            }
            .font(.title2)
            .disabled(true)
        }
    }
}

// MARK: - Playback control

private struct PlaybackControl: View {
    @ObservedObject
    private var player: MusicPlayer = .shared

    var body: some View {
        HStack {
            PlayPreviousButton(player: player)
                .font(.title2)
                .frame(width: 50, height: 50)
                .contentShape(Rectangle())
                .disabled(player.history.isEmpty)

            Spacer()

            PlayPauseButton(player: player)
                .frame(width: 50, height: 50)
                .contentShape(Rectangle())

            Spacer()

            PlayNextButton(player: player)
                .font(.title2)
                .frame(width: 50, height: 50)
                .contentShape(Rectangle())
                .disabled(player.upNext.isEmpty)
        }
        .frame(height: 40)
    }
}

private struct FooterActions: View {
    var listTapHandler: () -> Void

    var body: some View {
        HStack {
            lyricsButton
                .disabled(true)

            Spacer()

            AirPlayComponent()

            Spacer()

            queueButton
                .buttonStyle(.plain)
        }
    }

    private var lyricsButton: some View {
        Button {} label: {
            Image(systemSymbol: .quoteBubble)
        }
    }

    private var queueButton: some View {
        Button {
            listTapHandler()
        } label: {
            Image(systemSymbol: .listBullet)
        }
    }
}
