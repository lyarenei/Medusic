import SFSafeSymbols
import SwiftUI

struct LibraryScreen: View {
    @ObservedObject
    var albumRepo: AlbumRepository

    init(albumRepo: AlbumRepository = .shared) {
        _albumRepo = ObservedObject(wrappedValue: albumRepo)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    mainNavigation()
                        .padding(.leading)

                    favoriteAlbums()
                        .padding(.top, 10)
                        .padding(.leading)
                }
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
    func navLink(for name: String, to dst: some View, icon: SFSymbol) -> some View {
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
        VStack(spacing: 7) {
            favoritesTitle()
            Divider()
            favoritesContent(albumRepo.albums.favorite.consistent)
        }
    }

    @ViewBuilder
    func favoritesTitle() -> some View {
        HStack {
            Text("Favorite albums")
                .font(.title)
                .bold()

            Spacer()
        }
    }

    @ViewBuilder
    func favoritesContent(_ albums: [Album]) -> some View {
        if albums.isNotEmpty {
            AlbumCollection(albums: albums)
                .forceMode(.asPlainList)
                .buttonStyle(.plain)
        } else {
            Text("No favorite albums")
                .font(.title3)
                .foregroundColor(.gray)
                .padding(.top, 10)
        }
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
