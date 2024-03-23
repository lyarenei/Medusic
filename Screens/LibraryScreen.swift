import Defaults
import SFSafeSymbols
import SwiftUI

struct LibraryScreen: View {
    @EnvironmentObject
    private var library: LibraryRepository

    @Default(.libraryShowFavorites)
    private var showFavoriteAlbums

    @Default(.libraryShowRecentlyAdded)
    private var showRecentlyAdded

    var body: some View {
        NavigationStack {
            ScrollView {
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem { RefreshButton(mode: .all) }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        VStack(spacing: 15) {
            mainNavigation
                .padding(.leading)

            favoriteAlbums
            recentlyAddedAlbums
        }
    }

    @ViewBuilder
    private var mainNavigation: some View {
        VStack(spacing: 5) {
            Divider()
            navLink(for: "Playlists", to: EmptyView(), icon: .musicNoteList)
                .disabled(true)

            Divider()
            navLink(for: "Artists", to: ArtistLibraryScreen(artists: library.artists), icon: .musicMic)
            Divider()
            navLink(for: "Albums", to: AlbumLibraryScreen(albums: library.albums), icon: .squareStack)
            Divider()
            navLink(for: "Songs", to: SongsLibraryScreen(songs: library.songs), icon: .musicNote)
            Divider()
        }
    }

    @ViewBuilder
    private func navLink(for name: String, to dst: some View, icon: SFSymbol) -> some View {
        NavigationLink(destination: dst) {
            HStack(spacing: 15) {
                Image(systemSymbol: icon)
                    .foregroundColor(.accentColor)
                    .frame(minWidth: 25)

                Text(name)
                Spacer()
                Image(systemSymbol: .chevronRight)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.gray)
                    .font(.system(size: 15))
            }
            .buttonStyle(.plain)
            .padding(.trailing, 15)
        }
        .contentShape(Rectangle())
        .font(.title2)
        .padding(.vertical, 5)
    }

    @ViewBuilder
    private var favoriteAlbums: some View {
        if showFavoriteAlbums {
            AlbumPreviewCollection(
                for: library.albums.favorite.sorted(by: Array<Album>.AlbumSortBy.dateAdded).reversed(),
                titleText: "Favorite albums",
                emptyText: "No albums"
            )
            .stackType(.horizontal)
        }
    }

    @ViewBuilder
    private var recentlyAddedAlbums: some View {
        if showRecentlyAdded {
            AlbumPreviewCollection(
                for: library.albums.sorted(by: Array<Album>.AlbumSortBy.dateAdded).reversed(),
                titleText: "Recently added",
                emptyText: "No albums"
            )
            .stackType(.horizontal)
        }
    }
}

#if DEBUG
struct LibraryScreen_Previews: PreviewProvider {
    static var previews: some View {
        LibraryScreen()
            .previewDisplayName("Default")
            .environmentObject(PreviewUtils.libraryRepo)

        LibraryScreen()
            .previewDisplayName("Empty library")
            .environmentObject(PreviewUtils.libraryRepoEmpty)
    }
}
#endif
