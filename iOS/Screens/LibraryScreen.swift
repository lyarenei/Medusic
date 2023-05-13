import Defaults
import SFSafeSymbols
import SwiftUI

struct LibraryScreen: View {
    @ObservedObject
    var albumRepo: AlbumRepository

    @Default(.libraryShowFavorites)
    var showFavoriteAlbums

    @Default(.libraryShowRecentlyAdded)
    var showRecentlyAdded

    init(albumRepo: AlbumRepository = .shared) {
        _albumRepo = ObservedObject(wrappedValue: albumRepo)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                bodyContent()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem { RefreshButton(mode: .all) }
            }
        }
        .navigationViewStyle(.stack)
    }

    @ViewBuilder
    private func bodyContent() -> some View {
        VStack {
            mainNavigation()
                .padding(.leading)

            favoriteAlbums()
                .padding(.top, 10)

            recentlyAddedAlbums()
                .padding(.top, 10)
        }
    }

    @ViewBuilder
    private func mainNavigation() -> some View {
        VStack(spacing: 5) {
            Divider()
            navLink(for: "Playlists", to: EmptyView(), icon: .musicNoteList)
                .disabled(true)

            Divider()

            navLink(for: "Artists", to: EmptyView(), icon: .musicMic)
                .disabled(true)

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
                    .frame(width: 25, height: 25)
                    .foregroundColor(.gray)
                    .font(.system(size: 10))
            }
            .buttonStyle(.plain)
            .padding(.trailing, 15)
        }
        .contentShape(Rectangle())
        .font(.title2)
        .padding(.vertical, 5)
    }

    @ViewBuilder
    private func favoriteAlbums() -> some View {
        if showFavoriteAlbums {
            AlbumPreviewCollection(
                for: albumRepo.albums.favorite.consistent,
                titleText: "Favorite albums",
                emptyText: "No favorite albums"
            ) {
                Text("All favorite albums")
            }
            .stackType(numberOfEnabledSections() < 3 ? .vertical : .horizontal)
        }
    }

    @ViewBuilder
    private func recentlyAddedAlbums() -> some View {
        if showRecentlyAdded {
            AlbumPreviewCollection(
                for: albumRepo.albums.sortedByDateAdded,
                titleText: "Recently added",
                emptyText: "No albums"
            ) {
                Text("All albums, sorted by recently added")
            }
            .stackType(numberOfEnabledSections() < 3 ? .vertical : .horizontal)
        }
    }

    /// Get number of currently enabled sections on library screen.
    private func numberOfEnabledSections() -> Int {
        let sections = [
            Defaults[.libraryShowFavorites],
            Defaults[.libraryShowRecentlyAdded],
        ]

        return sections.filter { $0 == true }.count
    }
}

#if DEBUG
struct LibraryScreen_Previews: PreviewProvider {
    static var previews: some View {
        LibraryScreen(
            albumRepo: .init(
                store: .previewStore(
                    items: PreviewData.albums,
                    cacheIdentifier: \.uuid
                )
            )
        )

        LibraryScreen(
            albumRepo: .init(
                store: .previewStore(
                    items: [],
                    cacheIdentifier: \.uuid
                )
            )
        )
        .previewDisplayName("Empty library")
    }
}
#endif
