import SwiftUI

struct SongListRowComponent: View {
    let song: Song

    private var showAlbumOrder = false
    private var showArtwork = false
    private var showArtistName = false

    @State
    private var artistName: String?

    init(song: Song) {
        self.song = song
    }

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
    private func order() -> some View {
        if showAlbumOrder {
            Text("\(song.index)")
                .font(.title3)
                .frame(minWidth: 20)
        }
    }

    @ViewBuilder
    private func artwork() -> some View {
        if showArtwork {
            ArtworkComponent(itemId: song.uuid)
                .frame(width: 40, height: 40)
        }
    }

    @ViewBuilder
    private func songBody() -> some View {
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

extension SongListRowComponent {
    func showAlbumOrder(_ value: Bool = true) -> SongListRowComponent {
        var view = self
        view.showAlbumOrder = value
        return view
    }

    func showArtwork(_ value: Bool = true) -> SongListRowComponent {
        var view = self
        view.showArtwork = value
        return view
    }

    func showArtistName(_ value: Bool = true) -> SongListRowComponent {
        var view = self
        view.showArtistName = value
        return view
    }
}

#if DEBUG
// swiftlint:disable all
struct SongListRowComponent_Previews: PreviewProvider {
    static var previews: some View {
        SongListRowComponent(song: PreviewData.songs.first!)
            .showArtwork()
            .showArtistName()
            .padding(.horizontal)
    }
}
// swiftlint:enable all
#endif