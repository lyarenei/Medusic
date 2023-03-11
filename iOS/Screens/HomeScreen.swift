import SwiftUI

struct HomeScreen: View {
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
