import SFSafeSymbols
import SwiftUI

struct FavoriteIcon: View {
    @Binding
    var isFavorite: Bool

    var body: some View {
        let favoriteIcon: SFSymbol = isFavorite ? .heartFill : .heart
        Image(systemSymbol: favoriteIcon)
    }
}

#if DEBUG
struct FavoriteIcon_Previews: PreviewProvider {
    @State
    static var isFavorite_yes = true

    @State
    static var isFavorite_no = false

    static var previews: some View {
        FavoriteIcon(isFavorite: $isFavorite_yes)
        FavoriteIcon(isFavorite: $isFavorite_no)
    }
}
#endif
