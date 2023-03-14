import SFSafeSymbols
import SwiftUI

struct ListOptionComponent: View {
    var symbol: SFSymbol?
    var text: String?

    var body: some View {
        HStack(spacing: 5) {
            if let symbol = symbol {
                Image(systemSymbol: symbol)
                    .frame(minWidth: 25)
            }

            if let text = text {
                Text(text)
            }
        }
    }
}

#if DEBUG
struct ListOptionComponent_Previews: PreviewProvider {
    static var previews: some View {
        ListOptionComponent(
            symbol: .trash,
            text: "Anime was mistake"
        )
    }
}
#endif
