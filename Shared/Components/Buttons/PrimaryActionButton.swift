import Defaults
import SwiftUI

struct PrimaryActionButton: View {
    @Default(.primaryAction)
    private var primaryAction: PrimaryAction

    let item: Item

    init(for item: Item) {
        self.item = item
    }

    var body: some View {
        switch primaryAction {
            case .download:
                downloadButton(for: item)
            case .favorite:
                FavoriteButton(for: item)
        }
    }

    // TODO: temporary until download button is refactored
    @ViewBuilder
    func downloadButton(for item: Item) -> some View {
        switch item {
        case .album(let album):
            DownloadButton(for: album.uuid)
        case .song(let song):
            DownloadButton(for: song.uuid)
        }
    }
}

#if DEBUG
struct PrimaryActionButton_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryActionButton(for: .song(PreviewData.songs.first!))
    }
}
#endif

enum PrimaryAction: String, Defaults.Serializable {
    case download
    case favorite
}

enum Item {
    case album(_ album: Album)
    case song(_ song: Song)
}
