import SFSafeSymbols
import SwiftUI

struct AlbumDetailScreen: View {
    @ObservedObject
    var albumRepo: AlbumRepository

    @ObservedObject
    var songRepo: SongRepository

    let album: Album

    init(
        for album: Album,
        albumRepo: AlbumRepository = .shared,
        songRepo: SongRepository = .shared
    ) {
        self.album = album
        _albumRepo = ObservedObject(wrappedValue: albumRepo)
        _songRepo = ObservedObject(wrappedValue: songRepo)
    }

    var body: some View {
        ScrollView {
            VStack {
                AlbumHeading(album: album)
                    .padding(.bottom, 10)

                AlbumActions()
                    .padding(.bottom, 30)

                SongCollection(
                    songs: songRepo.songs.filterByAlbum(id: album.uuid),
                    showAlbumOrder: true,
                    showArtwork: false,
                    showAction: true,
                    showArtistName: false
                )
            }
            .padding(.top, 15)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                RefreshButton(mode: .album(id: album.uuid))
            }
        }
    }
}

#if DEBUG
struct AlbumDetailScreen_Previews: PreviewProvider {
    static var previews: some View {
        AlbumDetailScreen(
            for: PreviewData.albums.first!,
            albumRepo: .init(store: .previewStore(items: PreviewData.albums, cacheIdentifier: \.uuid)),
            songRepo: .init(store: .previewStore(items: PreviewData.songs, cacheIdentifier: \.uuid))
        )
    }
}
#endif

// MARK: - Album heading component

private struct AlbumHeading: View {
    var album: Album

    var body: some View {
        VStack(spacing: 20) {
            ArtworkComponent(itemId: album.id)
                .frame(width: 270, height: 270)

            VStack(spacing: 5) {
                Text(album.name)
                    .font(.title3)
                    .bold()
                    .multilineTextAlignment(.center)

                Text(album.artistName)
                    .font(.body)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.leading, 20)
        .padding(.trailing, 20)
    }
}

// MARK: - Album actions component

private struct AlbumActions: View {
    var body: some View {
        HStack {
            Button {
                // Album play action
            } label: {
                Image(systemSymbol: .playFill)
                Text("Play")
            }
            .frame(width: 120, height: 37)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(style: StrokeStyle(lineWidth: 1.0))
            )
            .disabled(true)

            Button {
                // Album shuffle play action
            } label: {
                Image(systemSymbol: .shuffle)
                Text("Shuffle")
            }
            .frame(width: 120, height: 37)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(style: StrokeStyle(lineWidth: 1.0))
            )
            .disabled(true)
        }
    }
}
