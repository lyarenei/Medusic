import Defaults
import SwiftUI

struct PrimaryActionButton: View {
    @Default(.primaryAction)
    private var primaryAction: PrimaryAction

    let itemId: String

    init(for itemId: String) {
        self.itemId = itemId
    }

    var body: some View {
        switch primaryAction {
            case .download:
                DownloadButton(for: itemId)
            case .favorite:
                FavoriteButton(isFavorite: false)
            default:
                Image(systemSymbol: .faceDashed)
        }
    }
}

#if DEBUG
struct PrimaryActionButton_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryActionButton(for: PreviewData.songs[0].uuid)
    }
}
#endif

enum PrimaryAction: String, Defaults.Serializable {
    case download
    case favorite
}
