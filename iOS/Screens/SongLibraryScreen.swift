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

    var body: some View {
        SongLibraryScreenContent(filterBy: filter, sortBy: sortBy, sortOrder: sortDirection)
            .navigationTitle("Songs")
            .navigationBarTitleDisplayMode(.large)
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

    init(filterBy: FilterOption, sortBy: SortOption, sortOrder: SortOrder) {
        let predicate: Predicate<Song> = Song.predicate(for: filterBy)
        switch sortBy {
        case .name:
            self._songs = Query(filter: predicate, sort: \.sortName, order: sortOrder, animation: .smooth)
        case .dateAdded:
            self._songs = Query(filter: predicate, sort: \.createdAt, order: sortOrder, animation: .smooth)
        }
    }

    var body: some View {
        List(songs) { song in
            SongListRow(for: song)
                .frame(height: 40)
                .onTapGesture { onTap(song.jellyfinId) }
                .contextMenu {
//                    TODO: context menu
//                    PlayButton("Play", item: song)
//                    DownloadButton(
//                        item: song,
//                        textDownload: "Download",
//                        textRemove: "Remove"
//                    )
//
//                    FavoriteButton(
//                        item: song,
//                        textFavorite: "Favorite",
//                        textUnfavorite: "Unfavorite"
//                    )
//
//                    EnqueueButton("Play Next", item: song, position: .next)
//                    EnqueueButton("Play Last", item: song, position: .last)
                }
        }
        .listStyle(.plain)
    }

    private func onTap(_ songId: String) {
        Task {
            do {
//                try await player.play(song: song)
                Alerts.info("Feature not available")
            } catch {
                // TODO: reason
                Alerts.error("Failed to play song")
            }
        }
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
                ArtworkComponent(for: song.album?.jellyfinId ?? .empty)
                    .frame(width: proxy.size.height, height: proxy.size.height)

                songInfo
                    .frame(height: proxy.size.height)

                Spacer()
                action
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
                Alerts.info("Feature not available")
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
