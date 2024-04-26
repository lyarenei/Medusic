import Defaults
import SwiftUI

struct PrimaryActionButton<Item: JellyfinItem>: View {
    @Default(.primaryAction)
    private var primaryAction: PrimaryAction

    let item: Item

    var body: some View {
        switch primaryAction {
        case .download:
            DownloadButton(item: item)
        case .favorite:
            FavoriteButton(item: item)
        }
    }
}

#if DEBUG
// swiftlint:disable all

#Preview {
    PrimaryActionButton(item: PreviewData.songs.first!)
}

// swiftlint:enable all
#endif
