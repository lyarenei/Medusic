import Defaults
import SwiftUI

struct AppearanceSettings: View {
    @Default(.appColorScheme)
    private var colorScheme

    @Default(.primaryAction)
    private var primaryAction: PrimaryAction

    @Default(.libraryShowFavorites)
    private var libraryShowFavorites

    @Default(.libraryShowRecentlyAdded)
    private var libraryShowRecentlyAdded

    @Default(.maxPreviewItems)
    private var maxPreviewItems: Int

    var body: some View {
        List {
            Section {
                colorSchemeOption
            }

            Section {
                primaryActionOption
            }

            Section {
                libraryShowFavoritesOption
                libraryShowRecentlyAddedOption
                maxPreviewItemsOption
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var colorSchemeOption: some View {
        Picker("Color scheme", selection: $colorScheme) {
            Text("System").tag(AppColorScheme.system)
            Text("Light").tag(AppColorScheme.light)
            Text("Dark").tag(AppColorScheme.dark)
        }
    }

    @ViewBuilder
    private var primaryActionOption: some View {
        Picker("Primary action", selection: $primaryAction) {
            Text("Download").tag(PrimaryAction.download)
            Text("Favorite").tag(PrimaryAction.favorite)
        }
    }

    @ViewBuilder
    private var libraryShowFavoritesOption: some View {
        Toggle(isOn: $libraryShowFavorites) {
            Text("Show favorites")
        }
    }

    @ViewBuilder
    private var libraryShowRecentlyAddedOption: some View {
        Toggle(isOn: $libraryShowRecentlyAdded) {
            Text("Show recently added")
        }
    }

    @ViewBuilder
    private var maxPreviewItemsOption: some View {
        Picker("Max items in previews", selection: $maxPreviewItems) {
            Text("5").tag(5)
            Text("10").tag(10)
            Text("15").tag(15)
            Text("20").tag(20)
            Text("25").tag(25)
        }
    }
}

#Preview {
    AppearanceSettings()
}
