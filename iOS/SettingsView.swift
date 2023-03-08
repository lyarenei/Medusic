import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink {
                    AccountSettingsView()
                } label: {
                    Image(systemName: "person.crop.circle")
                    Text("Account")
                }
                
                NavigationLink {
                    AppearanceSettingsView()
                } label: {
                    Image(systemName: "paintbrush.pointed")
                    Text("Appearance")
                }
            }
            .navigationTitle("Settings")
            .listStyle(.grouped)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
