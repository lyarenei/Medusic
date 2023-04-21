import SFSafeSymbols
import SwiftUI

enum EnqueuePosition {
    case last
    case next
}

struct EnqueueButton: View {
    @ObservedObject
    var player: MusicPlayer

    let text: String?
    let item: any JellyfinItem
    let position: EnqueuePosition
    let songRepo: SongRepository

    init(
        text: String? = nil,
        item: any JellyfinItem,
        position: EnqueuePosition = .last,
        player: MusicPlayer = .shared,
        songRepo: SongRepository = .shared
    ) {
        self.text = text
        self.item = item
        self.position = position
        _player = ObservedObject(wrappedValue: player)
        self.songRepo = songRepo
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
        Task {
            switch item {
            case let album as Album:
                let songs = await songRepo.getSongs(ofAlbum: album.uuid)
                await player.enqueue(songs: songs.sortByAlbum(), position: position)
            case let song as Song:
                await player.enqueue(song: song, position: position)
            default:
                print("Unhandled item type: \(item)")
            }
        }
    }
}

#if DEBUG
// swiftlint:disable all
struct EnqueueButton_Previews: PreviewProvider {
    static var previews: some View {
        EnqueueButton(
            item: PreviewData.songs.first!,
            player: .init(preview: true),
            songRepo: .init(store: .previewStore(items: PreviewData.songs, cacheIdentifier: \.uuid))
        )
    }
}
// swiftlint:enable all
#endif
