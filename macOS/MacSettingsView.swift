import SwiftUI

struct MacSettingsView: View {
    private enum Tabs: Hashable {
        case general, advanced
    }
    
    var body: some View {
        TabView {
            Text("General settings")
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(Tabs.general)
            Text("Advanced settings")
                .tabItem {
                    Label("Advanced", systemImage: "wrench.and.screwdriver")
                }
                .tag(Tabs.advanced)
        }
        .padding(20)
        .frame(width: 375, height: 150)
    }
}

#if DEBUG
struct MacSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        MacSettingsView()
    }
}
#endif
