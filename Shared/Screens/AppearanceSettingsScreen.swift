import Defaults
import SwiftUI

struct AppearanceSettingsScreen: View {
    var body: some View {
        List {
            AlbumDisplayOption()
        }
        .listStyle(.grouped)
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#if DEBUG
struct AppearanceSettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        AppearanceSettingsScreen()
    }
}
#endif

private struct AlbumDisplayOption: View {
    @Default(.albumDisplayMode)
    var selectedOption: AlbumDisplayMode

    var body: some View {
        Picker("Show albums as", selection: $selectedOption) {
            Text("List").tag(AlbumDisplayMode.asList)
            Text("Tiles (default)").tag(AlbumDisplayMode.asTiles)
        }
    }
}
