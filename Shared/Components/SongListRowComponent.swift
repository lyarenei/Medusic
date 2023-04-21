import SwiftUI

struct SongListRowComponent: View {
    let song: Song

    let showAlbumOrder: Bool
    let showArtwork: Bool
    let showArtistName: Bool

    @State
    var artistName: String?

    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: 0) {
                HStack(spacing: 17) {
                    order()
                    artwork()
                    songBody()
                }
                .padding(.vertical, 4)

                Spacer()
            }
        }
    }

    @ViewBuilder
    func order() -> some View {
        if showAlbumOrder {
            Text("\(song.index)")
                .font(.title3)
                .frame(minWidth: 20)
        }
    }

    @ViewBuilder
    func artwork() -> some View {
        if showArtwork {
            ArtworkComponent(itemId: song.uuid)
                .frame(width: 40, height: 40)
        }
    }

    @ViewBuilder
    func songBody() -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(song.name)
                .font(.title3)
                .lineLimit(1)

            // TODO: automatic - if artist differs from album artist
            if showArtistName, let artistName {
                Text(artistName)
                    .lineLimit(1)
                    .font(.body)
                    .foregroundColor(.gray)
            }
        }
    }
}

#if DEBUG
// swiftlint:disable all
struct SongListRowComponent_Previews: PreviewProvider {
    static var previews: some View {
        SongListRowComponent(
            song: PreviewData.songs.first!,
            showAlbumOrder: false,
            showArtwork: true,
            showArtistName: true
        )
        .padding(.horizontal)
    }
}
// swiftlint:enable all
#endif
