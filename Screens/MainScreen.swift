import LNPopupUI
import SFSafeSymbols
import SwiftUI

struct MainScreen: View {
    @EnvironmentObject
    private var player: MusicPlayer

    @State
    private var showNowPlayingBar = false

    @State
    private var selectedTab: NavigationTab = .library

    var body: some View {
        TabView(selection: $selectedTab) {
            libraryTab
                .tag(NavigationTab.library)

            searchTab
                .tag(NavigationTab.search)

            settingsTab
                .tag(NavigationTab.search)
        }
        .onChange(of: player.currentSong) { evaluateBarPresent() }
        .onChange(of: selectedTab) { evaluateBarPresent() }
        .popup(isBarPresented: $showNowPlayingBar) { MusicPlayerScreen() }
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
        case settings
    }
}

#if DEBUG
struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen()
            .environmentObject(PreviewUtils.libraryRepo)
            .environmentObject(PreviewUtils.player)
            .environmentObject(ApiClient(previewEnabled: true))
    }
}
#endif
