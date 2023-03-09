import SwiftUI

struct HomeView: View {
    var body: some View {
        TabView {
            LibraryView()
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

            SettingsView()
                .tabItem {
                    Image(systemSymbol: .gear)
                    Text("Settings")
                }
                .tag("settings_tab")
        }
    }
}

#if DEBUG
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
#endif
