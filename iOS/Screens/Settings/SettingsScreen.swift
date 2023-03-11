import SFSafeSymbols
import SwiftUI

struct SettingsScreen: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                List {
                    JellyfinSection()
                    GeneralSection()
                }
                .navigationTitle("Settings")
                .listStyle(.grouped)
                .buttonStyle(.plain)

                // TODO: allow keyboard to cover this
                AboutServer()
            }
        }
    }
}

#if DEBUG
struct SettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        SettingsScreen()
            .environment(\.api, .preview)
    }
}
#endif
