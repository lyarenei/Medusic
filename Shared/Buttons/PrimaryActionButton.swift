import Defaults
import SwiftUI

struct PrimaryActionButton: View {
    @Default(.primaryAction)
    private var primaryAction: PrimaryAction

    let item: any JellyfinItem

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
struct PrimaryActionButton_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryActionButton(item: PreviewData.songs.first!)
    }
}
// swiftlint:enable all
#endif
