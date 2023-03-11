import SwiftUI

struct SettingsScreen: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink {
                    AccountSettingsView()
                } label: {
                    Image(systemSymbol: .personCropCircle)
                    Text("Account")
                }

                NavigationLink {
                    AppearanceSettingsView()
                } label: {
                    Image(systemSymbol: .paintbrushPointed)
                    Text("Appearance")
                }
            }
            .navigationTitle("Settings")
            .listStyle(.grouped)
        }
    }
}

#if DEBUG
struct SettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        SettingsScreen()
    }
}
#endif
