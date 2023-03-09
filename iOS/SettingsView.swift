import SwiftUI

struct SettingsView: View {
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
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
#endif
