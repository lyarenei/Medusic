import SFSafeSymbols
import SwiftUI

struct AlbumLibraryScreen: View {
    @EnvironmentObject
    private var repo: LibraryRepository

    @State
    private var filterBy: FilterOption = .all

    @State
    private var sortBy: SortOption = .name

    @State
    private var sortDirection: SortDirection = .ascending

    @State
    private var searchText: String = .empty

    let albums: [AlbumDto]

    init(
        _ albums: [AlbumDto],
        filterBy: FilterOption = .all,
        sortBy: SortOption = .name,
        sortDirection: SortDirection = .ascending
    ) {
        self.albums = albums
        self.filterBy = filterBy
        self.sortBy = sortBy
        self.sortDirection = sortDirection
    }

    var body: some View {
        content
            .navigationTitle("Albums")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .toolbar {
                ToolbarItemGroup {
                    filterMenu
                    sortMenu
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        let albumsToDisplay = albums.filtered(by: filterBy).nameContains(text: searchText).sorted(by: sortBy).ordered(by: sortDirection)
        if albumsToDisplay.isNotEmpty {
            albumList(albumsToDisplay)
        } else {
            ContentUnavailableView(
                "No albums",
                systemImage: SFSymbol.eyeSlash.rawValue,
                description: Text("Check selected filter or try refreshing the database.")
            )
        }
    }

    @ViewBuilder
    private func albumList(_ albums: [AlbumDto]) -> some View {
        List(albums) { album in
            albumListRow(for: album)
                .frame(height: 60)
                .contextMenu {
//                    DownloadButton(albumId: album.id, isDownloaded: album.isDownloaded)
                    Divider()
                    PlayButton("Play", item: album)
                    EnqueueButton("Play next", item: album, position: .next)
                    EnqueueButton("Play last", item: album, position: .last)
                    Divider()
                    FavoriteButton(albumId: album.id, isFavorite: album.isFavorite)
                }
        }
        .listStyle(.plain)
    }

    @ViewBuilder
    private var filterMenu: some View {
        let image = SFSymbol.line3HorizontalDecrease
        Menu("Filter", systemImage: image.rawValue) {
            Picker("Filter", selection: $filterBy) {
                Label("All", systemSymbol: .musicNote)
                    .tag(FilterOption.all)

                Label("Favorite", systemSymbol: .heart)
                    .tag(FilterOption.favorite)
            }
            .pickerStyle(.inline)
        }
    }

    @ViewBuilder
    private var sortMenu: some View {
        let symbol = SFSymbol.arrowUpArrowDown
        Menu("Sort", systemImage: symbol.rawValue) {
            Picker("Sort by", selection: $sortBy) {
                Label("Name", systemSymbol: .character)
                    .tag(SortOption.name)

                Label("Date added", systemSymbol: .clock)
                    .tag(SortOption.dateAdded)
            }
            .pickerStyle(.inline)

            Picker("Order by", selection: $sortDirection) {
                Label("Ascending", systemSymbol: .arrowUp)
                    .tag(SortDirection.ascending)

                Label("Descending", systemSymbol: .arrowDown)
                    .tag(SortDirection.descending)
            }
            .pickerStyle(.inline)
        }
    }

    @ViewBuilder
    private func albumListRow(for album: AlbumDto) -> some View {
        GeometryReader { proxy in
            NavigationLink {
                AlbumDetailScreen(album: album)
            } label: {
                HStack {
                    HStack {
                        ArtworkComponent(for: album.id)
                            .showFavorite(album.isFavorite)
                            .frame(width: proxy.size.height, height: proxy.size.height)
                    }

                    let artistName = repo.artists.by(id: album.artistId)?.name ?? .empty
                    albumDetail(name: album.name, artist: artistName)
                        .frame(height: proxy.size.height)

                    Spacer()
                }
                .frame(width: proxy.size.width - proxy.size.height)
                .contentShape(Rectangle())
            }
        }
    }

    @ViewBuilder
    private func albumDetail(name: String, artist: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            MarqueeTextComponent(name, font: .title2)
            MarqueeTextComponent(artist, color: .gray)
        }
    }
}

#if DEBUG
// swiftlint:disable all

#Preview {
    NavigationStack {
        AlbumLibraryScreen(PreviewData.albums)
            .environmentObject(PreviewUtils.libraryRepo)
    }
}

// swiftlint:enable all
#endif
