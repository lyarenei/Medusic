import SFSafeSymbols
import SwiftUI

enum EnqueuePosition {
    case last, next
}

struct EnqueueButton: View {
    @ObservedObject
    var player: MusicPlayer

    let text: String?
    let itemId: String
    let mode: EnqueuePosition

    init(
        _ text: String? = nil,
        for itemId: String,
        mode: EnqueuePosition = .last,
        player: MusicPlayer = .shared
    ) {
        self.text = text
        self.itemId = itemId
        self.mode = mode
        _player = ObservedObject(wrappedValue: player)
    }

    var body: some View {
        Button {
            action()
        } label: {
            switch mode {
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
            await player.enqueue(itemId: itemId, position: mode)
        }
    }
}

#if DEBUG
struct EnqueueButton_Previews: PreviewProvider {
    static var previews: some View {
        EnqueueButton(for: PreviewData.songs.first!.uuid, player: .init(preview: true))
    }
}
#endif
