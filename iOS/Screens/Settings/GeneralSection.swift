import Defaults
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

                    PreviewModeToggle()
                }
            )
        }
    }
}

private struct PreviewModeToggle: View {
    @Environment(\.api)
    var api

    @Default(.previewMode)
    var previewEnabled: Bool

    var body: some View {
        Toggle(isOn: $previewEnabled) {
            HStack(spacing: 7) {
                Image(systemSymbol: .eyes)
                Text("Preview mode")
            }
        }
        .onChange(of: previewEnabled, perform: { newValue in
            if newValue {
                api.usePreviewMode()
                return
            }

            do {
                api.useDefaultMode()
                try api.performAuth()
            } catch {
                print("Failed to switch to default mode: \(error)")
            }
        })
    }
}

#if DEBUG
struct GeneralSection_Previews: PreviewProvider {
    static var previews: some View {
        SettingsScreen()
            .environment(\.api, .init())
    }
}
#endif
