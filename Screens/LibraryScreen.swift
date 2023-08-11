import Defaults
import SFSafeSymbols
import SwiftUI

struct LibraryScreen: View {
    @EnvironmentObject
    private var albumRepo: AlbumRepository

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
        VStack {
            mainNavigation
                .padding(.leading)

            favoriteAlbums
                .padding(.top, 10)

            recentlyAddedAlbums
                .padding(.top, 10)
        }
    }

    @ViewBuilder
    private var mainNavigation: some View {
        VStack(spacing: 5) {
            Divider()
            navLink(for: "Playlists", to: EmptyView(), icon: .musicNoteList)
                .disabled(true)

            Divider()
            navLink(for: "Artists", to: ArtistLibraryScreen(), icon: .musicMic)
            Divider()
            navLink(for: "Albums", to: AlbumLibraryScreen(), icon: .squareStack)
            Divider()
            navLink(for: "Songs", to: SongsLibraryScreen(), icon: .musicNote)
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
                for: albumRepo.albums.favorite.consistent,
                titleText: "Favorite albums",
                emptyText: "No favorite albums"
            )
            .stackType(.horizontal)
        }
    }

    @ViewBuilder
    private var recentlyAddedAlbums: some View {
        if showRecentlyAdded {
            AlbumPreviewCollection(
                for: albumRepo.albums.sortedByDateAdded,
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
            .environmentObject(
                AlbumRepository(store: .previewStore(items: PreviewData.albums, cacheIdentifier: \.uuid))
            )

        LibraryScreen()
            .previewDisplayName("Empty library")
            .environmentObject(
                AlbumRepository(store: .previewStore(items: [], cacheIdentifier: \.uuid))
            )
    }
}
#endif
