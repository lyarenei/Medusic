import SFSafeSymbols
import SwiftUI

struct PlayPreviousButton: View {
    @ObservedObject
    private var player: MusicPlayer

    @State
    private var isLongPress = false

    private let text: String?

    init(_ text: String? = nil, player: MusicPlayer = .shared) {
        self.text = text
        _player = ObservedObject(wrappedValue: player)
    }

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemSymbol: .backwardFill)
            if let text {
                Text(text)
            }
        }
        .simultaneousGesture(
            LongPressGesture(minimumDuration: MusicPlayer.seekDelay).onEnded { isSuccess in
                guard isSuccess else { return }
                isLongPress = isSuccess
                player.seekBackward(isActive: true)
            }
        )
        .onLongPressGesture(perform: {}, onPressingChanged: { isPressing in
            guard !isPressing else {
                isLongPress = false
                return
            }

            player.seekBackward(isActive: false)
        })
    }

    func action() {
        guard !isLongPress else { return }
        player.skipBackward()
    }
}

#if DEBUG

#Preview {
    PlayPreviousButton(player: .init(preview: true))
}

#endif
