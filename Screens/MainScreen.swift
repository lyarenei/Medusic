import SFSafeSymbols
import SwiftUI

struct MainScreen: View {
    @ObservedObject
    private var player: MusicPlayer

    @State
    private var isPlayerPresented = false

    init(
        player: MusicPlayer = .shared
    ) {
        self._player = ObservedObject(wrappedValue: player)
    }

    var body: some View {
        TabView {
            libraryTab
            searchTab
            settingsTab
        }
        .onChange(of: player.currentSong) { curSong in
            withAnimation(.linear) {
                isPlayerPresented = curSong != nil
            }
        }
    }

    @ViewBuilder
    private var libraryTab: some View {
        NowPlayingComponent(
            isPresented: $isPlayerPresented,
            content: LibraryScreen()
        )
        .tabItem {
            Image(systemSymbol: .musicQuarternote3)
            Text("Library")
        }
    }

    @ViewBuilder
    private var searchTab: some View {
        NowPlayingComponent(
            isPresented: $isPlayerPresented,
            content: SearchScreen()
        )
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
}

#if DEBUG
struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen(player: .init(preview: true))
            .environmentObject(PreviewUtils.libraryRepo)
    }
}
#endif
