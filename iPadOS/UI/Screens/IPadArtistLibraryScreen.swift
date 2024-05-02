import MarqueeText
import SFSafeSymbols
import SwiftData
import SwiftUI

struct IPadArtistLibraryScreen: View {
    @State
    private var filter: FilterOption = .all

    @State
    private var sortBy: SortOption = .name

    @State
    private var sortDirection: SortOrder = .forward

    var body: some View {
        IPadArtistLibraryScreenContent(filterBy: filter, sortBy: sortBy, sortOrder: sortDirection)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { filterMenu }
                ToolbarItem(placement: .topBarTrailing) { sortMenu }
                ToolbarItem(placement: .topBarTrailing) { IPadRefreshButton() }
            }
    }

    @ViewBuilder
    private var filterMenu: some View {
        let image = SFSymbol.line3HorizontalDecrease
        Menu("Filter", systemImage: image.rawValue) {
            Picker("Filter", selection: $filter) {
                Label("All Artists", systemSymbol: .musicMic)
                    .tag(FilterOption.all)

                Label("Favorite", systemSymbol: .heart)
                    .tag(FilterOption.favorite)
            }
            .pickerStyle(.inline)
        }
    }

    @ViewBuilder
    private var sortMenu: some View {
        Menu("Sort", systemImage: SFSymbol.arrowUpArrowDown.rawValue) {
            Picker("Sort By", selection: $sortBy) {
                Label("Name", systemSymbol: .character)
                    .tag(SortOption.name)

                Label("Date Added", systemSymbol: .clock)
                    .tag(SortOption.dateAdded)
            }
            .pickerStyle(.inline)

            Picker("Order", selection: $sortDirection) {
                Label("Ascending", systemSymbol: .arrowUp)
                    .tag(SortOrder.forward)

                Label("Descending", systemSymbol: .arrowDown)
                    .tag(SortOrder.reverse)
            }
            .pickerStyle(.inline)
        }
    }
}

private struct IPadArtistLibraryScreenContent: View {
    @Environment(\.modelContext)
    private var modelContext

    @Query
    private var artists: [Artist]

    @State
    private var path = NavigationPath()

    init(filterBy: FilterOption, sortBy: SortOption, sortOrder: SortOrder) {
        let predicate: Predicate<Artist> = Artist.predicate(for: filterBy)
        switch sortBy {
        case .name:
            self._artists = Query(filter: predicate, sort: \.sortName, order: sortOrder, animation: .smooth)
        case .dateAdded:
            self._artists = Query(filter: predicate, sort: \.createdAt, order: sortOrder, animation: .smooth)
        }
    }

    var body: some View {
        NavigationStack(path: $path) {
            // TODO: maybe a grid of tiles
            List(artists) { artist in
                NavigationLink(value: artist) {
                    //                TODO: artwork component accepts only jellyfin items
                    //                ArtworkComponent(for: artist)
                    //                    .frame(width: 40, height: 40)

                    MarqueeText(
                        text: artist.name,
                        font: .preferredFont(forTextStyle: .title2),
                        leftFade: UIConstants.marqueeFadeLen,
                        rightFade: UIConstants.marqueeFadeLen,
                        startDelay: UIConstants.marqueeDelay
                    )
                }
            }
            .listStyle(.plain)
            .navigationDestination(for: Artist.self) { artist in
                Text(artist.name)
            }
        }
    }
}

#if DEBUG
// swiftlint:disable all

#Preview {
    NavigationStack {
        IPadArtistLibraryScreen()
    }
    .modelContainer(PreviewDataSource.container)
}

// swiftlint:enable all
#endif
