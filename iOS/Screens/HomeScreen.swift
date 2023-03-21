import LNPopupUI
import SwiftUI

struct HomeScreen: View {
    @State
    private var isPlayerPresented = false

    @State
    private var isPlayerOpen = false

    var body: some View {
        TabView {
            LibraryScreen()
                .tabItem {
                    Image(systemSymbol: .musicQuarternote3)
                    Text("Library")
                }
                .tag("library_tab")

            Text("Search")
                .tabItem {
                    Image(systemSymbol: .magnifyingglass)
                    Text("Search")
                }
                .tag("search_tab")

            SettingsScreen()
                .tabItem {
                    Image(systemSymbol: .gear)
                    Text("Settings")
                }
                .tag("settings_tab")
                .onAppear { isPlayerPresented = false }
                .onDisappear { isPlayerPresented = true }
        }
        .popup(isBarPresented: $isPlayerPresented, isPopupOpen: $isPlayerOpen) {
            MusicPlayerScreen()
        }
    }
}

#if DEBUG
struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
    }
}
#endif
