import SwiftUI

struct HomeScreen: View {
    @ObservedObject
    var player: MusicPlayer

    @State
    var isPlayerPresented = false

    @State
    var isPlayerOpen = false

    init(
        player: MusicPlayer = .shared
    ) {
        self._player = ObservedObject(wrappedValue: player)
    }

    var body: some View {
        TabView {
            libraryTab()
            searchTab()
            settingsTab()
        }
        .onChange(of: player.currentSong) { curSong in
            withAnimation(.linear) {
                isPlayerPresented = curSong != nil
            }
        }
    }

    @ViewBuilder
    func libraryTab() -> some View {
        NowPlayingComponent(
            isPresented: $isPlayerPresented,
            content: LibraryScreen()
        )
        .tabItem {
            Image(systemSymbol: .musicQuarternote3)
            Text("Library")
        }
        .tag("library_tab")
    }

    @ViewBuilder
    func searchTab() -> some View {
        NowPlayingComponent(
            isPresented: $isPlayerPresented,
            content: SearchScreen()
        )
        .tabItem {
            Image(systemSymbol: .magnifyingglass)
            Text("Search")
        }
        .tag("search_tab")
    }

    @ViewBuilder
    func settingsTab() -> some View {
        SettingsScreen()
            .tabItem {
                Image(systemSymbol: .gear)
                Text("Settings")
            }
            .tag("settings_tab")
    }
}

#if DEBUG
struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen(player: .init(preview: true))
    }
}
#endif
