import SFSafeSymbols
import SwiftUI

struct MusicPlayerScreen: View {
    @StateObject
    private var songRepo = SongRepository(store: .songs)

    @State
    private var currentSong: Song = Song(uuid: "asdf", index: 1, name: "Song name", parentId: "asdf", isFavorite: false)

    @State
    private var sliderValue = 0.35

    var body: some View {
        ZStack {
            VStack(spacing: 15) {
                ArtworkPlaceholder()

                SongWithActions(
                    songName: currentSong.name,
                    artistName: "Artist name"
                )

                PlaybackBar()

                PlaybackControl()
                    .font(.largeTitle)
                    .buttonStyle(.plain)
                    .padding([.leading, .trailing], 50)


                VolumeBar()
                    .font(.footnote)
                    .padding(.bottom, 20)

                BottomPlaceholder()
                    .padding([.leading, .trailing], 50)
                    .font(.title3)
            }
            .padding([.top, .leading, .trailing], 30)
        }
        .popupTitle("Song name")
        .popupImage(Image(systemSymbol: .square))
        .popupBarMarqueeScrollEnabled(true)
        .popupBarItems({
            HStack(spacing:20) {
                Button(action: {

                }) {
                    Image(systemSymbol: .playFill)
                }
                .buttonStyle(.plain)

                Button(action: {

                }) {
                    Image(systemSymbol: .forwardFill)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 10)
            }
        })
    }
}

#if DEBUG
struct MusicPlayerScreen_Previews: PreviewProvider {
    static var previews: some View {
        MusicPlayerScreen()
    }
}
#endif

// MARK: - Artwork placeholder

private struct ArtworkPlaceholder: View {
    var body: some View {
        // TODO: collides with closing chevron
        Text("img")
            .frame(width: 270, height: 270)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(style: StrokeStyle(lineWidth: 1.0))
            )
    }
}

// MARK: - Song with actions
private struct SongWithActions: View {
    @State
    var songName: String

    @State
    var artistName: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(songName)
                    .bold()
                    .lineLimit(1)
                    .font(.title2)

                Text(artistName)
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
        }
    }
}

// MARK: - Playback bar

private struct PlaybackBar: View {
    @State
    private var progressPercent: Double = 65

    @State
    private var currentTime: Int32 = 65

    @State
    private var remainingTime: Int32 = 35

    var body: some View {
        VStack(spacing: 0) {
            Slider(
                value: $progressPercent,
                in: 0...100
            )

            HStack {
                Text("\(currentTime)")
                    .font(.subheadline)

                Spacer()

                Text("\(remainingTime)")
                    .font(.subheadline)
            }
        }
    }
}

// MARK: - Playback control

private struct PlaybackControl: View {
    var body: some View {
        HStack {
            Button {
                // Previous song
            } label: {
                Image(systemSymbol: .backwardFill)
            }
            .font(.title2)

            Spacer()

            Button {
                // Play/pause
            } label: {
                Image(systemSymbol: .playFill)
            }

            Spacer()

            Button {
                // Next song
            } label: {
                Image(systemSymbol: .forwardFill)
            }
            .font(.title2)
        }
    }
}

// MARK: - Volume bar

private struct VolumeBar: View {
    @State
    private var volumePercent: Double = 0.35

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
    var body: some View {
        HStack {
            Image(systemSymbol: .quoteBubble)
            Spacer()
            Image(systemSymbol: .airplayaudio)
            Spacer()
            Image(systemSymbol: .listBullet)
        }
    }
}
