import SFSafeSymbols
import SwiftUI

struct PlayNextButton: View {
    @EnvironmentObject
    private var player: MusicPlayer

    @State
    private var isLongPress = false

    @State
    private var bounce = false

    private let text: String?

    init(_ text: String? = nil) {
        self.text = text
    }

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemSymbol: .forwardFill)
                .symbolEffect(.bounce, value: bounce)

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
        bounce.toggle()
    }
}

#if DEBUG

#Preview {
    PlayNextButton()
        .environmentObject(PreviewUtils.player)
}

#endif
