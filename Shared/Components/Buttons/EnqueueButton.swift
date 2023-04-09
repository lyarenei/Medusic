import SFSafeSymbols
import SwiftUI

enum EnqueuePosition {
    case last, next
}

struct EnqueueButton: View {
    @ObservedObject
    var player: MusicPlayer

    let text: String?
    let item: Item
    let position: EnqueuePosition
    let songRepo: SongRepository

    init(
        text: String? = nil,
        item: Item,
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

            if let text = text {
                Text(text)
            }
        }
    }

    func action() {
        Task(priority: .userInitiated) {
            switch item {
            case .album(let album):
                let songs = await songRepo.getSongs(ofAlbum: album.uuid)
                await player.enqueue(songs: songs, position: position)
            case .song(let song):
                await player.enqueue(itemId: song.uuid, position: position)
            }
        }
    }
}

#if DEBUG
struct EnqueueButton_Previews: PreviewProvider {
    static var previews: some View {
        EnqueueButton(
            item: .song(PreviewData.songs.first!),
            player: .init(preview: true),
            songRepo: .init(store: .previewStore(items: PreviewData.songs, cacheIdentifier: \.uuid))
        )
    }
}
#endif
