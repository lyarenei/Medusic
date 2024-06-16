import SFSafeSymbols
import SwiftUI

struct SongLibraryScreen: View {
    @EnvironmentObject
    private var library: LibraryRepository

    @State
    private var filterBy: FilterOption = .all

    @State
    private var sortBy: SortOption = .name

    @State
    private var sortDirection: SortDirection = .ascending

    @State
    private var searchText: String = .empty

    let songs: [SongDto]

    init(
        _ songs: [SongDto],
        filterBy: FilterOption = .all,
        sortBy: SortOption = .name,
        sortDirection: SortDirection = .ascending
    ) {
        self.songs = songs
        self.filterBy = filterBy
        self.sortBy = sortBy
        self.sortDirection = sortDirection
    }

    var body: some View {
        content
            .navigationTitle("Songs")
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
        let songsToDisplay = songs.filtered(by: filterBy).nameContains(text: searchText).sorted(by: sortBy).ordered(by: sortDirection)
        if songsToDisplay.isNotEmpty {
            songList(songsToDisplay)
        } else {
            ContentUnavailableView(
                "No songs",
                systemImage: SFSymbol.eyeSlash.rawValue,
                description: Text("Check selected filter or try refreshing the database.")
            )
        }
    }

    @ViewBuilder
    private func songList(_ songs: [SongDto]) -> some View {
        List(songs) { song in
            let albumName = library.albums.by(id: song.albumId)?.name ?? .empty
            NewSongListRowComponent(for: song, subtitle: albumName) { _ in
                Alerts.notImplemented()
            } menuActions: { song in
                DownloadSongButton(songId: song.id, isDownloaded: song.isDownloaded)
                Divider()
                PlayButton("Play", item: song)
                EnqueueButton("Play next", item: song, position: .next)
                EnqueueButton("Play last", item: song, position: .last)
                Divider()
                FavoriteButton(songId: song.id, isFavorite: song.isFavorite)
            }
            .frame(height: 40)
            .contextMenu {
                DownloadSongButton(songId: song.id, isDownloaded: song.isDownloaded)
                Divider()
                PlayButton("Play", item: song)
                EnqueueButton("Play next", item: song, position: .next)
                EnqueueButton("Play last", item: song, position: .last)
                Divider()
                FavoriteButton(songId: song.id, isFavorite: song.isFavorite)
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
}

#if DEBUG
// swiftlint:disable all

#Preview {
    NavigationStack {
        SongLibraryScreen(PreviewData.songs)
            .environmentObject(PreviewUtils.libraryRepo)
            .environmentObject(PreviewUtils.apiClient)
    }
}

// swiftlint:enable all
#endif
