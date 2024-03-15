import OSLog
import SFSafeSymbols
import SwiftUI

enum EnqueuePosition {
    case last
    case next
}

struct EnqueueButton: View {
    @EnvironmentObject
    private var library: LibraryRepository

    @ObservedObject
    var player: MusicPlayer

    let text: String?
    let item: any JellyfinItem
    let position: EnqueuePosition

    init(
        text: String? = nil,
        item: any JellyfinItem,
        position: EnqueuePosition = .last,
        player: MusicPlayer = .shared
    ) {
        self.text = text
        self.item = item
        self.position = position
        _player = ObservedObject(wrappedValue: player)
    }

    var body: some View {
        Button {
            action()
        } label: {
            switch position {
            case .last:
                Image(systemSymbol: .textAppend)
            case .next:
                Image(systemSymbol: .textInsert)
            }

            if let text {
                Text(text)
            }
        }
    }

    func action() {
        switch item {
        case let album as Album:
            let songs = library.songs.filtered(by: .albumId(album.id))
            player.enqueue(songs: songs.sorted(by: .index), position: position)
            Alerts.done("Album added to queue")
        case let song as Song:
            player.enqueue(song: song, position: position)
            Alerts.done("Song added to queue")
        default:
            Logger.player.info("Failed to enqueue item \(item.id): item type not supported")
            Alerts.error("Enqueue failed")
        }
    }
}

#if DEBUG
// swiftlint:disable all
struct EnqueueButton_Previews: PreviewProvider {
    static var previews: some View {
        EnqueueButton(item: PreviewData.songs.first!, player: .init(preview: true))
    }
}
// swiftlint:enable all
#endif
