import Boutique
import LNPopupUI
import SFSafeSymbols
import SwiftUI

struct MainScreen: View {
    @EnvironmentObject
    private var player: MusicPlayer

    @Stored(in: .downloadQueue)
    private var downloadQueue

    @State
    private var showNowPlayingBar = false

    @State
    private var selectedTab: NavigationTab = .library

    init(downloadQueue: Store<Song> = .downloadQueue) {
        self._downloadQueue = Stored(in: downloadQueue)
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            libraryTab
                .tag(NavigationTab.library)

            searchTab
                .tag(NavigationTab.search)

            downloadsTab
                .tag(NavigationTab.downloads)

            settingsTab
                .tag(NavigationTab.settings)
        }
        .onChange(of: player.currentSong) { evaluateBarPresent() }
        .onChange(of: selectedTab) { evaluateBarPresent() }
        .popup(isBarPresented: $showNowPlayingBar) {
            MusicPlayerScreen()
                .padding(.top, 30)
        }
        .popupBarCustomView { NowPlayingBarComponent() }
    }

    @ViewBuilder
    private var libraryTab: some View {
        LibraryScreen()
            .tabItem {
                Image(systemSymbol: .musicQuarternote3)
                Text("Library")
            }
    }

    @ViewBuilder
    private var searchTab: some View {
        SearchScreen()
            .tabItem {
                Image(systemSymbol: .magnifyingglass)
                Text("Search")
            }
    }

    @ViewBuilder
    private var downloadsTab: some View {
        Text("Downloads")
            .tabItem { Label("Downloads", systemSymbol: .icloudAndArrowDown) }
            .badge(downloadQueue.count)
    }

    @ViewBuilder
    private var settingsTab: some View {
        SettingsScreen()
            .tabItem {
                Image(systemSymbol: .gear)
                Text("Settings")
            }
    }

    private func evaluateBarPresent() {
        showNowPlayingBar = player.currentSong != nil && selectedTab != .settings
    }
}

extension MainScreen {
    enum NavigationTab {
        case library
        case search
        case downloads
        case settings
    }
}

#if DEBUG
// swiftlint:disable all

#Preview {
    MainScreen(downloadQueue: .previewStore(items: PreviewData.songs))
        .environmentObject(PreviewUtils.libraryRepo)
        .environmentObject(PreviewUtils.player)
        .environmentObject(ApiClient(previewEnabled: true))
        .environmentObject(PreviewUtils.fileRepo)
}

// swiftlint:enable all
#endif
