import ButtonKit
import MarqueeText
import SFSafeSymbols
import SwiftUI

struct SongLibraryScreen: View {
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

    init(
        filterBy: FilterOption = .all,
        sortBy: SortOption = .name,
        sortDirection: SortDirection = .ascending
    ) {
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
        let songs = repo.songs.filtered(by: filterBy).nameContains(text: searchText).sorted(by: sortBy).ordered(by: sortDirection)
        List(songs) { song in
            songListRow(for: song) { song in
                Menu {
                    PlayButton("Play", item: song)
                    EnqueueButton("Play next", item: song, position: .next)
                    EnqueueButton("Play last", item: song, position: .last)
                    Divider()
                    favoriteButton(for: song)
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
                PlayButton("Play", item: song)
                EnqueueButton("Play next", item: song, position: .next)
                EnqueueButton("Play last", item: song, position: .last)
                Divider()
                favoriteButton(for: song)
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
    private func songListRow(for song: SongDto, @ViewBuilder action: @escaping (SongDto) -> some View) -> some View {
        GeometryReader { proxy in
            HStack {
                HStack {
                    HStack {
                        ZStack(alignment: .bottomTrailing) {
                            ArtworkComponent(for: song.albumId)
//                            TODO: support this in artwork component
//                            if song.isFavorite {
//                                Image(systemSymbol: .heartFill)
//                                    .resizable()
//                                    .scaledToFit()
//                                    .foregroundStyle(.red)
//                                    .frame(width: 8, height: 8)
//                                    .padding(2)
//                                    .background {
//                                        RoundedRectangle(cornerRadius: 3.0)
//                                            .foregroundStyle(.background)
//                                    }
//                            }
                        }
                        .frame(width: proxy.size.height, height: proxy.size.height)
                    }

                    SongDetail(for: song)
                        .frame(height: proxy.size.height)

                    Spacer()
                }
                .frame(width: proxy.size.width - proxy.size.height)
                .contentShape(Rectangle())
//                .onTapGesture {} TODO: play

                action(song)
                    .buttonStyle(.plain)
                    .foregroundStyle(Color.accentColor)
                    .frame(width: proxy.size.height, height: proxy.size.height)
            }
        }
    }

    @ViewBuilder
    private func favoriteButton(for song: SongDto) -> some View {
        AsyncButton {
            await repo.setFavorite(songId: song.id, isFavorite: !song.isFavorite)
        } label: {
            if song.isFavorite {
                Label("Undo favorite", systemSymbol: .heartSlashFill)
            } else {
                Label("Favorite", systemSymbol: .heart)
            }
        }
        .disabledWhenLoading()
    }
}

#if DEBUG
// swiftlint:disable all

#Preview {
    NavigationStack {
        SongLibraryScreen()
            .environmentObject(PreviewUtils.libraryRepo)
    }
}

// swiftlint:enable all
#endif

private struct SongDetail: View {
    @EnvironmentObject
    private var repo: LibraryRepository

    @State
    private var albumName: String?

    private let song: SongDto

    init(for song: SongDto) {
        self.song = song
        self.albumName = .empty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            MarqueeText(
                text: song.name,
                font: .preferredFont(forTextStyle: .title3),
                leftFade: UIConstants.marqueeFadeLen,
                rightFade: UIConstants.marqueeFadeLen,
                startDelay: UIConstants.marqueeDelay
            )

            MarqueeText(
                text: albumName ?? .empty,
                font: .systemFont(ofSize: 12),
                leftFade: UIConstants.marqueeFadeLen,
                rightFade: UIConstants.marqueeFadeLen,
                startDelay: UIConstants.marqueeDelay
            )
            .foregroundStyle(.gray)
        }
        .task { albumName = repo.albums.by(id: song.albumId)?.name }
    }
}
