import SwiftUI
import SwiftUIBackports

struct SongListRowComponent: View {
    let song: Song

    private var showAlbumOrder = false
    private var showArtwork = false
    private var showArtistName = false
    private var showAlbumName = false
    private var height = 40.0

    @State
    private var artistName: String?

    @State
    private var album: Album?

    private let albumRepo: AlbumRepository

    init(
        song: Song,
        albumRepo: AlbumRepository = .shared
    ) {
        self.song = song
        self.albumRepo = albumRepo
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
        .backport.task { album = await albumRepo.getAlbum(by: song.parentId) }
    }

    @ViewBuilder
    private func order() -> some View {
        if showAlbumOrder {
            Text("\(song.index)")
                .frame(minWidth: 20)
        }
    }

    @ViewBuilder
    private func artwork() -> some View {
        if showArtwork {
            let square = CGSize(width: height, height: height)
            ArtworkComponent(itemId: song.parentId)
                .frame(width: square.width, height: square.height)
        }
    }

    @ViewBuilder
    private func songBody() -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(song.name)
                .lineLimit(1)

            artistOrAlbumName()
                .lineLimit(1)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
    }

    @ViewBuilder
    private func artistOrAlbumName() -> some View {
        // TODO: automatic - if artist differs from album artist
        if showArtistName, let artistName {
            Text(artistName)

        } else if showAlbumName, let album {
            Text(album.name)
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

    func height(_ height: CGFloat) -> SongListRowComponent {
        var view = self
        view.height = height
        return view
    }

    func showAlbumName(_ value: Bool = true) -> SongListRowComponent {
        var view = self
        view.showAlbumName = value
        return view
    }
}

#if DEBUG
// swiftlint:disable all
struct SongListRowComponent_Previews: PreviewProvider {
    static var previews: some View {
        SongListRowComponent(
            song: PreviewData.songs.first!,
            albumRepo: .init(
                store: .previewStore(
                    items: PreviewData.albums,
                    cacheIdentifier: \.uuid
                )
            )
        )
        .showArtwork()
        .showArtistName()
        .padding(.horizontal)
    }
}
// swiftlint:enable all
#endif
