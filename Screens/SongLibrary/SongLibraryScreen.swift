import MarqueeText
import SFSafeSymbols
import SwiftUI

struct SongLibraryScreen: View {
    @StateObject
    private var controller = Controller()

    @State
    private var filterBy: FilterOption = .all

    @State
    private var sortBy: SortOption = .name

    @State
    private var sortDirection: SortDirection = .ascending

    var body: some View {
        content
            .navigationTitle("Songs")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup {
                    filterMenu
                    sortMenu
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        let songs = controller.songs.filtered(by: filterBy).sorted(by: sortBy).ordered(by: sortDirection)
        List(songs) { song in
            songListRow(for: song) { song in
                Menu {
                    // Download/remove button
                    // Favorite button
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
                // same as menu above
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
                    ArtworkComponent(for: song.albumId)
                        .frame(width: proxy.size.height, height: proxy.size.height)

                    SongDetail(for: song)
                        .frame(height: proxy.size.height)

                    Spacer()
                }
                .frame(width: proxy.size.width - proxy.size.height)
                .contentShape(Rectangle())
//                .onTapGesture {}

                action(song)
                    .buttonStyle(.plain)
                    .foregroundStyle(Color.accentColor)
                    .frame(width: proxy.size.height, height: proxy.size.height)
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
}

// swiftlint:enable all
#endif

private struct SongDetail: View {
    @StateObject
    private var controller = SongDetailController()

    @State
    private var albumName: String

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
                text: albumName,
                font: .systemFont(ofSize: 12),
                leftFade: UIConstants.marqueeFadeLen,
                rightFade: UIConstants.marqueeFadeLen,
                startDelay: UIConstants.marqueeDelay
            )
            .foregroundStyle(.gray)
        }
        .task {
            if let name = await controller.getAlbumName(for: song.albumId) {
                albumName = name
            }
        }
    }
}
