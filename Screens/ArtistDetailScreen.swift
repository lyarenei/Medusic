import SwiftUI

struct ArtistDetailScreen: View {
    @EnvironmentObject
    private var library: LibraryRepository

    let artist: Artist

    var body: some View {
        let albums = library.albums.filtered(by: .artistId(artist.id))
        VStack {
            artistHeader(albumCount: albums.count)
            artistAlbums(albums)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                RefreshButton(mode: .artist(id: artist.id))
            }
        }
    }

    @ViewBuilder
    private func artistHeader(albumCount: Int) -> some View {
        HStack(spacing: 15) {
            ArtworkComponent(itemId: artist.id)
                .frame(width: 90, height: 90)

            VStack(alignment: .leading, spacing: 10) {
                Text(artist.name)
                    .font(.title2)
                    .multilineTextAlignment(.leading)

                Text("\(albumCount) albums, 0 minutes")
                    .font(.footnote)
                    .foregroundColor(.secondaryLabel)
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func artistAlbums(_ albums: [Album]) -> some View {
        List {
            ForEach(albums, id: \.id) { album in
                NavigationLink {
                    AlbumDetailScreen(album: album)
                } label: {
                    Label {
                        Text(album.name)
                            .font(.title3)
                    } icon: {
                        ArtworkComponent(itemId: album.id)
                            .scaledToFit()
                    }
                    .labelStyle(.titleAndIcon)
                }
                .frame(height: 40)
            }
        }
        .listStyle(.plain)
    }
}

#if DEBUG
struct ArtistDetailScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ArtistDetailScreen(artist: PreviewData.artist)
        }
        .environmentObject(PreviewUtils.libraryRepo)
    }
}
#endif
