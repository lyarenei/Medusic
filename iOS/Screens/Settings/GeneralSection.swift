import SwiftUI

extension SettingsScreen {
    struct GeneralSection: View {
        var body: some View {
            Section(
                header: Text("General"),
                content: {
                    NavigationLink {
                        AppearanceSettingsView()
                    } label: {
                        Image(systemSymbol: .paintbrushPointed)
                        Text("Appearance")
                    }
                }
            )
        }
    }
}

#if DEBUG
struct GeneralSection_Previews: PreviewProvider {
    static var previews: some View {
        SettingsScreen()
            .environment(\.api, .preview)
    }
}
#endif
