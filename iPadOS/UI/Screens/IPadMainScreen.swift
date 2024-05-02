import SFSafeSymbols
import SwiftData
import SwiftUI

struct IPadMainScreen: View {
    @Query(sort: \Album.favoriteAt, order: .reverse)
    private var favoriteAlbums: [Album]

    @Query(sort: \Album.createdAt, order: .reverse)
    private var recentAlbums: [Album]

    @State
    private var selectedMenu: NavOption? = .home

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedMenu) {
                Label("Home", systemSymbol: .house)
                    .tag(NavOption.home)

                Label("Artists", systemSymbol: .musicMic)
                    .tag(NavOption.artists)
            }
            .navigationTitle("Medúsic")
            .listStyle(.plain)
            .toolbar { ToolbarItem(placement: .bottomBar) { IPadRefreshButton() } }
        } detail: {
            switch selectedMenu {
            case .home:
                ContentUnavailableView("This is a home view", systemImage: SFSymbol.house.rawValue)
            case .artists:
                IPadArtistLibraryScreen()
            default:
                ContentUnavailableView("Select an item from menu", systemImage: SFSymbol.xmark.rawValue)
            }
        }
    }
}

extension IPadMainScreen {
    enum NavOption {
        case home
        case artists
    }
}

#if DEBUG
// swiftlint:disable all

#Preview {
    IPadMainScreen()
        .modelContainer(PreviewDataSource.container)
        .environmentObject(ApiClient(previewEnabled: true))
}

// swiftlint:enable all
#endif
