import SFSafeSymbols
import SwiftUI

struct PlayNextButton: View {
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
            Image(systemSymbol: .forwardFill)
            if let text {
                Text(text)
            }
        }
    }

    func action() {
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
