import MarqueeText
import SFSafeSymbols
import SwiftData
import SwiftUI

struct SongLibraryScreen: View {
    @State
    private var filter: FilterOption = .all

    @State
    private var sortBy: SortOption = .name

    @State
    private var sortDirection: SortOrder = .forward

    @State
    private var searchText: String = .empty

    var body: some View {
        SongLibraryScreenContent(filterBy: filter, sortBy: sortBy, sortOrder: sortDirection, contains: searchText)
            .navigationTitle("Songs")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    filterMenu
                    sortMenu
                }
            }
    }

    @ViewBuilder
    private var filterMenu: some View {
        let image = SFSymbol.line3HorizontalDecrease
        Menu("Filter", systemImage: image.rawValue) {
            Picker("Filter", selection: $filter) {
                Label("All songs", systemSymbol: .musicNote)
                    .tag(FilterOption.all)

                Label("Favorite", systemSymbol: .heart)
                    .tag(FilterOption.favorite)

                Label("Downloaded", systemSymbol: .icloudAndArrowDown)
                    .tag(FilterOption.downloaded)
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

private struct SongLibraryScreenContent: View {
    @Environment(\.modelContext)
    private var modelContext

    @Query
    private var songs: [Song]

    @EnvironmentObject
    private var player: MusicPlayer

    @EnvironmentObject
    private var fileRepo: FileRepository

    init(filterBy: FilterOption, sortBy: SortOption, sortOrder: SortOrder, contains text: String) {
        let predicate: Predicate<Song> = Song.predicate(for: filterBy, contains: text)
        switch sortBy {
        case .name:
            self._songs = Query(filter: predicate, sort: \.sortName, order: sortOrder, animation: .smooth)
        case .dateAdded:
            self._songs = Query(filter: predicate, sort: \.createdAt, order: sortOrder, animation: .smooth)
        }
    }

    var body: some View {
        List(songs) { song in
            SongListRow(for: song) { song in
                Menu {
                    DownloadOrRemoveButton(for: song.id, isDownloaded: song.isDownloaded)
                    NewFavoriteButton(for: song.id, isFavorite: song.isFavorite)
                } label: {
                    Image(systemSymbol: .ellipsis)
                        .resizable()
                        .scaledToFit()
                        .padding(12)
                        .contentShape(Rectangle())
                }
            }
            .frame(height: 40)
            .contextMenu {
                DownloadOrRemoveButton(for: song.id, isDownloaded: song.isDownloaded)
                NewFavoriteButton(for: song.id, isFavorite: song.isFavorite)
//                    TODO: context menu
//                    PlayButton("Play", item: song)
//
//                    EnqueueButton("Play Next", item: song, position: .next)
//                    EnqueueButton("Play Last", item: song, position: .last)
            }
        }
        .listStyle(.plain)
    }
}

#if DEBUG
// swiftlint:disable all

#Preview {
    NavigationStack {
        SongLibraryScreen()
    }
    .modelContainer(PreviewDataSource.container)
    .environmentObject(ApiClient(previewEnabled: true))
}

// swiftlint:enable all
#endif

private struct SongListRow<Action: View>: View {
    private let song: Song
    private var action: Action?

    init(for song: Song, @ViewBuilder action: @escaping (Song) -> Action) {
        self.song = song
        self.action = action(song)
    }

    var body: some View {
        GeometryReader { proxy in
            HStack {
                HStack {
                    ArtworkComponent(for: song.album?.jellyfinId ?? .empty)
                        .frame(width: proxy.size.height, height: proxy.size.height)

                    songInfo
                        .frame(height: proxy.size.height)

                    Spacer()
                }
                .frame(width: proxy.size.width - proxy.size.height)
                .contentShape(Rectangle())
//                .onTapGesture { onTap() }

                action
                    .buttonStyle(.plain)
                    .foregroundColor(Color.accentColor)
                    .frame(width: proxy.size.height, height: proxy.size.height)
            }
            .frame(height: proxy.size.height)
        }
    }

    @ViewBuilder
    private var songInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            MarqueeText(
                text: song.name,
                font: .preferredFont(forTextStyle: .title3),
                leftFade: UIConstants.marqueeFadeLen,
                rightFade: UIConstants.marqueeFadeLen,
                startDelay: UIConstants.marqueeDelay
            )

            MarqueeText(
                text: song.album?.name ?? .empty,
                font: .systemFont(ofSize: 12),
                leftFade: UIConstants.marqueeFadeLen,
                rightFade: UIConstants.marqueeFadeLen,
                startDelay: UIConstants.marqueeDelay
            )
            .foregroundColor(.gray)
        }
    }

    private func onTap() {
        Task {
            do {
//                try await player.play(song: song)
                Alerts.info("Feature is not available")
            } catch {
                // TODO: reason
                Alerts.error("Failed to play song")
            }
        }
    }
}

extension SongListRow where Action == EmptyView {
    init(for song: Song) {
        self.song = song
    }
}
