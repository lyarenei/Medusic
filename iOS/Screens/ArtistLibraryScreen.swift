import SFSafeSymbols
import SwiftUI

struct ArtistLibraryScreen: View {
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

    let artists: [ArtistDto]

    init(
        _ artists: [ArtistDto],
        filterBy: FilterOption = .all,
        sortBy: SortOption = .name,
        sortDirection: SortDirection = .ascending
    ) {
        self.artists = artists
        self.filterBy = filterBy
        self.sortBy = sortBy
        self.sortDirection = sortDirection
    }

    var body: some View {
        content
            .navigationTitle("Artists")
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
        let artistGroups = repo.artists
            .filtered(by: filterBy)
            .nameContains(text: searchText)
            .sorted(by: sortBy)
            .ordered(by: sortDirection)
            .grouped(by: .firstLetter)

        if repo.artists.isNotEmpty {
            List {
                ForEach(enumerating: artistGroups.keys) { key in
                    if let artists = artistGroups[key] {
                        artistSection(name: key, artists: artists)
                    }
                }
            }
            .listStyle(.plain)
        } else {
            ContentUnavailableView(
                "No artists",
                systemImage: SFSymbol.eyeSlash.rawValue,
                description: Text("Check selected filter or try refreshing the database.")
            )
        }
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
    private func artistSection(name: String, artists: [ArtistDto]) -> some View {
        Section {
            ForEach(artists) { artist in
                NavigationLink {
                    ArtistDetailScreen(artist: artist)
                } label: {
                    ArtworkComponent(for: artist.id)
                        .frame(width: 40, height: 40)

                    MarqueeTextComponent(artist.name, font: .title2)
                }
                .artistContextMenu(for: artist)
            }
        } header: {
            Text(name)
                .bold()
                .foregroundStyle(Color.primary)
                .font(.title3)
        }
    }
}

#if DEBUG
// swiftlint:disable all

#Preview("Normal") {
    NavigationStack {
        ArtistLibraryScreen(PreviewData.artists)
            .environmentObject(PreviewUtils.libraryRepo)
            .environmentObject(PreviewUtils.apiClient)
    }
}

#Preview("Empty") {
    NavigationStack {
        ArtistLibraryScreen([])
            .environmentObject(PreviewUtils.libraryRepoEmpty)
            .environmentObject(PreviewUtils.apiClient)
    }
}

// swiftlint:enable all
#endif
