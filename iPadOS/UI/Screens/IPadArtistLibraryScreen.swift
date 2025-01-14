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

    @State
    private var cols = [GridItem(.adaptive(minimum: 220))]

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
            ScrollView {
                LazyVGrid(columns: cols, spacing: 20) {
                    ForEach(artists) { artist in
                        NavigationLink(value: artist) {
                            VStack(alignment: .leading) {
                                ArtworkComponent(for: artist.jellyfinId)
                                    .frame(width: 220, height: 220)

                                MarqueeText(
                                    text: artist.name,
                                    font: .preferredFont(forTextStyle: .title2),
                                    leftFade: UIConstants.marqueeFadeLen,
                                    rightFade: UIConstants.marqueeFadeLen,
                                    startDelay: UIConstants.marqueeDelay
                                )
                            }
                        }
                        .frame(width: 220)
                        .foregroundStyle(.primary)
                    }
                }
                .navigationDestination(for: Artist.self) { artist in
                    IPadArtistDetailScreen(artist: artist)
                }
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
    .environmentObject(ApiClient(previewEnabled: true))
}

// swiftlint:enable all
#endif
