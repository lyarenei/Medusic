import SFSafeSymbols
import SwiftUI

struct PlayPreviousButton: View {
    @ObservedObject
    var player: MusicPlayer

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
            Image(systemSymbol: .backwardFill)
            if let text {
                Text(text)
            }
        }
    }

    func action() {
        player.skipBackward()
    }
}

#if DEBUG
struct PlayPreviousButton_Previews: PreviewProvider {
    static var previews: some View {
        PlayPreviousButton(player: .init(preview: true))
    }
}
#endif
