import SFSafeSymbols
import SwiftUI

struct MusicPlayerScreen: View {
    @ObservedObject
    var player: MusicPlayer

    init(player: MusicPlayer = .shared) {
        _player = ObservedObject(wrappedValue: player)
    }

    var body: some View {
        VStack(spacing: 15) {
            ArtworkComponent(itemId: player.currentSong?.parentId ?? "")
                .frame(width: 270, height: 270)

            SongWithActions(song: player.currentSong)
            PlaybackProgressComponent(player: player)
            PlaybackControl()
                .font(.largeTitle)
                .buttonStyle(.plain)
                .padding(.horizontal, 50)

            VolumeBar()
                .font(.footnote)
                .padding(.bottom, 20)
                .disabled(true)
                .foregroundColor(.init(UIColor.secondaryLabel))

            BottomPlaceholder()
                .padding(.horizontal, 50)
                .font(.title3)
                .foregroundColor(.init(UIColor.secondaryLabel))
                .frame(height: 40)
        }
        .padding([.top, .horizontal], 30)
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
                .disabled(true)

            Spacer()

            PlayPauseButton(player: player)
                .frame(width: 50, height: 50)
                .contentShape(Rectangle())

            Spacer()

            PlayNextButton(player: player)
                .font(.title2)
                .frame(width: 50, height: 50)
                .contentShape(Rectangle())
                .disabled(false)
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

    var body: some View {
        HStack {
            Image(systemSymbol: .quoteBubble)
            Spacer()
            AirPlayComponent()
            Spacer()
            Image(systemSymbol: .listBullet)
        }
    }
}
