import Defaults
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

            albumSection(
                title: "Favorite albums",
                empty: "No favorite albums",
                albums: albumRepo.albums.favorite.consistent
            )
            .padding(.top, 10)

            albumSection(
                title: "Recently added",
                empty: "No albums",
                albums: albumRepo.albums.sortedByDateAdded
            )
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
    private func albumSection(title: String, empty: String, albums: [Album]) -> some View {
        VStack(spacing: 7) {
            Group {
                sectionTitle(title)
                Divider()
            }
            .padding(.leading)

            if Defaults[.libraryShowFavorites] && Defaults[.libraryShowLatest] {
                sectionHContent(albums, empty: empty)
            } else {
                sectionVContent(albums, empty: empty)
                    .padding(.leading)
            }
        }
    }

    @ViewBuilder
    private func sectionTitle(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.title)
                .bold()

            Spacer()

            NavigationLink("Show all") {}
                .padding(.trailing)
                .disabled(true)
        }
    }

    @ViewBuilder
    private func sectionVContent(_ albums: [Album], empty: String) -> some View {
        if albums.isNotEmpty {
            AlbumCollection(albums: albums)
                .forceMode(.asPlainList)
                .buttonStyle(.plain)
        } else {
            emptyText(empty)
        }
    }

    @ViewBuilder
    private func sectionHContent(_ albums: [Album], empty: String) -> some View {
        if albums.isNotEmpty {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 20) {
                    AlbumCollection(albums: albums)
                        .forceMode(.asTiles)
                        .padding(.top, 10)
                        .padding(.bottom, 15)
                }
                .padding(.leading)
            }
        } else {
            emptyText(empty)
        }
    }

    @ViewBuilder
    private func emptyText(_ text: String) -> some View {
        Text(text)
            .font(.title3)
            .foregroundColor(.gray)
            .padding(.top, 10)
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
