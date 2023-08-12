import JellyfinAPI
import OSLog
import SwiftUI

struct AlbumLibraryScreen: View {
    @EnvironmentObject
    private var library: LibraryRepository

    var body: some View {
        content
            .navigationTitle("Albums")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem { RefreshButton(mode: .allAlbums) }
            }
    }

    @ViewBuilder
    private var content: some View {
        if library.albums.isNotEmpty {
            List { albumList }
                .listStyle(.plain)
        } else {
            Text("No albums")
                .font(.title3)
                .foregroundColor(.gray)
        }
    }

    @ViewBuilder
    private var albumList: some View {
        ForEach(library.albums.sorted(by: .name), id: \.id) { album in
            NavigationLink {
                AlbumDetailScreen(album: album)
            } label: {
                label(for: album)
            }
        }
    }

    @ViewBuilder
    private func label(for album: Album) -> some View {
        HStack {
            ArtworkComponent(itemId: album.id)
                .frame(width: 50, height: 50)

            VStack(alignment: .leading, spacing: 3) {
                Text(album.name)
                    .font(.title2)

                Text(library.getArtistName(for: album))
                    .font(.body)
                    .foregroundColor(.gray)
            }
        }
    }
}

#if DEBUG
struct AlbumLibraryScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AlbumLibraryScreen()
                .environmentObject(PreviewUtils.libraryRepo)
        }
    }
}
#endif
