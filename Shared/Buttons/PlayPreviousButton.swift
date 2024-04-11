import SFSafeSymbols
import SwiftUI

struct PlayPreviousButton: View {
    @EnvironmentObject
    private var player: MusicPlayerCore

    @State
    private var isLongPress = false

    private let text: String?

    init(_ text: String? = nil) {
        self.text = text
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
            LongPressGesture(minimumDuration: MusicPlayerCore.seekDelay).onEnded { isSuccess in
                guard isSuccess else { return }
                isLongPress = isSuccess
//                TODO: enable
//                player.seekBackward(isActive: true)
            }
        )
        .onLongPressGesture(perform: {}, onPressingChanged: { isPressing in
            guard !isPressing else {
                isLongPress = false
                return
            }
//            TODO: enable
//            player.seekBackward(isActive: false)
        })
    }

    func action() {
        guard !isLongPress else { return }
//        TODO: enable
//        player.skipBackward()
    }
}

#if DEBUG

#Preview {
    PlayPreviousButton()
        .environmentObject(PreviewUtils.player)
}

#endif
