import SFSafeSymbols
import SwiftUI

struct MainScreen: View {
    @EnvironmentObject
    private var player: MusicPlayer

    @State
    private var isPlayerPresented = false

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
        NowPlayingComponent(isPresented: $isPlayerPresented) {
            LibraryScreen()
        }
        .tabItem {
            Image(systemSymbol: .musicQuarternote3)
            Text("Library")
        }
    }

    @ViewBuilder
    private var searchTab: some View {
        NowPlayingComponent(isPresented: $isPlayerPresented) {
            SearchScreen()
        }
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
        MainScreen()
            .environmentObject(PreviewUtils.libraryRepo)
            .environmentObject(PreviewUtils.player)
            .environmentObject(ApiClient(previewEnabled: true))
    }
}
#endif
