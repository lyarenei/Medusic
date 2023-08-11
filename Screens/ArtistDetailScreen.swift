import SwiftUI

struct ArtistDetailScreen: View {
    @EnvironmentObject
    private var library: LibraryRepository

    private let artist: Artist

    init(artist: Artist) {
        self.artist = artist
    }

    var body: some View {
        VStack {
            header
            albums
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        HStack(spacing: 15) {
            ArtworkComponent(itemId: artist.id)
                .frame(width: 90, height: 90)

            VStack(alignment: .leading, spacing: 10) {
                Text(artist.name)
                    .font(.title2)
                    .multilineTextAlignment(.leading)

                let albumCount = library.albums.matching(artistId: artist.id).count
                Text("\(albumCount) albums, 0 minutes")
                    .font(.footnote)
                    .foregroundColor(.secondaryLabel)
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var albums: some View {
        List {
            ForEach(library.albums.matching(artistId: artist.id), id: \.id) { album in
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
// swiftlint:disable all
struct ArtistDetailScreen_Previews: PreviewProvider {
    static var previews: some View {
        ArtistDetailScreen(artist: PreviewData.artists.first!)
            .environmentObject(
                LibraryRepository(
                    artistStore: .previewStore(items: PreviewData.artists, cacheIdentifier: \.id),
                    albumStore: .previewStore(items: PreviewData.albums, cacheIdentifier: \.id),
                    apiClient: .init(previewEnabled: true)
                )
            )
    }
}
// swiftlint:enable all
#endif
