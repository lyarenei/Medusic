import SFSafeSymbols
import SwiftUI

struct PlayNextButton: View {
    @ObservedObject
    var player: MusicPlayer

    @State
    private var isLongPress = false

    let text: String?

    init(
        text: String? = nil,
        player: MusicPlayer = .shared
    ) {
        self.text = text
        _player = ObservedObject(wrappedValue: player)
    }

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemSymbol: .forwardFill)
            if let text {
                Text(text)
            }
        }
        .simultaneousGesture(
            LongPressGesture(minimumDuration: MusicPlayer.seekDelay).onEnded { isSuccess in
                guard isSuccess else { return }
                isLongPress = isSuccess
                player.seekForward(isActive: true)
            }
        )
        .onLongPressGesture(perform: {}, onPressingChanged: { isPressing in
            guard !isPressing else {
                isLongPress = false
                return
            }

            player.seekForward(isActive: false)
        })
    }

    func action() {
        guard !isLongPress else { return }
        player.skipForward()
    }
}

#if DEBUG
struct PlayNextButton_Previews: PreviewProvider {
    static var previews: some View {
        PlayNextButton(player: .init(preview: true))
    }
}
#endif
