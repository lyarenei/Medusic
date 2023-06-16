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
                .frame(width: 270, height: 270)

            SongWithActions(song: player.currentSong)

            PlaybackProgressComponent(player: player)
                .padding(.top, 15)

            PlaybackControl()
                .font(.largeTitle)
                .buttonStyle(.plain)
                .padding(.horizontal, 50)

            VolumeBar()
                .font(.footnote)
                .padding(.bottom, 20)
                .disabled(true)
                .foregroundColor(.init(UIColor.secondaryLabel))

            BottomPlaceholder {
                isSongListPresented = true
            }
            .padding(.horizontal, 50)
            .font(.title3)
            .frame(height: 40)
        }
        .padding([.top, .horizontal], 30)
        .sheet(isPresented: $isSongListPresented) {
            Button {
                isSongListPresented = false
            } label: {
                Image(systemSymbol: .chevronCompactDown)
                    .font(.system(size: 42))
                    .foregroundColor(.lightGray)
                    .padding(.top, 10)
                    .padding(.bottom, 1)
            }

            List {
                if player.history.isNotEmpty {
                    historySection
                }

                if player.upNext.isNotEmpty {
                    upNextSection
                }
            }
            .listStyle(.grouped)
        }
    }

    @ViewBuilder
    private var historySection: some View {
        Section {
            ForEach(player.history, id: \.uuid) { song in
                Text(song.name)
                    .contentShape(Rectangle())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.almostClear)
                    .onTapGesture { player.playHistory(song: song) }
            }
        } header: {
            Text("History")
        }
    }

    @ViewBuilder
    private var upNextSection: some View {
        Section {
            ForEach(player.upNext, id: \.uuid) { song in
                Text(song.name)
                    .contentShape(Rectangle())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.almostClear)
                    .onTapGesture { player.playUpNext(song: song) }
            }
        } header: {
            Text("Up next")
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
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(song?.name ?? "")
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

// MARK: - Volume bar

private struct VolumeBar: View {
    @State
    private var volumePercent = 0.35

    var body: some View {
        HStack {
            Image(systemSymbol: .speakerFill)

            Slider(
                value: $volumePercent,
                in: 0...1
            )

            Image(systemSymbol: .speakerWave3Fill)
        }
    }
}

private struct BottomPlaceholder: View {
    @State
    var airplayPresented = false

    var listTapHandler: () -> Void

    var body: some View {
        HStack {
            Image(systemSymbol: .quoteBubble)
                .foregroundColor(.init(UIColor.secondaryLabel))

            Spacer()

            AirPlayComponent()

            Spacer()

            Button {
                listTapHandler()
            } label: {
                Image(systemSymbol: .listBullet)
            }
            .foregroundColor(.init(UIColor.label))
        }
    }
}
